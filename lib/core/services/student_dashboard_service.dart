import 'package:supabase_flutter/supabase_flutter.dart';

class StudentDashboardService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get student's enrolled classes and lessons
  Future<Map<String, dynamic>> getStudentData(String studentId) async {
    try {
      // Get student profile
      final studentResponse = await _client
          .from('profiles')
          .select('id, first_name, last_name, grade')
          .eq('id', studentId)
          .single();

      // Get student's enrolled classes
      final enrollmentsResponse = await _client
          .from('class_enrollments')
          .select('class_id, student_code')
          .eq('student_code', studentId);

      final classIds = enrollmentsResponse
          .map<String>((e) => e['class_id'] as String)
          .toList();

      // Get classes details
      final classesResponse = classIds.isNotEmpty
          ? await _client
              .from('classes')
              .select('id, subject, grade, educator_id')
              .inFilter('id', classIds)
          : [];

      // Get educators for these classes
      final educatorIds = classesResponse
          .map<String>((c) => c['educator_id'] as String)
          .toSet()
          .toList();

      final educatorsResponse = educatorIds.isNotEmpty
          ? await _client
              .from('profiles')
              .select('id, first_name, last_name')
              .inFilter('id', educatorIds)
          : [];

      // Get published lessons for student's grade and subjects
      final subjects = classesResponse
          .map<String>((c) => c['subject'] as String)
          .toSet()
          .toList();

      final lessonsResponse = await _client
          .from('lessons')
          .select('*')
          .eq('grade', studentResponse['grade'])
          .inFilter('subject', subjects.isNotEmpty ? subjects : ['Mathematics'])
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(10);

      // Get today's live sessions
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final liveSessionsResponse = await _client
          .from('live_sessions')
          .select('*')
          .eq('grade', studentResponse['grade'])
          .inFilter('subject', subjects.isNotEmpty ? subjects : ['Mathematics'])
          .gte('scheduled_time', startOfDay.toIso8601String())
          .lt('scheduled_time', endOfDay.toIso8601String())
          .order('scheduled_time', ascending: true);

      return _processStudentData(
        studentResponse,
        classesResponse,
        educatorsResponse,
        lessonsResponse,
        liveSessionsResponse,
      );
    } catch (e) {
      throw Exception('Failed to load student data: $e');
    }
  }

  Map<String, dynamic> _processStudentData(
    Map<String, dynamic> student,
    List<dynamic> classes,
    List<dynamic> educators,
    List<dynamic> lessons,
    List<dynamic> liveSessions,
  ) {
    // Create educator map
    final educatorMap = <String, Map<String, dynamic>>{};
    for (final educator in educators) {
      educatorMap[educator['id']] = {
        'first_name': educator['first_name'],
        'last_name': educator['last_name'],
      };
    }

    // Process lessons with educator names
    final processedLessons = lessons.map((lesson) {
      final educator = educatorMap[lesson['educator_id']];
      return {
        ...lesson,
        'educator_name': educator != null
            ? '${educator['first_name']} ${educator['last_name']}'
            : 'Unknown Educator',
      };
    }).toList();

    // Process live sessions
    final processedSessions = liveSessions.map((session) {
      final educator = educatorMap[session['educator_id']];
      return {
        ...session,
        'educator_name': educator != null
            ? '${educator['first_name']} ${educator['last_name']}'
            : 'Unknown Educator',
      };
    }).toList();

    // Calculate progress (simplified - you can make this more sophisticated)
    final completedLessons =
        lessons.where((lesson) => lesson['completed'] == true).length;
    final progress =
        lessons.isNotEmpty ? (completedLessons / lessons.length) * 100 : 0;

    return {
      'student': student,
      'stats': {
        'total_classes': classes.length,
        'total_lessons': lessons.length,
        'completed_lessons': completedLessons,
        'progress_percentage': progress.round(),
        'today_sessions': liveSessions.length,
      },
      'today_lessons': processedLessons.take(2).toList(),
      'live_sessions': processedSessions,
      'subjects': classes.map((c) => c['subject']).toSet().toList(),
    };
  }

  // Get student's homework assignments
  Future<List<Map<String, dynamic>>> getHomeworkAssignments(
      String studentId) async {
    try {
      final response = await _client
          .from('homework_assignments')
          .select('*, lessons(title, subject)')
          .eq('student_id', studentId)
          .order('due_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load homework: $e');
    }
  }
}
