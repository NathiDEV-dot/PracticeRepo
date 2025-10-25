// ignore_for_file: deprecated_member_use, avoid_print, unused_element

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
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
  final TextEditingController _subjectController =
      TextEditingController(text: 'Mathematics');

  // UI State only
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;
  String? _temporaryVideoPath;
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingTime = const Duration();
  bool _isExtractingDuration = false;
  Timer? _recordingTimer;

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
      subject: _subjectController.text,
      grade: '',
      durationText: 'Duration will be auto-detected',
      videoFile: null,
      publishImmediately: true,
      scheduledDate: null,
    );

    _titleController.addListener(_updateLessonData);
    _descriptionController.addListener(_updateLessonData);
    _subjectController.addListener(_updateLessonData);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _updateLessonData() {
    setState(() {
      _lessonData = _lessonData.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        subject: _subjectController.text,
      );
    });
  }

  // ========== VIDEO HANDLING METHODS ==========

  Future<void> _uploadVideo() async {
    try {
      setState(() => _uploadError = null);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        if (kIsWeb) {
          // Web platform - handle bytes directly
          if (file.bytes == null) {
            throw Exception('Unable to access video file on web');
          }

          // Store the filename for web uploads
          _temporaryVideoPath = file.name;

          setState(() {
            _lessonData = _lessonData.copyWith(
              videoFile: null, // Can't create File object on web
              durationText: 'Calculating duration...',
            );
            _isExtractingDuration = true;
          });

          // For web, estimate duration based on file size
          final estimatedDuration =
              await _estimateVideoDurationWeb(file.bytes!.length);

          setState(() {
            _lessonData = _lessonData.copyWith(
              videoDuration: estimatedDuration,
              durationText: _formatDurationForDisplay(estimatedDuration),
            );
            _isExtractingDuration = false;
          });

          _showFileSelected(file);
        } else {
          // Mobile platform - check if path is available
          if (file.path == null) {
            throw Exception('Unable to access video file path');
          }

          // Use the non-null path with null assertion
          final videoFile = File(file.path!);
          _temporaryVideoPath = file.path!;

          // Validate file extension
          final ext = path.extension(file.name).toLowerCase();
          final validExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];

          if (!validExtensions.contains(ext)) {
            throw Exception(
                'Invalid video format. Supported: MP4, MOV, AVI, MKV, WEBM');
          }

          _lessonService.validateVideoFile(file);

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

          _showFileSelected(file);
        }
      }
    } catch (e) {
      _handleUploadError(e);
    }
  }

  Future<Duration> _estimateVideoDurationWeb(int fileSizeBytes) async {
    // Rough estimation for web (varies by codec and quality)
    final estimatedMinutes = (fileSizeBytes / (1024 * 1024 * 2)).ceil();
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
    if (!_lessonData.canSave) return;

    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadError = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // 1. Create lesson record
      final lessonId = await _lessonService.createLesson(
        title: _lessonData.title,
        subject: _lessonData.subject,
        grade: _lessonData.grade,
        durationSeconds:
            _lessonData.videoDuration?.inSeconds ?? 2700, // 45 min default
        educatorId: user.id,
        description: _lessonData.description,
        isPublished: _lessonData.publishImmediately,
        scheduledPublish: _lessonData.scheduledDate,
      );

      // 2. Upload video if exists
      String? videoUrl;
      String? thumbnailUrl;

      if (_lessonData.videoFile != null || _temporaryVideoPath != null) {
        if (kIsWeb) {
          // Handle web upload differently - use the helper method
          final result = await FilePicker.platform.pickFiles(
            type: FileType.video,
            allowMultiple: false,
          );

          if (result != null && result.files.isNotEmpty) {
            final file = result.files.single;

            // Use the helper method that handles PlatformFile directly
            videoUrl = await _lessonService.uploadVideoWebFromPlatformFile(
              lessonId: lessonId,
              educatorId: user.id,
              platformFile: file,
              onProgress: (progress) {
                if (mounted) {
                  setState(() => _uploadProgress = progress * 0.7);
                }
              },
            );
          }
        } else {
          // Mobile upload (existing code)
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

          // 3. Generate and upload thumbnail (skip on web)
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

        // 4. Update lesson with URLs
        await _lessonService.updateLessonUrls(
          lessonId: lessonId,
          videoUrl: videoUrl ?? '',
          thumbnailUrl: thumbnailUrl ?? '',
        );
      }

      // Success
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
    // Show message that camera recording is not available on web
    if (kIsWeb) {
      _showError(
          'Camera recording is not supported on web. Please use the upload option.');
      return;
    }

    // Implement camera functionality for mobile
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
    // TODO: Implement actual camera recording stop and file handling
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
            Expanded(
              child: _buildFormField(
                label: 'Subject',
                hintText: 'Mathematics',
                controller: _subjectController,
                icon: Icons.category_rounded,
                maxLines: 1,
              ),
            ),
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
                                              _temporaryVideoPath != null
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
        // Show video preview if we have any video reference
        if (_lessonData.videoFile != null || _temporaryVideoPath != null)
          _buildVideoPreview(),
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
    final bool hasVideo =
        _lessonData.videoFile != null || _temporaryVideoPath != null;
    final fileSize =
        _lessonData.videoFile != null ? _lessonData.videoFile!.lengthSync() : 0;

    // Get the filename for display
    String fileName = 'Video Selected';
    if (_temporaryVideoPath != null) {
      fileName = path.basename(_temporaryVideoPath!);
    } else if (_lessonData.videoFile != null) {
      fileName = path.basename(_lessonData.videoFile!.path);
    }

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor().withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              color: _isUploading
                  ? _primaryColor.withAlpha(10)
                  : _primaryColor.withAlpha(25),
              child: _isUploading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _uploadProgress > 0 ? _uploadProgress : null,
                          color: _primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(_uploadProgress * 100).round()}%',
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_rounded,
                            size: 60, color: _getTextColor().withOpacity(0.3)),
                        const SizedBox(height: 8),
                        Text(
                          fileName,
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_lessonData.videoDuration != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _formatDurationForDisplay(
                                _lessonData.videoDuration!),
                            style: TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                        if (kIsWeb) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Web Upload - Ready to Save',
                            style: TextStyle(
                              color: _primaryColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            if (!kIsWeb && fileSize > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _lessonService.formatFileSize(fileSize),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: _successColor, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Selected: $fileName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_uploadError != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _errorColor.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _uploadError!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Grade',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _lessonService.getGradeOptions().map((grade) {
            final isSelected = _lessonData.grade == grade;
            return ChoiceChip(
              label: Text(grade),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _lessonData =
                      _lessonData.copyWith(grade: selected ? grade : '');
                });
              },
              backgroundColor: _getCardColor(),
              selectedColor: _primaryColor.withAlpha(50),
              labelStyle: TextStyle(
                color: isSelected ? _primaryColor : _getTextColor(),
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? _primaryColor : _getBorderColor(),
                  width: isSelected ? 2 : 1,
                ),
              ),
            );
          }).toList(),
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
        onPressed: _lessonData.canSave && !_isUploading ? _saveLesson : null,
        backgroundColor:
            _lessonData.canSave && !_isUploading ? _primaryColor : Colors.grey,
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

  // ========== HELPER METHODS ==========

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

  void _showFileSelected(PlatformFile file) {
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

  // ========== UI COMPONENTS ==========

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
              value: _lessonData.progress,
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
              '${(_lessonData.progress * 100).round()}% Complete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
          ],
        ),
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
            fillColor: _getCardColor(),
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
}
