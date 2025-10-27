// ignore_for_file: unnecessary_cast

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all available lessons for students
  Future<List<Map<String, dynamic>>> getAvailableLessons() async {
    try {
      final response = await _supabase.from('lessons').select('''
            *,
            educator:educator_id (
              id,
              full_name,
              avatar_url
            )
          ''').eq('is_published', true).order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch lessons: $e');
    }
  }

  // Get lessons by subject
  Future<List<Map<String, dynamic>>> getLessonsBySubject(String subject) async {
    try {
      final response = await _supabase
          .from('lessons')
          .select('''
            *,
            educator:educator_id (
              id,
              full_name,
              avatar_url
            )
          ''')
          .eq('is_published', true)
          .eq('subject', subject)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch lessons by subject: $e');
    }
  }

  // Get student's progress data
  Future<Map<String, dynamic>> getStudentProgress(String studentId) async {
    try {
      // Get completed lessons count
      final completedResponse = await _supabase
          .from('student_progress')
          .select('lesson_id')
          .eq('student_id', studentId)
          .eq('completed', true);

      final completedCount = completedResponse.length;

      // Get total available lessons count
      final totalResponse =
          await _supabase.from('lessons').select('id').eq('is_published', true);

      final totalCount = totalResponse.length;

      // Calculate progress percentage
      final progressPercentage =
          totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;

      return {
        'completed_lessons': completedCount,
        'total_lessons': totalCount,
        'progress_percentage': progressPercentage,
        'current_streak': 7, // This could be calculated from progress dates
      };
    } catch (e) {
      throw Exception('Failed to fetch student progress: $e');
    }
  }

  // Get recommended lessons for student
  Future<List<Map<String, dynamic>>> getRecommendedLessons(
      String studentId) async {
    try {
      // Get student's completed subjects to recommend similar content
      final progressResponse =
          await _supabase.from('student_progress').select('''
            lessons:lesson_id (
              subject
            )
          ''').eq('student_id', studentId).eq('completed', true);

      final completedSubjects = progressResponse
          .map((item) => item['lessons']['subject'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      // If student has completed lessons, recommend similar subjects
      // Otherwise, return popular lessons
      if (completedSubjects.isNotEmpty) {
        final response = await _supabase
            .from('lessons')
            .select('''
              *,
              educator:educator_id (
                id,
                full_name,
                avatar_url
              )
            ''')
            .eq('is_published', true)
            .inFilter('subject',
                completedSubjects) // Fixed: changed from .in_ to .inFilter
            .order('views', ascending: false)
            .limit(5);

        return (response as List).cast<Map<String, dynamic>>();
      } else {
        // Return popular lessons for new students
        final response = await _supabase
            .from('lessons')
            .select('''
              *,
              educator:educator_id (
                id,
                full_name,
                avatar_url
              )
            ''')
            .eq('is_published', true)
            .order('views', ascending: false)
            .limit(5);

        return (response as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      throw Exception('Failed to fetch recommended lessons: $e');
    }
  }

  // Mark lesson as completed
  Future<void> markLessonCompleted(String studentId, String lessonId) async {
    try {
      await _supabase.from('student_progress').upsert({
        'student_id': studentId,
        'lesson_id': lessonId,
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
        'progress_percentage': 100,
      });
    } catch (e) {
      throw Exception('Failed to mark lesson as completed: $e');
    }
  }

  // Get lesson details by ID
  Future<Map<String, dynamic>> getLessonById(String lessonId) async {
    try {
      final response = await _supabase.from('lessons').select('''
            *,
            educator:educator_id (
              id,
              full_name,
              avatar_url,
              bio
            )
          ''').eq('id', lessonId).single();

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch lesson details: $e');
    }
  }

  // Increment lesson views
  Future<void> incrementLessonViews(String lessonId) async {
    try {
      await _supabase.rpc('increment_views', params: {'lesson_id': lessonId});
    } catch (e) {
      // Silently fail for view increments
      if (kDebugMode) {
        print('Failed to increment views: $e');
      }
    }
  }

  // Search lessons
  Future<List<Map<String, dynamic>>> searchLessons(String query) async {
    try {
      final response = await _supabase
          .from('lessons')
          .select('''
            *,
            educator:educator_id (
              id,
              full_name,
              avatar_url
            )
          ''')
          .eq('is_published', true)
          .or('title.ilike.%$query%,description.ilike.%$query%,subject.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to search lessons: $e');
    }
  }

  // Get student's favorite lessons
  Future<List<Map<String, dynamic>>> getFavoriteLessons(
      String studentId) async {
    try {
      final response = await _supabase.from('student_favorites').select('''
            lessons:lesson_id (
              *,
              educator:educator_id (
                id,
                full_name,
                avatar_url
              )
            )
          ''').eq('student_id', studentId).eq('lessons.is_published', true);

      return response
          .map((item) => item['lessons'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite lessons: $e');
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(
      String studentId, String lessonId, bool isCurrentlyFavorite) async {
    try {
      if (isCurrentlyFavorite) {
        await _supabase
            .from('student_favorites')
            .delete()
            .eq('student_id', studentId)
            .eq('lesson_id', lessonId);
      } else {
        await _supabase.from('student_favorites').insert({
          'student_id': studentId,
          'lesson_id': lessonId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Get lesson progress for a specific student and lesson
  Future<Map<String, dynamic>?> getLessonProgress(
      String studentId, String lessonId) async {
    try {
      final response = await _supabase
          .from('student_progress')
          .select('*')
          .eq('student_id', studentId)
          .eq('lesson_id', lessonId)
          .maybeSingle();

      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Update lesson progress (for videos, quizzes, etc.)
  Future<void> updateLessonProgress(
    String studentId,
    String lessonId,
    double progressPercentage,
    bool completed,
  ) async {
    try {
      await _supabase.from('student_progress').upsert({
        'student_id': studentId,
        'lesson_id': lessonId,
        'progress_percentage': progressPercentage,
        'completed': completed,
        'last_accessed_at': DateTime.now().toIso8601String(),
        if (completed) 'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update lesson progress: $e');
    }
  }
}
