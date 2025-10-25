// lib/core/services/dashboard_service.dart
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
              .inFilter('class_id', classIds) // CHANGED: in_ to inFilter
          : [];

      // Get student details for all enrolled students
      final studentCodes = enrollmentsResponse
          .map<String>((e) => e['student_code'] as String)
          .toSet()
          .toList();
      final studentsResponse = studentCodes.isNotEmpty
          ? await _client
              .from('pre_verified_users')
              .select('student_code, first_name, last_name, grade')
              .inFilter(
                  'student_code', studentCodes) // CHANGED: in_ to inFilter
          : [];

      // Process the data
      return _processEducatorData(
        educatorResponse,
        classesResponse,
        enrollmentsResponse,
        studentsResponse,
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
  ) {
    // Create student map for easy lookup
    final studentMap = <String, Map<String, dynamic>>{};
    for (final student in students) {
      studentMap[student['student_code']] = {
        'student_code': student['student_code'],
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

    // ignore: unused_local_variable
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
        'published_lessons': 0,
        'total_lessons': 0,
      },
      'classes_by_grade': classesByGrade,
      'subjects': subjects.toList(),
      'grades_taught': classesByGrade.keys.toList(),
      'all_students': allStudents,
    };
  }
}
