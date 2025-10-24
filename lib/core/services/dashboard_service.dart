// lib/core/services/dashboard_service.dart
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>> getEducatorData(String educatorId) async {
    try {
      // Get educator profile
      final educatorProfile =
          await _client.from('profiles').select().eq('id', educatorId).single();

      // Get classes taught by this educator with student details
      final classesResponse = await _client.from('classes').select('''
            *,
            class_enrollments (
              student:profiles!class_enrollments_student_id_fkey (
                first_name,
                last_name,
                student_code,
                grade
              )
            )
          ''').eq('educator_id', educatorId).order('grade').order('subject');

      // Process the data - group by grade
      Map<String, List<Map<String, dynamic>>> classesByGrade = {};
      // ignore: unused_local_variable
      int totalStudents = 0;
      Set<String> uniqueStudents = {};
      Set<String> subjects = {};
      List<String> grades = [];

      for (var classItem in classesResponse) {
        final enrollments = classItem['class_enrollments'] as List;
        final students = enrollments.map((e) => e['student']).toList();

        final classData = {
          'id': classItem['id'],
          'subject': classItem['subject'],
          'student_count': students.length,
          'students': students,
        };

        // Group by grade
        final grade = classItem['grade'];
        if (!classesByGrade.containsKey(grade)) {
          classesByGrade[grade] = [];
          grades.add(grade);
        }
        classesByGrade[grade]!.add(classData);

        // Count unique students across all classes
        for (var student in students) {
          uniqueStudents.add(student['student_code']);
        }

        // Collect subjects
        subjects.add(classItem['subject']);
      }

      // Get lesson statistics
      final lessonStats = await _client
          .from('lessons')
          .select('id, is_published, subject, grade')
          .eq('educator_id', educatorId);

      final publishedLessons =
          lessonStats.where((l) => l['is_published'] == true).length;
      final totalLessons = lessonStats.length;

      // Get lessons by subject
      Map<String, int> lessonsBySubject = {};
      for (var lesson in lessonStats) {
        final subject = lesson['subject'] ?? 'General';
        lessonsBySubject[subject] = (lessonsBySubject[subject] ?? 0) + 1;
      }

      return {
        'educator': educatorProfile,
        'classes_by_grade': classesByGrade,
        'grades_taught': grades,
        'subjects': subjects.toList(),
        'stats': {
          'total_lessons': totalLessons,
          'published_lessons': publishedLessons,
          'total_students': uniqueStudents.length,
          'total_classes': classesResponse.length,
          'lessons_by_subject': lessonsBySubject,
        }
      };
    } catch (e) {
      debugPrint('Error fetching educator data: $e');
      throw Exception('Failed to fetch educator data: $e');
    }
  }
}
