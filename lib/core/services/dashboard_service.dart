import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get comprehensive educator data for dashboard
  Future<Map<String, dynamic>> getEducatorData(String educatorId) async {
    try {
      // Get educator basic info
      final educatorResponse = await _client
          .from('profiles')
          .select('id, first_name, last_name, grade, role')
          .eq('id', educatorId)
          .eq('role', 'educator')
          .single();

      // Get educator's classes with student counts
      final classesResponse = await _client
          .from('classes')
          .select('id, subject, grade, educator_id')
          .eq('educator_id', educatorId);

      // Get all enrollments for this educator's classes
      final classIds =
          classesResponse.map<String>((c) => c['id'] as String).toList();
      final enrollmentsResponse = classIds.isNotEmpty
          ? await _client
              .from('class_enrollments')
              .select('class_id, student_code')
              .inFilter('class_id', classIds)
          : [];

      // Get student details for all enrolled students
      final studentCodes = enrollmentsResponse
          .map<String>((e) => e['student_code'] as String)
          .toSet()
          .toList();
      final studentsResponse = studentCodes.isNotEmpty
          ? await _client
              .from('profiles')
              .select('id, first_name, last_name, grade')
              .inFilter('id', studentCodes)
          : [];

      // Get educator's lessons
      final lessonsResponse = await _client
          .from('lessons')
          .select('*')
          .eq('educator_id', educatorId)
          .order('created_at', ascending: false);

      // Calculate lesson statistics
      final totalLessons = lessonsResponse.length;
      final publishedLessons = lessonsResponse
          .where((lesson) => lesson['is_published'] == true)
          .length;

      // Process the data
      return _processEducatorData(
        educatorResponse,
        classesResponse,
        enrollmentsResponse,
        studentsResponse,
        lessonsResponse,
        totalLessons,
        publishedLessons,
      );
    } catch (e) {
      debugPrint('Error getting educator data: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _processEducatorData(
    Map<String, dynamic> educator,
    List<dynamic> classes,
    List<dynamic> enrollments,
    List<dynamic> students,
    List<dynamic> lessons,
    int totalLessons,
    int publishedLessons,
  ) {
    // Create student map for easy lookup
    final studentMap = <String, Map<String, dynamic>>{};
    for (final student in students) {
      studentMap[student['id']] = {
        'id': student['id'],
        'first_name': student['first_name'],
        'last_name': student['last_name'],
        'grade': student['grade'],
      };
    }

    // Process classes and enrollments
    final classesByGrade = <String, List<Map<String, dynamic>>>{};
    final allStudents = <Map<String, dynamic>>[];
    final seenStudents = <String>{};
    final subjects = <String>{};

    int totalStudents = 0;
    final uniqueStudents = <String>{};

    for (final classData in classes) {
      final grade = classData['grade'];
      final subject = classData['subject'];
      subjects.add(subject);

      // Get enrollments for this class
      final classEnrollments =
          enrollments.where((e) => e['class_id'] == classData['id']).toList();

      totalStudents += classEnrollments.length;
      for (final enrollment in classEnrollments) {
        uniqueStudents.add(enrollment['student_code']);
      }

      // Add to classes by grade
      if (!classesByGrade.containsKey(grade)) {
        classesByGrade[grade] = [];
      }

      classesByGrade[grade]!.add({
        'class_id': classData['id'],
        'subject': subject,
        'student_count': classEnrollments.length,
        'students': classEnrollments
            .map((e) {
              final studentCode = e['student_code'];
              return studentMap[studentCode];
            })
            .where((s) => s != null)
            .toList(),
      });

      // Build unique student list
      for (final enrollment in classEnrollments) {
        final studentCode = enrollment['student_code'];
        if (!seenStudents.contains(studentCode) &&
            studentMap.containsKey(studentCode)) {
          seenStudents.add(studentCode);
          allStudents.add(studentMap[studentCode]!);
        }
      }
    }

    // Sort students by name
    allStudents.sort((a, b) {
      final nameA = '${a['first_name']} ${a['last_name']}';
      final nameB = '${b['first_name']} ${b['last_name']}';
      return nameA.compareTo(nameB);
    });

    return {
      'educator': educator,
      'stats': {
        'total_classes': classes.length,
        'total_students': uniqueStudents.length,
        'published_lessons': publishedLessons,
        'total_lessons': totalLessons,
      },
      'classes_by_grade': classesByGrade,
      'subjects': subjects.toList(),
      'grades_taught': classesByGrade.keys.toList(),
      'all_students': allStudents,
      'recent_lessons': lessons.take(5).toList(),
    };
  }

  // Get educator's recent activity
  Future<List<Map<String, dynamic>>> getRecentActivity(
      String educatorId) async {
    try {
      // Get recent homework submissions
      final submissionsResponse = await _client
          .from('homework_submissions')
          .select('*, lessons(title), profiles(first_name, last_name)')
          .eq('lessons.educator_id', educatorId)
          .order('submitted_at', ascending: false)
          .limit(5);

      // Get upcoming live sessions
      final now = DateTime.now();
      final sessionsResponse = await _client
          .from('live_sessions')
          .select('*')
          .eq('educator_id', educatorId)
          .gte('scheduled_time', now.toIso8601String())
          .order('scheduled_time', ascending: true)
          .limit(3);

      // Combine and format activities
      final activities = <Map<String, dynamic>>[];

      // Add submission activities
      for (final submission in submissionsResponse) {
        activities.add({
          'type': 'submission',
          'title':
              '${submission['profiles']['first_name']} ${submission['profiles']['last_name']} submitted ${submission['lessons']['title']}',
          'time':
              _formatTimeDifference(DateTime.parse(submission['submitted_at'])),
          'icon': Icons.assignment_turned_in_rounded,
          'color': const Color(0xFF4ADE80),
        });
      }

      // Add session activities
      for (final session in sessionsResponse) {
        activities.add({
          'type': 'session',
          'title': 'Live session "${session['title']}" starting soon',
          'time':
              _formatTimeDifference(DateTime.parse(session['scheduled_time'])),
          'icon': Icons.live_tv_rounded,
          'color': const Color(0xFFEF4444),
        });
      }

      // Sort by time
      activities.sort((a, b) => b['time'].compareTo(a['time']));

      return activities.take(5).toList();
    } catch (e) {
      debugPrint('Error getting recent activity: $e');
      return [];
    }
  }

  String _formatTimeDifference(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
