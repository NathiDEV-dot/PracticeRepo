import 'dart:io';
import 'dart:math';
// ignore: unnecessary_import
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';

class LessonCreationService {
  final SupabaseClient _client;

  LessonCreationService() : _client = Supabase.instance.client;

  // Create lesson in database
  Future<String> createLesson({
    required String title,
    required String subject,
    required String grade,
    required int durationSeconds,
    required String educatorId,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    bool isPublished = false,
    DateTime? scheduledPublish,
  }) async {
    try {
      final response = await _client
          .from('lessons')
          .insert({
            'title': title.trim(),
            'subject': subject.trim(),
            'grade': grade,
            'duration':
                durationSeconds, // Use 'duration' instead of 'duration_seconds'
            'educator_id': educatorId,
            'description': description?.trim().isEmpty ?? true
                ? null
                : description?.trim(),
            'video_url': videoUrl,
            'thumbnail_url': thumbnailUrl,
            'is_published': isPublished,
            'scheduled_publish': scheduledPublish?.toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating lesson: $e');
      }
      throw Exception('Failed to create lesson: ${e.toString()}');
    }
  }

  // Fetch educator's subjects from database
  Future<List<String>> getEducatorSubjects(String educatorId) async {
    try {
      // Try to get subjects from profiles table first
      final profileResponse = await _client
          .from('profiles')
          .select('subject_specialization')
          .eq('id', educatorId)
          .eq('role', 'educator')
          .single();

      final subjectSpecialization =
          profileResponse['subject_specialization'] as String?;

      if (subjectSpecialization != null && subjectSpecialization.isNotEmpty) {
        return [subjectSpecialization];
      }

      // Fallback to default subjects
      return ['Mathematics', 'English', 'Science', 'History'];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching educator subjects: $e');
      }
      return ['Mathematics', 'English', 'Science', 'History'];
    }
  }

  // Fetch educator's grade from database - CORRECTED VERSION
  Future<String> getEducatorGrade(String educatorId) async {
    try {
      debugPrint('🔍 Fetching grade for educator: $educatorId');

      // Query the profiles table where educators actually exist
      final response = await _client
          .from('profiles')
          .select('grade, first_name, last_name')
          .eq('id', educatorId)
          .eq('role', 'educator')
          .single();

      final grade = response['grade'] as String?;
      final firstName = response['first_name'] as String?;
      final lastName = response['last_name'] as String?;

      debugPrint('📊 Found educator: $firstName $lastName - Grade: $grade');

      if (grade == null || grade.isEmpty) {
        debugPrint('⚠️ No grade found for educator, using fallback');
        // Don't use hardcoded fallback - throw error instead
        throw Exception('No grade assigned to educator $firstName $lastName');
      }

      return grade;
    } catch (e) {
      debugPrint('❌ Error fetching educator grade: $e');
      // Don't return hardcoded grade - rethrow the error
      throw Exception('Failed to fetch educator grade: ${e.toString()}');
    }
  }

  // Extract video duration using video_player for accurate detection
  Future<Duration> getVideoDuration(File videoFile) async {
    if (kIsWeb) {
      return const Duration(minutes: 45);
    }

    VideoPlayerController? controller;

    try {
      controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      final duration = controller.value.duration;
      await controller.dispose();

      if (duration == Duration.zero) {
        throw Exception('Could not determine video duration');
      }

      return duration;
    } catch (e) {
      await controller?.dispose();
      return await _extractDurationWithFFmpeg(videoFile);
    }
  }

  Future<Duration> _extractDurationWithFFmpeg(File videoFile) async {
    try {
      final fileSize = await videoFile.length();
      final estimatedMinutes = (fileSize / (1024 * 1024)).ceil();
      return Duration(minutes: estimatedMinutes.clamp(1, 180));
    } catch (e) {
      return const Duration(minutes: 45);
    }
  }

  Future<String> _getTemporaryPath() async {
    if (kIsWeb) {
      return '/tmp/thumbnail.jpg';
    }
    final tempDir = Directory.systemTemp;
    return '${tempDir.path}/thumbnail.jpg';
  }

  // Upload video to storage
  Future<String> uploadVideo({
    required String lessonId,
    required String educatorId,
    required File videoFile,
    required Function(double) onProgress,
  }) async {
    try {
      final videoFileName =
          'video_${DateTime.now().millisecondsSinceEpoch}${kIsWeb ? '.mp4' : path.extension(videoFile.path)}';
      final storagePath = '$educatorId/$lessonId/$videoFileName';

      onProgress(0.2);

      await _client.storage.from('videos').upload(storagePath, videoFile);

      onProgress(0.8);

      final String videoUrl =
          _client.storage.from('videos').getPublicUrl(storagePath);

      onProgress(1.0);

      return videoUrl;
    } catch (e) {
      throw Exception('Failed to upload video: ${e.toString()}');
    }
  }

  // Upload video for web platform
  Future<String> uploadVideoWeb({
    required String lessonId,
    required String educatorId,
    required Uint8List fileBytes,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    try {
      final videoFileName =
          'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final storagePath = '$educatorId/$lessonId/$videoFileName';

      onProgress(0.2);

      await _client.storage.from('videos').uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(contentType: 'video/mp4'),
          );

      onProgress(0.8);

      final String videoUrl =
          _client.storage.from('videos').getPublicUrl(storagePath);

      onProgress(1.0);

      return videoUrl;
    } catch (e) {
      throw Exception('Failed to upload video: ${e.toString()}');
    }
  }

  // Helper method for web upload
  Future<String> uploadVideoWebFromList({
    required String lessonId,
    required String educatorId,
    required List<int> fileBytes,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    try {
      return await uploadVideoWeb(
        lessonId: lessonId,
        educatorId: educatorId,
        fileBytes: Uint8List.fromList(fileBytes),
        fileName: fileName,
        onProgress: onProgress,
      );
    } catch (e) {
      throw Exception('Failed to upload video from list: ${e.toString()}');
    }
  }

  // Generate thumbnail from video
  Future<String> generateThumbnail({
    required String lessonId,
    required String educatorId,
    required File videoFile,
  }) async {
    if (kIsWeb) {
      return '';
    }

    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
        maxHeight: 300,
        timeMs: 10000,
      );

      if (uint8list == null || uint8list.isEmpty) {
        throw Exception('Thumbnail generation returned null or empty data');
      }

      final tempFile = File(
          '${(await _getTemporaryPath())}_thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(uint8list);

      return await uploadThumbnail(
        lessonId: lessonId,
        educatorId: educatorId,
        thumbnailFile: tempFile,
      );
    } catch (e) {
      return '';
    }
  }

  Future<String> uploadThumbnail({
    required String lessonId,
    required String educatorId,
    required File thumbnailFile,
  }) async {
    try {
      final thumbnailFileName =
          'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '$educatorId/$lessonId/$thumbnailFileName';

      await _client.storage.from('thumbnails').upload(
            storagePath,
            thumbnailFile,
          );

      return _client.storage.from('thumbnails').getPublicUrl(storagePath);
    } catch (e) {
      throw Exception('Failed to upload thumbnail: ${e.toString()}');
    }
  }

  // Update lesson with file URLs
  Future<void> updateLessonUrls({
    required String lessonId,
    required String videoUrl,
    required String thumbnailUrl,
  }) async {
    try {
      await _client.from('lessons').update({
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', lessonId);
    } catch (e) {
      throw Exception('Failed to update lesson URLs: ${e.toString()}');
    }
  }

  // Validate video file
  void validateVideoFile(PlatformFile file) {
    if (!kIsWeb) {
      if (file.size > 500 * 1024 * 1024) {
        throw Exception('Video file too large. Maximum size is 500MB.');
      }
    }
  }

  String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  List<String> getGradeOptions() {
    return [
      'Grade 1',
      'Grade 2',
      'Grade 3',
      'Grade 4',
      'Grade 5',
      'Grade 6',
      'Grade 7',
      'Grade 8',
      'Grade 9',
      'Grade 10',
      'Grade 11',
      'Grade 12'
    ];
  }

  // Utility method to format duration for display
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
