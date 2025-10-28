import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart';

class ContentManagementService {
  final SupabaseClient _client;

  ContentManagementService() : _client = Supabase.instance.client;

  // Get educator's lessons with all details
  Future<List<Map<String, dynamic>>> getEducatorLessons(
      String educatorId) async {
    try {
      debugPrint('📚 Fetching lessons for educator: $educatorId');

      final response = await _client
          .from('lessons')
          .select('''
            id,
            title,
            subject,
            grade,
            duration,
            video_url,
            thumbnail_url,
            is_published,
            created_at,
            updated_at,
            description
          ''')
          .eq('educator_id', educatorId)
          .order('created_at', ascending: false);

      debugPrint('✅ Found ${response.length} lessons');

      // Process and enhance the data
      final lessons = await _enhanceLessonData(response);
      return lessons;
    } catch (e) {
      debugPrint('❌ Error fetching lessons: $e');
      throw Exception('Failed to load lessons: ${e.toString()}');
    }
  }

  // Get published lessons only (for students/parents view)
  Future<List<Map<String, dynamic>>> getPublishedLessonsByGrade(
      String grade) async {
    try {
      final response = await _client
          .from('lessons')
          .select('''
            id,
            title,
            subject,
            grade,
            duration,
            video_url,
            thumbnail_url,
            created_at,
            description,
            educator:profiles!educator_id(first_name, last_name)
          ''')
          .eq('grade', grade)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return _enhanceLessonData(response);
    } catch (e) {
      debugPrint('❌ Error fetching published lessons: $e');
      throw Exception('Failed to load published lessons: ${e.toString()}');
    }
  }

  // Get lesson analytics (views, student engagement)
  Future<Map<String, dynamic>> getLessonAnalytics(String lessonId) async {
    try {
      // This would typically query an analytics table
      // For now, return mock data or basic stats
      return {
        'total_views': 0,
        'unique_students': 0,
        'completion_rate': 0,
        'average_watch_time': 0,
      };
    } catch (e) {
      debugPrint('❌ Error fetching analytics: $e');
      return {
        'total_views': 0,
        'unique_students': 0,
        'completion_rate': 0,
        'average_watch_time': 0,
      };
    }
  }

  // Update lesson details
  Future<void> updateLesson({
    required String lessonId,
    String? title,
    String? description,
    String? subject,
    bool? isPublished,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (subject != null) updates['subject'] = subject;
      if (isPublished != null) updates['is_published'] = isPublished;

      await _client.from('lessons').update(updates).eq('id', lessonId);

      debugPrint('✅ Lesson $lessonId updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating lesson: $e');
      throw Exception('Failed to update lesson: ${e.toString()}');
    }
  }

  // Delete lesson
  Future<void> deleteLesson(String lessonId) async {
    try {
      await _client.from('lessons').delete().eq('id', lessonId);

      debugPrint('✅ Lesson $lessonId deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting lesson: $e');
      throw Exception('Failed to delete lesson: ${e.toString()}');
    }
  }

  // Get content statistics for dashboard
  Future<Map<String, dynamic>> getContentStats(String educatorId) async {
    try {
      final lessons = await getEducatorLessons(educatorId);

      final totalLessons = lessons.length;
      final publishedLessons =
          lessons.where((lesson) => lesson['is_published'] == true).length;
      final totalDuration =
          lessons.fold(0, (sum, lesson) => sum + (lesson['duration'] as int));
      final totalViews =
          lessons.fold(0, (sum, lesson) => sum + (lesson['views'] as int));

      // Get unique subjects
      final subjects =
          lessons.map((lesson) => lesson['subject'] as String).toSet().toList();

      return {
        'total_videos': totalLessons,
        'published_videos': publishedLessons,
        'draft_videos': totalLessons - publishedLessons,
        'total_duration_minutes': (totalDuration / 60).round(),
        'total_views': totalViews,
        'subjects': subjects,
      };
    } catch (e) {
      debugPrint('❌ Error fetching content stats: $e');
      return {
        'total_videos': 0,
        'published_videos': 0,
        'draft_videos': 0,
        'total_duration_minutes': 0,
        'total_views': 0,
        'subjects': [],
      };
    }
  }

  // Search lessons
  Future<List<Map<String, dynamic>>> searchLessons({
    required String educatorId,
    required String query,
    String? subject,
    String? grade,
  }) async {
    try {
      var request = _client
          .from('lessons')
          .select()
          .eq('educator_id', educatorId)
          .textSearch('title', query);

      if (subject != null && subject.isNotEmpty) {
        request = request.eq('subject', subject);
      }

      if (grade != null && grade.isNotEmpty) {
        request = request.eq('grade', grade);
      }

      final response = await request.order('created_at', ascending: false);
      return _enhanceLessonData(response);
    } catch (e) {
      debugPrint('❌ Error searching lessons: $e');
      return [];
    }
  }

  // Private method to enhance lesson data with additional fields
  Future<List<Map<String, dynamic>>> _enhanceLessonData(
      List<dynamic> lessons) async {
    final enhancedLessons = <Map<String, dynamic>>[];

    for (final lesson in lessons) {
      // Get analytics for each lesson
      final analytics = await getLessonAnalytics(lesson['id'] as String);

      // Format duration for display
      final durationSeconds = lesson['duration'] as int? ?? 0;
      final durationText = _formatDuration(Duration(seconds: durationSeconds));

      // Determine icon and color based on subject
      final subject = lesson['subject'] as String? ?? 'General';
      final iconData = _getSubjectIcon(subject);
      final color = _getSubjectColor(subject);

      enhancedLessons.add({
        'id': lesson['id'],
        'title': lesson['title'],
        'subject': subject,
        'grade': lesson['grade'],
        'duration': durationSeconds,
        'duration_text': durationText,
        'video_url': lesson['video_url'],
        'thumbnail_url': lesson['thumbnail_url'],
        'is_published': lesson['is_published'] ?? false,
        'created_at': lesson['created_at'],
        'description': lesson['description'],
        'views': analytics['total_views'],
        'students': analytics['unique_students'],
        'completion_rate': analytics['completion_rate'],
        'icon': iconData,
        'color': color,
      });
    }

    return enhancedLessons;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  IconData _getSubjectIcon(String subject) {
    final subjectIcons = {
      'Mathematics': Icons.calculate_rounded,
      'Science': Icons.science_rounded,
      'History': Icons.history_rounded,
      'English': Icons.menu_book_rounded,
      'Languages': Icons.language_rounded,
      'Physics': Icons.rocket_launch_rounded,
      'Chemistry': Icons.emoji_objects_rounded,
      'Biology': Icons.psychology_rounded,
      'Geography': Icons.public_rounded,
    };

    return subjectIcons[subject] ?? Icons.play_arrow_rounded;
  }

  Color _getSubjectColor(String subject) {
    final subjectColors = {
      'Mathematics': const Color(0xFF3B82F6),
      'Science': const Color(0xFF10B981),
      'History': const Color(0xFFF59E0B),
      'English': const Color(0xFF8B5CF6),
      'Languages': const Color(0xFFEC4899),
      'Physics': const Color(0xFF06B6D4),
      'Chemistry': const Color(0xFF84CC16),
      'Biology': const Color(0xFFF97316),
      'Geography': const Color(0xFF6366F1),
    };

    return subjectColors[subject] ?? const Color(0xFF6B7280);
  }
}

class VideoPlayerService {
  static Future<void> playVideo(
      BuildContext context, String videoUrl, String title) async {
    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No video available for this lesson'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Initialize video player
      final videoPlayerController = VideoPlayerController.network(videoUrl);
      await videoPlayerController.initialize();

      // Initialize chewie controller
      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF3B82F6),
          handleColor: const Color(0xFF3B82F6),
          backgroundColor: Colors.grey,
          // ignore: deprecated_member_use
          bufferedColor: Colors.grey.withOpacity(0.5),
        ),
        placeholder: Container(
          color: Colors.grey.shade900,
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.grey.shade900,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 50),
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

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show video player
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () {
                      videoPlayerController.dispose();
                      chewieController.dispose();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Chewie(controller: chewieController),
                ),
              ],
            ),
          ),
        );
      }

      // Cleanup
      videoPlayerController.dispose();
      chewieController.dispose();
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
