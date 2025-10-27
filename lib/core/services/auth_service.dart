// lib/core/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // EDUCATOR: Sign up with pre-verified accounts
  Future<AuthResponse?> educatorSignUp(String email, String password) async {
    try {
      debugPrint('🔄 Attempting educator signup: $email');

      // Check if educator exists in pre_verified_users
      final preVerifiedResponse = await _client
          .from('pre_verified_users')
          .select()
          .eq('email', email)
          .eq('role', 'educator')
          .maybeSingle();

      if (preVerifiedResponse == null) {
        throw Exception('Email not found in pre-verified educators list.');
      }

      // Check if pre-verified user is already used
      if (preVerifiedResponse['is_used'] == true) {
        throw Exception(
            'Educator account already exists. Please sign in instead.');
      }

      // Sign up with Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': 'educator',
          'first_name': preVerifiedResponse['first_name'],
          'last_name': preVerifiedResponse['last_name'],
          'grade': preVerifiedResponse['grade'],
          'school_name': preVerifiedResponse['school_name'],
        },
      );

      if (authResponse.user == null) {
        if (authResponse.user?.identities?.isEmpty ?? true) {
          throw Exception(
              'Educator account already exists. Please sign in instead.');
        }
        throw Exception('Signup failed. Please try again.');
      }

      // Mark pre-verified user as used
      await _client
          .from('pre_verified_users')
          .update({'is_used': true}).eq('email', email);

      debugPrint(
          '✅ Educator signup successful for: ${preVerifiedResponse['first_name']} ${preVerifiedResponse['last_name']}');
      return authResponse;
    } catch (e) {
      debugPrint('❌ Educator signup error: $e');

      if (e.toString().contains('User already registered') ||
          e.toString().contains('already exists') ||
          e.toString().contains('identity_id')) {
        throw Exception(
            'Educator account already exists. Please sign in instead.');
      } else {
        throw Exception(
            'Signup failed: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  // EDUCATOR: Login with existing accounts
  Future<AuthResponse?> educatorLogin(String email, String password) async {
    try {
      debugPrint('🔄 Attempting educator login: $email');

      // Sign in with Supabase Auth
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Invalid email or password');
      }

      // Verify educator has a profile
      final educatorProfile = await _client
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .eq('role', 'educator')
          .maybeSingle();

      if (educatorProfile == null) {
        await _client.auth.signOut();
        throw Exception('Educator profile not found');
      }

      debugPrint(
          '✅ Educator login successful: ${educatorProfile['first_name']} ${educatorProfile['last_name']}');
      return authResponse;
    } catch (e) {
      debugPrint('❌ Educator login error: $e');

      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Invalid email or password');
      } else if (e.toString().contains('Email not confirmed')) {
        throw Exception('Please verify your email address');
      } else {
        throw Exception(
            'Educator login failed: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  // STUDENT: Simplified login with student code only
  Future<Map<String, dynamic>?> studentLogin(String studentCode) async {
    try {
      debugPrint('🔄 Attempting student login with code: $studentCode');

      final preVerifiedResponse = await _client
          .from('pre_verified_users')
          .select()
          .eq('student_code', studentCode)
          .eq('role', 'student')
          .maybeSingle();

      if (preVerifiedResponse == null) {
        throw Exception('Student code not found in our records');
      }

      final classEnrollments =
          await _client.from('class_enrollments').select('''
            class_id,
            classes (
              id,
              grade,
              subject,
              educator_id,
              profiles!classes_educator_id_fkey (
                first_name,
                last_name
              )
            )
          ''').eq('student_code', studentCode);

      debugPrint('✅ Student login successful');
      return {
        'student_info': preVerifiedResponse,
        'enrollments': classEnrollments,
        'login_type': 'student'
      };
    } catch (e) {
      debugPrint('❌ Student login error: $e');
      throw Exception('Student login failed: $e');
    }
  }

  // PARENT: Login with student code validation
  Future<Map<String, dynamic>?> parentLogin(String studentCode) async {
    try {
      debugPrint('🔄 Attempting parent login for student: $studentCode');

      // Verify student exists
      final studentResponse = await _client
          .from('pre_verified_users')
          .select()
          .eq('student_code', studentCode)
          .eq('role', 'student')
          .maybeSingle();

      if (studentResponse == null) {
        throw Exception('Student code not found in our records');
      }

      final studentData = studentResponse;

      // Get student's classes and progress
      final classEnrollments =
          await _client.from('class_enrollments').select('''
            class_id,
            classes (
              id,
              grade,
              subject,
              educator_id,
              profiles!classes_educator_id_fkey (
                first_name,
                last_name
              )
            )
          ''').eq('student_code', studentCode);

      debugPrint('✅ Parent login successful for student: $studentCode');

      return {
        'student_info': studentData,
        'enrollments': classEnrollments,
        'login_type': 'parent'
      };
    } catch (e) {
      debugPrint('❌ Parent login error: $e');
      throw Exception('Parent login failed: $e');
    }
  }

  // EDUCATOR: Get educator's classes and students
  Future<Map<String, dynamic>?> getEducatorClasses(String educatorId) async {
    try {
      final classes = await _client.from('classes').select('''
            *,
            class_enrollments (
              student_code,
              pre_verified_users!class_enrollments_student_code_fkey (
                first_name,
                last_name,
                grade
              )
            )
          ''').eq('educator_id', educatorId).eq('academic_year', '2024');

      int totalStudents = 0;
      int totalClasses = classes.length;

      for (var classData in classes) {
        final enrollments = classData['class_enrollments'] as List?;
        totalStudents += enrollments?.length ?? 0;
      }

      return {
        'classes': classes,
        'total_classes': totalClasses,
        'total_students': totalStudents,
      };
    } catch (e) {
      debugPrint('❌ Error getting educator classes: $e');
      return null;
    }
  }

  // EDUCATOR: Get educator profile
  Future<Map<String, dynamic>?> getEducatorProfile(String educatorId) async {
    try {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', educatorId)
          .eq('role', 'educator')
          .maybeSingle();

      return profile;
    } catch (e) {
      debugPrint('❌ Error getting educator profile: $e');
      return null;
    }
  }

  // Get student profile by student code
  Future<Map<String, dynamic>?> getStudentProfile(String studentCode) async {
    try {
      final profile = await _client
          .from('pre_verified_users')
          .select()
          .eq('student_code', studentCode)
          .eq('role', 'student')
          .maybeSingle();

      return profile;
    } catch (e) {
      debugPrint('❌ Error getting student profile: $e');
      return null;
    }
  }

  // Get student attendance data
  Future<List<dynamic>?> getStudentAttendance(String studentCode) async {
    try {
      final attendance = await _client.from('attendance').select('''
            *,
            classes (
              subject,
              grade
            )
          ''').eq('student_code', studentCode).order('date', ascending: false);

      return attendance;
    } catch (e) {
      debugPrint('❌ Error getting student attendance: $e');
      return null;
    }
  }

  // COMMON: Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
    debugPrint('✅ User signed out');
  }

  // Check if user is educator (has auth session)
  bool get isEducatorLoggedIn => _client.auth.currentUser != null;

  // Get current user (for educators)
  User? get currentUser => _client.auth.currentUser;

  // Check if user session is valid
  bool get hasValidSession => _client.auth.currentSession != null;

  // Get current session
  Session? get currentSession => _client.auth.currentSession;
}
