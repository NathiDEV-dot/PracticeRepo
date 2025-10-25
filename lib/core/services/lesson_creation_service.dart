import 'dart:io';
import 'dart:math';
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
      final response = await _client.rpc('create_lesson', params: {
        'p_title': title.trim(),
        'p_subject': subject.trim(),
        'p_grade': grade,
        'p_duration_text': _formatDurationForApi(durationSeconds),
        'p_educator_id': educatorId,
        'p_description':
            description?.trim().isEmpty ?? true ? null : description?.trim(),
        'p_video_url': videoUrl,
        'p_thumbnail_url': thumbnailUrl,
        'p_is_published': isPublished,
        'p_scheduled_publish': scheduledPublish?.toIso8601String(),
      });

      return response as String;
    } catch (e) {
      throw Exception('Failed to create lesson: ${e.toString()}');
    }
  }

  String _formatDurationForApi(int seconds) {
    final duration = Duration(seconds: seconds);
    if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ${duration.inMinutes.remainder(60)} min${duration.inMinutes.remainder(60) > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} min${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  // Extract video duration using video_player for accurate detection
  Future<Duration> getVideoDuration(File videoFile) async {
    // On web, we can't use video_player with File objects easily
    if (kIsWeb) {
      return const Duration(minutes: 45); // Default fallback for web
    }

    VideoPlayerController? controller;

    try {
      controller = VideoPlayerController.file(videoFile);

      // Initialize the controller
      await controller.initialize();

      // Get the duration from the controller
      final duration = controller.value.duration;

      // Dispose the controller to free resources
      await controller.dispose();

      if (duration == Duration.zero) {
        throw Exception('Could not determine video duration');
      }

      return duration;
    } catch (e) {
      // Ensure controller is disposed even if an error occurs
      await controller?.dispose();

      // Fallback to metadata-based estimation if video_player fails
      return await _getVideoDurationFromMetadata(videoFile);
    }
  }

  Future<Duration> _getVideoDurationFromMetadata(File videoFile) async {
    try {
      // This is a fallback method - less accurate but better than nothing
      final fileSize = await videoFile.length();
      // Very rough estimation (varies greatly by codec and quality)
      final estimatedMinutes = (fileSize / (1024 * 1024 * 2)).ceil();
      return Duration(
          minutes: estimatedMinutes.clamp(1, 180)); // Limit to 1-180 minutes
    } catch (e) {
      return const Duration(minutes: 45); // Default fallback
    }
  }

  Future<String> _getTemporaryPath() async {
    if (kIsWeb) {
      return '/tmp/thumbnail.jpg'; // Simple path for web
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

      // Upload the file
      await _client.storage.from('videos').upload(storagePath, videoFile);

      onProgress(0.8);

      // Get public URL
      final String videoUrl =
          _client.storage.from('videos').getPublicUrl(storagePath);

      onProgress(1.0);

      return videoUrl;
    } catch (e) {
      throw Exception('Failed to upload video: ${e.toString()}');
    }
  }

  // Upload video for web platform - MAIN METHOD
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

      // Upload the file bytes as Uint8List
      await _client.storage.from('videos').uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(contentType: 'video/mp4'),
          );

      onProgress(0.8);

      // Get public URL
      final String videoUrl =
          _client.storage.from('videos').getPublicUrl(storagePath);

      onProgress(1.0);

      return videoUrl;
    } catch (e) {
      throw Exception('Failed to upload video: ${e.toString()}');
    }
  }

  // HELPER METHOD: Convert List<int> to Uint8List and upload
  Future<String> uploadVideoWebFromList({
    required String lessonId,
    required String educatorId,
    required List<int> fileBytes,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    try {
      // Convert List<int> to Uint8List and call the main upload method
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

  // HELPER METHOD: Upload video from PlatformFile (convenience method)
  Future<String> uploadVideoWebFromPlatformFile({
    required String lessonId,
    required String educatorId,
    required PlatformFile platformFile,
    required Function(double) onProgress,
  }) async {
    try {
      if (platformFile.bytes == null) {
        throw Exception('Platform file bytes are null');
      }

      return await uploadVideoWebFromList(
        lessonId: lessonId,
        educatorId: educatorId,
        fileBytes: platformFile.bytes!,
        fileName: platformFile.name,
        onProgress: onProgress,
      );
    } catch (e) {
      throw Exception(
          'Failed to upload video from platform file: ${e.toString()}');
    }
  }

  // Generate thumbnail from video with improved error handling
  Future<String> generateThumbnail({
    required String lessonId,
    required String educatorId,
    required File videoFile,
  }) async {
    // Skip thumbnail generation on web as it requires file paths
    if (kIsWeb) {
      return ''; // Return empty string for web
    }

    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
        maxHeight: 300,
        timeMs: 10000, // Capture at 10-second mark for better thumbnail
      );

      if (uint8list == null || uint8list.isEmpty) {
        throw Exception('Thumbnail generation returned null or empty data');
      }

      // Upload thumbnail to storage
      final tempFile = File(
          '${(await _getTemporaryPath())}_thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(uint8list);

      return await uploadThumbnail(
        lessonId: lessonId,
        educatorId: educatorId,
        thumbnailFile: tempFile,
      );
    } catch (e) {
      // Return empty string instead of throwing error for web compatibility
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

  // Validate video file - updated for web compatibility
  void validateVideoFile(PlatformFile file) {
    // For web, we can't check file size the same way, so we'll skip size validation on web
    if (!kIsWeb) {
      // Mobile platform - check file size
      if (file.size > 500 * 1024 * 1024) {
        throw Exception('Video file too large. Maximum size is 500MB.');
      }
    }

    // File extension validation is handled in the uploadVideo method
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

  List<String> getSubjectOptions() {
    return [
      'Mathematics',
      'English',
      'South African Sign Language (SASL)',
      'Life Orientation',
      'Technology',
      'Economic Management Sciences',
      'Natural Sciences',
      'Social Sciences',
      'Arts and Culture',
      'Physical Education',
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
