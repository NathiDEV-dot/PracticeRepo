// ignore_for_file: deprecated_member_use

import 'dart:io';
// ignore: unused_import
import 'dart:math';
import 'dart:async';
// ignore: unnecessary_import
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Added import
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../core/services/lesson_creation_service.dart';
import '../../../core/models/lesson_data.dart';

class LessonCreation extends StatefulWidget {
  const LessonCreation({super.key});

  @override
  State<LessonCreation> createState() => _LessonCreationState();
}

class _LessonCreationState extends State<LessonCreation> {
  final LessonCreationService _lessonService = LessonCreationService();
  late LessonData _lessonData;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // UI State only
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;
  String? _temporaryVideoPath;
  Uint8List? _webVideoBytes;
  String? _webVideoFileName;
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingTime = const Duration();
  bool _isExtractingDuration = false;
  Timer? _recordingTimer;

  // Video player controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoLoading = false;
  bool _hasVideoError = false;

  // Database fetched data
  List<String> _availableSubjects = [];
  String _educatorGrade = '';
  bool _isLoadingData = true;

  // Professional color palette
  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _successColor = const Color(0xFF10B981);
  final Color _warningColor = const Color(0xFFF59E0B);
  final Color _errorColor = const Color(0xFFEF4444);
  final Color _infoColor = const Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _lessonData = LessonData(
      title: _titleController.text,
      description: _descriptionController.text,
      subject: '',
      grade: '',
      durationText: 'Duration will be auto-detected',
      videoFile: null,
      publishImmediately: true,
      scheduledDate: null,
    );

    _titleController.addListener(_updateLessonData);
    _descriptionController.addListener(_updateLessonData);
    _loadEducatorData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recordingTimer?.cancel();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _loadEducatorData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _educatorGrade = await _lessonService.getEducatorGrade(user.id);
        _availableSubjects = await _lessonService.getEducatorSubjects(user.id);

        setState(() {
          _lessonData = _lessonData.copyWith(
            grade: _educatorGrade,
            subject:
                _availableSubjects.isNotEmpty ? _availableSubjects.first : '',
          );
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading educator data: $e');
      }
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _updateLessonData() {
    setState(() {
      _lessonData = _lessonData.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
      );
    });
  }

  // ========== VIDEO HANDLING METHODS ==========

  Future<void> _uploadVideo() async {
    try {
      setState(() {
        _uploadError = null;
        _hasVideoError = false;
        _webVideoBytes = null;
        _webVideoFileName = null;
      });

      // REPLACED FilePicker with ImagePicker
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (kIsWeb) {
          // Web-specific handling
          final fileBytes = await pickedFile.readAsBytes();
          _temporaryVideoPath = pickedFile.name;
          _webVideoBytes = fileBytes;
          _webVideoFileName = pickedFile.name;

          setState(() {
            _lessonData = _lessonData.copyWith(
              videoFile: null,
              durationText: 'Calculating duration...',
            );
            _isExtractingDuration = true;
          });

          final estimatedDuration =
              await _estimateVideoDurationWeb(fileBytes.length);

          setState(() {
            _lessonData = _lessonData.copyWith(
              videoDuration: estimatedDuration,
              durationText: _formatDurationForDisplay(estimatedDuration),
            );
            _isExtractingDuration = false;
          });

          await _initializeWebVideoPreview(fileBytes, pickedFile.name);
          _showFileSelected(pickedFile);
        } else {
          // Mobile handling
          final videoFile = File(pickedFile.path);
          _temporaryVideoPath = pickedFile.path;

          final ext = path.extension(pickedFile.name).toLowerCase();
          final validExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];

          if (!validExtensions.contains(ext)) {
            throw Exception(
                'Invalid video format. Supported: MP4, MOV, AVI, MKV, WEBM');
          }

          // Validate file size for mobile
          final fileSize = await videoFile.length();
          if (fileSize > 500 * 1024 * 1024) {
            throw Exception('Video file too large. Maximum size is 500MB.');
          }

          setState(() {
            _lessonData = _lessonData.copyWith(
              videoFile: videoFile,
              durationText: 'Calculating duration...',
            );
            _isExtractingDuration = true;
          });

          final duration = await _lessonService.getVideoDuration(videoFile);

          setState(() {
            _lessonData = _lessonData.copyWith(
              videoDuration: duration,
              durationText: _formatDurationForDisplay(duration),
            );
            _isExtractingDuration = false;
          });

          await _initializeVideoPlayer(videoFile: videoFile);
          _showFileSelected(pickedFile);
        }
      }
    } catch (e) {
      _handleUploadError(e);
    }
  }

  Future<void> _initializeWebVideoPreview(
      Uint8List videoBytes, String fileName) async {
    try {
      setState(() {
        _isVideoLoading = true;
        _hasVideoError = false;
      });

      await _videoPlayerController?.dispose();
      _chewieController?.dispose();

      final blobUrl = await _createBlobUrl(videoBytes);

      if (blobUrl != null) {
        _videoPlayerController = VideoPlayerController.network(blobUrl);
        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: _primaryColor,
            handleColor: _primaryColor,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey.withOpacity(0.5),
          ),
          placeholder: Container(
            color: Colors.grey.shade900,
            child: const Center(
              child:
                  Icon(Icons.videocam_rounded, color: Colors.white, size: 50),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Container(
              color: Colors.grey.shade900,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: _errorColor, size: 50),
                    const SizedBox(height: 16),
                    const Text(
                      'Error playing video preview',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Video will be available after upload',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );

        setState(() {
          _isVideoLoading = false;
        });
      } else {
        throw Exception('Could not create video preview');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Web video preview error: $e');
      }
      setState(() {
        _isVideoLoading = false;
        _hasVideoError = true;
      });
    }
  }

  Future<String?> _createBlobUrl(Uint8List bytes) async {
    try {
      // For mobile app, return null or handle differently
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating blob URL: $e');
      }
      return null;
    }
  }

  Future<void> _initializeVideoPlayer(
      {File? videoFile, String? videoUrl}) async {
    try {
      setState(() {
        _isVideoLoading = true;
        _hasVideoError = false;
      });

      await _videoPlayerController?.dispose();
      _chewieController?.dispose();

      if (videoFile != null) {
        _videoPlayerController = VideoPlayerController.file(videoFile);
      } else if (videoUrl != null && videoUrl.isNotEmpty) {
        _videoPlayerController = VideoPlayerController.network(videoUrl);
      } else {
        throw Exception('No video source provided');
      }

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: _primaryColor,
          handleColor: _primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.withOpacity(0.5),
        ),
        placeholder: Container(
          color: Colors.grey.shade900,
          child: const Center(
            child: Icon(Icons.videocam_rounded, color: Colors.white, size: 50),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.grey.shade900,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: _errorColor, size: 50),
                  const SizedBox(height: 16),
                  const Text(
                    'Error playing video',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      setState(() {
        _isVideoLoading = false;
      });
    } catch (e) {
      setState(() {
        _isVideoLoading = false;
        _hasVideoError = true;
      });
    }
  }

  Future<Duration> _estimateVideoDurationWeb(int fileSizeBytes) async {
    // More accurate estimation based on typical video bitrates
    // Average bitrate: ~1-2 Mbps for standard quality, ~4-8 Mbps for HD
    const averageBitrateMbps = 2.0; // Conservative estimate
    final fileSizeBits = fileSizeBytes * 8;
    final durationSeconds = fileSizeBits / (averageBitrateMbps * 1000000);

    final estimatedMinutes = (durationSeconds / 60).ceil();
    return Duration(minutes: estimatedMinutes.clamp(1, 180));
  }

  String _formatDurationForDisplay(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // ========== UPLOAD METHODS ==========

  Future<String> _uploadVideoToServer({
    required String lessonId,
    required String educatorId,
    required File videoFile,
    required Function(double) onProgress,
  }) async {
    try {
      final videoUrl = await _lessonService.uploadVideo(
        lessonId: lessonId,
        educatorId: educatorId,
        videoFile: videoFile,
        onProgress: onProgress,
      );
      return videoUrl;
    } catch (e) {
      throw Exception('Failed to upload video: ${e.toString()}');
    }
  }

  Future<void> _saveLesson() async {
    if (!_canSaveLesson) return;

    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadError = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final lessonId = await _lessonService.createLesson(
        title: _lessonData.title,
        subject: _lessonData.subject,
        grade: _lessonData.grade,
        durationSeconds: _lessonData.videoDuration?.inSeconds ?? 2700,
        educatorId: user.id,
        description: _lessonData.description,
        isPublished: _lessonData.publishImmediately,
        scheduledPublish: _lessonData.scheduledDate,
      );

      String? videoUrl;
      String? thumbnailUrl;

      if (_lessonData.videoFile != null || _webVideoBytes != null) {
        if (kIsWeb) {
          if (_webVideoBytes != null) {
            videoUrl = await _lessonService.uploadVideoWebFromList(
              lessonId: lessonId,
              educatorId: user.id,
              fileBytes: _webVideoBytes!,
              fileName: _webVideoFileName ?? 'video.mp4',
              onProgress: (progress) {
                if (mounted) {
                  setState(() => _uploadProgress = progress * 0.7);
                }
              },
            );
          }
        } else {
          videoUrl = await _uploadVideoToServer(
            lessonId: lessonId,
            educatorId: user.id,
            videoFile: _lessonData.videoFile!,
            onProgress: (progress) {
              if (mounted) {
                setState(() => _uploadProgress = progress * 0.7);
              }
            },
          );

          if (!kIsWeb) {
            final currentUser = Supabase.instance.client.auth.currentUser;
            if (currentUser != null) {
              thumbnailUrl = await _lessonService.generateThumbnail(
                lessonId: lessonId,
                educatorId: currentUser.id,
                videoFile: _lessonData.videoFile!,
              );
            }
          }
        }

        await _lessonService.updateLessonUrls(
          lessonId: lessonId,
          videoUrl: videoUrl ?? '',
          thumbnailUrl: thumbnailUrl ?? '',
        );

        setState(() {
          _lessonData = _lessonData.copyWith(videoUrl: videoUrl);
        });

        if (videoUrl != null) {
          await _initializeVideoPlayer(videoUrl: videoUrl);
        }
      }

      _showSuccessAndNavigate();
    } catch (e) {
      _handleUploadError(e);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _handleUploadError(dynamic error) {
    String errorMessage = 'An unexpected error occurred';

    if (error is SocketException) {
      errorMessage = 'Network connection failed. Please check your internet.';
    } else if (error is HttpException) {
      errorMessage = 'Server error. Please try again later.';
    } else if (error is FormatException) {
      errorMessage = 'Invalid file format. Please try another video.';
    } else {
      errorMessage = error.toString();
    }

    setState(() {
      _uploadError = errorMessage;
      _isUploading = false;
      _isExtractingDuration = false;
    });

    _showError(errorMessage);
  }

  // ========== VIDEO PLAYBACK METHODS ==========

  void _playVideoFullScreen() {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Video Preview'),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            backgroundColor: Colors.black,
            body: Center(
              child: Chewie(controller: _chewieController!),
            ),
          ),
        ),
      );
    } else if (kIsWeb && _webVideoBytes != null && _hasVideoError) {
      _showInfo(
          'Video preview is not available for this file. The video will play after saving.');
    } else {
      _showInfo('Please wait while the video loads...');
    }
  }

  Widget _buildVideoPlayer() {
    if (_isVideoLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Loading video preview...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasVideoError) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_rounded, color: _primaryColor, size: 50),
              const SizedBox(height: 16),
              const Text(
                'Video Selected',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                kIsWeb ? 'Ready to upload' : 'Tap Play Video to preview',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 8),
                Text(
                  'Preview not available',
                  style: TextStyle(color: _warningColor, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Chewie(controller: _chewieController!),
        ),
      );
    }

    if (_lessonData.videoFile != null ||
        _lessonData.videoUrl != null ||
        _webVideoBytes != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: _successColor, size: 50),
              const SizedBox(height: 8),
              const Text(
                'Video Selected',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                kIsWeb ? 'Ready to upload' : 'Tap Play Video to preview',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              if (_webVideoFileName != null) ...[
                const SizedBox(height: 8),
                Text(
                  _webVideoFileName!,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_rounded, color: Colors.white, size: 50),
            SizedBox(height: 8),
            Text(
              'No video selected',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ========== RECORDING METHODS ==========

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingTime += const Duration(seconds: 1);
        });
      }
    });
  }

  void _openCamera() {
    if (kIsWeb) {
      _showError(
          'Camera recording is not supported on web. Please use the upload option.');
      return;
    }
    setState(() {
      _isRecording = true;
      _recordingTime = const Duration();
    });
    _startRecordingTimer();
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
  }

  void _pauseRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeRecording() {
    setState(() {
      _isPaused = false;
    });
    _startRecordingTimer();
  }

  // ========== UI BUILDING METHODS ==========

  bool get _canSaveLesson {
    return _titleController.text.isNotEmpty &&
        _lessonData.subject.isNotEmpty &&
        _lessonData.grade.isNotEmpty &&
        (_lessonData.videoFile != null || _webVideoBytes != null) &&
        !_isLoadingData;
  }

  double get _lessonProgress {
    double progress = 0.0;
    if (_titleController.text.isNotEmpty) progress += 0.3;
    if (_lessonData.grade.isNotEmpty) progress += 0.3;
    if (_lessonData.videoFile != null || _webVideoBytes != null) {
      progress += 0.4;
    }
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 32),
          _buildSectionHeader(
              'Lesson Information', Icons.info_outline_rounded, _infoColor),
          const SizedBox(height: 20),
          _buildLessonInfoForm(),
          const SizedBox(height: 32),
          _buildSectionHeader(
              'Video Content', Icons.videocam_rounded, _primaryColor),
          const SizedBox(height: 20),
          _buildVideoOptions(),
          const SizedBox(height: 32),
          _buildSectionHeader(
              'Target Audience', Icons.people_alt_rounded, _successColor),
          const SizedBox(height: 20),
          _buildGradeSelection(),
          const SizedBox(height: 32),
          _buildSectionHeader(
              'Scheduling', Icons.schedule_rounded, _warningColor),
          const SizedBox(height: 20),
          _buildSchedulingOptions(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLessonInfoForm() {
    return Column(
      children: [
        _buildFormField(
          label: 'Lesson Title',
          hintText: 'Advanced Calculus: Derivatives & Applications',
          controller: _titleController,
          icon: Icons.title_rounded,
          maxLines: 1,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'Description (Optional)',
          hintText: 'Describe the lesson content and learning objectives...',
          controller: _descriptionController,
          icon: Icons.description_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSubjectDropdown()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getBorderColor()),
                      color: _getCardColor(),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer_rounded,
                            color: _getTextColor().withOpacity(0.5), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _lessonData.durationText,
                            style: TextStyle(
                              color: _isExtractingDuration
                                  ? _primaryColor
                                  : _getTextColor().withOpacity(
                                      _lessonData.videoFile != null ||
                                              _webVideoBytes != null
                                          ? 1.0
                                          : 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_isExtractingDuration)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoOptions() {
    return Column(
      children: [
        if (_lessonData.videoFile != null ||
            _lessonData.videoUrl != null ||
            _webVideoBytes != null)
          _buildVideoPreview(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildVideoOptionCard(
                'Upload Video',
                Icons.upload_rounded,
                _infoColor,
                'Choose from gallery',
                onTap: _uploadVideo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVideoOptionCard(
                'Record Video',
                Icons.videocam_rounded,
                _errorColor,
                'Use camera',
                onTap: _openCamera,
              ),
            ),
          ],
        ),
        if (_isRecording) ...[
          const SizedBox(height: 20),
          _buildRecordingInterface(),
        ],
      ],
    );
  }

  Widget _buildVideoPreview() {
    String fileName = 'Video Selected';
    if (_webVideoFileName != null) {
      fileName = _webVideoFileName!;
    } else if (_temporaryVideoPath != null) {
      fileName = path.basename(_temporaryVideoPath!);
    } else if (_lessonData.videoFile != null) {
      fileName = path.basename(_lessonData.videoFile!.path);
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBorderColor().withOpacity(0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _isUploading ? _buildUploadProgress() : _buildVideoPlayer(),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getCardColor(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBorderColor()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.videocam_rounded, color: _primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(
                        color: _getTextColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _successColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_lessonData.videoDuration != null)
                Row(
                  children: [
                    Icon(Icons.timer_rounded,
                        color: _getTextColor().withOpacity(0.6), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatDurationForDisplay(_lessonData.videoDuration!),
                      style: TextStyle(
                        color: _getTextColor().withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _playVideoFullScreen,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _uploadVideo,
                    icon: const Icon(Icons.replay_rounded),
                    tooltip: 'Replace Video',
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_uploadError != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _errorColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: _errorColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _uploadError!,
                    style: TextStyle(color: _errorColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: _uploadProgress > 0 ? _uploadProgress : null,
            color: _primaryColor,
            strokeWidth: 4,
          ),
          const SizedBox(height: 16),
          Text(
            '${(_uploadProgress * 100).round()}%',
            style: TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Uploading video...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeSelection() {
    if (_isLoadingData) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircularProgressIndicator(color: _primaryColor),
            const SizedBox(width: 12),
            Text(
              'Loading your grade...',
              style: TextStyle(color: _getTextColor()),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Teaching Grade',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _successColor.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _successColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.school_rounded, color: _successColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _educatorGrade,
                      style: TextStyle(
                        color: _getTextColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Automatically assigned from your profile',
                      style: TextStyle(
                        color: _getTextColor().withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded, color: _successColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    if (_isLoadingData) {
      return _buildFormField(
        label: 'Subject',
        hintText: 'Loading your subjects...',
        controller: TextEditingController(),
        icon: Icons.category_rounded,
        maxLines: 1,
        enabled: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Subject',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBorderColor()),
          ),
          child: DropdownButtonFormField<String>(
            value: _lessonData.subject.isNotEmpty ? _lessonData.subject : null,
            items: _availableSubjects.map((String subject) {
              return DropdownMenuItem<String>(
                value: subject,
                child: Text(subject),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _lessonData = _lessonData.copyWith(subject: newValue);
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Select your subject',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              prefixIcon: Icon(Icons.category_rounded,
                  color: _getTextColor().withOpacity(0.5)),
            ),
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulingOptions() {
    return Column(
      children: [
        _buildScheduleOption(
          'Publish Immediately',
          'Lesson will be available to students right away',
          Icons.publish_rounded,
          _lessonData.publishImmediately,
          () => _scheduleLesson(immediate: true),
        ),
        const SizedBox(height: 16),
        _buildScheduleOption(
          'Schedule for Later',
          'Set a specific date and time for publication',
          Icons.schedule_rounded,
          !_lessonData.publishImmediately,
          () => _scheduleLesson(immediate: false),
        ),
      ],
    );
  }

  Widget _buildScheduleOption(String title, String subtitle, IconData icon,
      bool isSelected, VoidCallback onTap) {
    return Material(
      color: isSelected ? _primaryColor.withAlpha(20) : _getCardColor(),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _primaryColor : _getBorderColor(),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? _primaryColor : _getCardColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : _getTextColor().withOpacity(0.6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTextColor().withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _primaryColor : _getBorderColor(),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: _primaryColor,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingInterface() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _isPaused ? 'RECORDING PAUSED' : '● RECORDING LIVE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _isPaused ? _warningColor : _errorColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDuration(_recordingTime),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'RobotoMono',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                Icons.stop_rounded,
                'Stop',
                _errorColor,
                onTap: _stopRecording,
                size: 60,
              ),
              const SizedBox(width: 20),
              _buildControlButton(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                _isPaused ? 'Resume' : 'Pause',
                _warningColor,
                onTap: _isPaused ? _resumeRecording : _pauseRecording,
                size: 60,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, Color color,
      {required VoidCallback onTap, double size = 50}) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: size * 0.4),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: FloatingActionButton.extended(
        onPressed: _canSaveLesson && !_isUploading ? _saveLesson : null,
        backgroundColor:
            _canSaveLesson && !_isUploading ? _primaryColor : Colors.grey,
        foregroundColor: Colors.white,
        icon: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Text(_isUploading ? 'Saving...' : 'Save Lesson'),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCardColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getBorderColor()),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: _getTextColor(), size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Create New Lesson',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _getTextColor(),
          letterSpacing: -0.3,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.help_outline_rounded,
                  color: _primaryColor, size: 20),
            ),
            onPressed: _showHelp,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _lessonProgress,
              backgroundColor: _getBorderColor(),
              color: _primaryColor,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lesson Creation Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getTextColor().withOpacity(0.7),
              ),
            ),
            Text(
              '${(_lessonProgress * 100).round()}% Complete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
          ],
        ),
        if (!_canSaveLesson && _lessonProgress >= 0.6) ...[
          const SizedBox(height: 8),
          Text(
            'Complete all required fields to save',
            style: TextStyle(
              color: _errorColor,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _getTextColor(),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: _getTextColor().withOpacity(0.4),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _getBorderColor()),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _getBorderColor()),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            filled: true,
            fillColor:
                enabled ? _getCardColor() : _getCardColor().withOpacity(0.5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon:
                Icon(icon, color: _getTextColor().withOpacity(0.5), size: 20),
          ),
          style: TextStyle(
            color: _getTextColor(),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoOptionCard(
      String title, IconData icon, Color color, String subtitle,
      {VoidCallback? onTap}) {
    return Material(
      color: _getCardColor(),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBorderColor().withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: _getTextColor().withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() => Colors.white;
  Color _getCardColor() => Colors.grey.shade100;
  Color _getBorderColor() => Colors.grey.shade300;
  Color _getTextColor() => Colors.black;

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Text('Need help creating your lesson? Contact support.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _scheduleLesson({required bool immediate}) {
    setState(() {
      _lessonData = _lessonData.copyWith(
        publishImmediately: immediate,
        scheduledDate:
            immediate ? null : DateTime.now().add(const Duration(days: 1)),
      );
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showFileSelected(XFile file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${file.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lesson saved successfully!'),
        backgroundColor: _successColor,
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context);
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: _errorColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _infoColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
