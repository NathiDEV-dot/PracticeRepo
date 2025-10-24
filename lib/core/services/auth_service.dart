// lib/core/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // STUDENT: One-tap login with student code (no password needed)
  Future<AuthResponse?> studentLogin(String studentCode) async {
    try {
      debugPrint('🔄 Attempting student login with code: $studentCode');

      // 1. Check if student exists in pre_verified_users
      final preVerifiedResponse = await _client
          .from('pre_verified_users')
          .select()
          .eq('student_code', studentCode)
          .eq('role', 'student')
          .eq('is_used', false)
          .maybeSingle();

      if (preVerifiedResponse == null) {
        throw Exception('Student code not found or already used');
      }

      final studentData = preVerifiedResponse;
      debugPrint(
          '✅ Student found: ${studentData['first_name']} ${studentData['last_name']}');

      // 2. Generate unique email and simple password
      final studentEmail = '$studentCode@signsync.academy';
      const studentPassword = 'welcome123'; // Simple universal password

      // 3. Try to sign in first (in case account already exists)
      try {
        final loginResponse = await _client.auth.signInWithPassword(
          email: studentEmail,
          password: studentPassword,
        );

        debugPrint('✅ Student logged in with existing account');
        return loginResponse;
      } catch (signInError) {
        // If sign in fails, create new account
        debugPrint('🔄 Creating new student account...');

        final authResponse = await _client.auth.signUp(
          email: studentEmail,
          password: studentPassword,
        );

        if (authResponse.user == null) {
          throw Exception('Failed to create auth account');
        }

        debugPrint('✅ Auth account created for student');

        // 4. Create profile
        await _client.from('profiles').insert({
          'id': authResponse.user!.id,
          'role': 'student',
          'first_name': studentData['first_name'],
          'last_name': studentData['last_name'],
          'grade': studentData['grade'],
          'school_name': studentData['school_name'],
          'student_code': studentCode,
        });

        // 5. Mark pre-verified user as used
        await _client
            .from('pre_verified_users')
            .update({'is_used': true}).eq('student_code', studentCode);

        debugPrint('✅ Student profile created and marked as used');

        // 6. Automatically log them in
        final finalLoginResponse = await _client.auth.signInWithPassword(
          email: studentEmail,
          password: studentPassword,
        );

        debugPrint('✅ Student logged in successfully');
        return finalLoginResponse;
      }
    } catch (e) {
      debugPrint('❌ Student login error: $e');
      throw Exception('Student login failed: $e');
    }
  }

  // EDUCATOR: Standard email/password registration
  Future<AuthResponse?> educatorSignUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      debugPrint('🔄 Attempting educator signup with email: $email');

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      // 1. Check if educator is pre-verified
      final preVerifiedResponse = await _client
          .from('pre_verified_users')
          .select()
          .eq('email', email)
          .eq('role', 'educator')
          .eq('is_used', false)
          .maybeSingle();

      if (preVerifiedResponse == null) {
        throw Exception(
            'Educator email not found in school records or already registered');
      }

      final educatorData = preVerifiedResponse;
      debugPrint(
          '✅ Educator found: ${educatorData['first_name']} ${educatorData['last_name']}');

      // 2. Try to sign in first (in case account exists)
      try {
        final loginResponse = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        debugPrint('✅ Educator logged in with existing account');
        return loginResponse;
      } catch (signInError) {
        // If sign in fails, create new account
        debugPrint('🔄 Creating new educator account...');

        final authResponse = await _client.auth.signUp(
          email: email,
          password: password,
        );

        if (authResponse.user == null) {
          throw Exception('Failed to create auth account');
        }

        debugPrint('✅ Auth account created for educator');

        // 3. Create profile
        await _client.from('profiles').insert({
          'id': authResponse.user!.id,
          'role': 'educator',
          'first_name': educatorData['first_name'],
          'last_name': educatorData['last_name'],
          'grade': educatorData['grade'],
          'school_name': educatorData['school_name'],
        });

        // 4. Mark as used
        await _client
            .from('pre_verified_users')
            .update({'is_used': true}).eq('email', email);

        debugPrint('✅ Educator profile created and marked as used');
        return authResponse;
      }
    } catch (e) {
      debugPrint('❌ Educator signup error: $e');
      throw Exception('Educator registration failed: $e');
    }
  }

  // EDUCATOR: Login (after initial signup)
  Future<AuthResponse?> educatorLogin(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // PARENT: Registration with student code validation
  Future<AuthResponse?> parentSignUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String studentCode,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      debugPrint('🔄 Attempting parent signup for student code: $studentCode');

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      // 1. Verify student exists in pre_verified_users
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
      debugPrint(
          '✅ Student found: ${studentData['first_name']} ${studentData['last_name']}');

      // 2. Check if parent already exists for this student
      final existingParent = await _client
          .from('profiles')
          .select()
          .eq('linked_student_code', studentCode)
          .eq('role', 'parent')
          .maybeSingle();

      if (existingParent != null) {
        throw Exception('A parent account already exists for this student');
      }

      // 3. Try to sign in first (in case account exists)
      try {
        final loginResponse = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        debugPrint('✅ Parent logged in with existing account');
        return loginResponse;
      } catch (signInError) {
        // If sign in fails, create new account
        debugPrint('🔄 Creating new parent account...');

        // 4. Create auth account
        final authResponse = await _client.auth.signUp(
          email: email,
          password: password,
        );

        if (authResponse.user == null) {
          throw Exception('Failed to create auth account');
        }

        debugPrint('✅ Auth account created for parent');

        // 5. Create parent profile linked to student
        await _client.from('profiles').insert({
          'id': authResponse.user!.id,
          'role': 'parent',
          'first_name': firstName,
          'last_name': lastName,
          'linked_student_code': studentCode,
          'phone_number': phoneNumber,
        });

        debugPrint(
            '✅ Parent profile created and linked to student: $studentCode');
        return authResponse;
      }
    } catch (e) {
      debugPrint('❌ Parent signup error: $e');
      throw Exception('Parent registration failed: $e');
    }
  }

  // PARENT: Login with student code validation
  Future<AuthResponse?> parentLogin({
    required String email,
    required String password,
    required String studentCode,
  }) async {
    try {
      debugPrint('🔄 Attempting parent login for student code: $studentCode');

      // 1. Verify credentials
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Invalid email or password');
      }

      // 2. Verify parent is linked to the student code
      final parentProfile = await _client
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .eq('role', 'parent')
          .eq('linked_student_code', studentCode)
          .maybeSingle();

      if (parentProfile == null) {
        // Sign out since the student code doesn't match
        await _client.auth.signOut();
        throw Exception('Parent account is not linked to this student code');
      }

      // 3. Verify student exists
      final studentExists = await _client
          .from('pre_verified_users')
          .select()
          .eq('student_code', studentCode)
          .eq('role', 'student')
          .maybeSingle();

      if (studentExists == null) {
        throw Exception('Student code not found in our records');
      }

      debugPrint('✅ Parent login successful for student: $studentCode');
      return authResponse;
    } catch (e) {
      debugPrint('❌ Parent login error: $e');
      throw Exception('Parent login failed: $e');
    }
  }

  // PARENT: Get linked student information
  Future<Map<String, dynamic>?> getLinkedStudentInfo(String parentId) async {
    try {
      // Get parent's linked student code
      final parentProfile = await _client
          .from('profiles')
          .select('linked_student_code')
          .eq('id', parentId)
          .eq('role', 'parent')
          .maybeSingle();

      if (parentProfile == null ||
          parentProfile['linked_student_code'] == null) {
        return null;
      }

      final studentCode = parentProfile['linked_student_code'];

      // Get student info from pre_verified_users
      final studentInfo = await _client
          .from('pre_verified_users')
          .select()
          .eq('student_code', studentCode)
          .eq('role', 'student')
          .maybeSingle();

      return studentInfo;
    } catch (e) {
      debugPrint('❌ Error getting linked student info: $e');
      return null;
    }
  }

  // PARENT: Get child's progress and assignments
  Future<Map<String, dynamic>?> getChildProgress(String studentCode) async {
    try {
      // This would join multiple tables to get comprehensive progress
      // For now, return basic student info
      final studentInfo = await _client
          .from('pre_verified_users')
          .select('first_name, last_name, grade, school_name')
          .eq('student_code', studentCode)
          .eq('role', 'student')
          .maybeSingle();

      if (studentInfo == null) {
        return null;
      }

      // TODO: Add actual progress tracking queries here
      // - Completed lessons
      // - Assignment submissions
      // - Grades
      // - Attendance

      return {
        'student_info': studentInfo,
        'completed_lessons': 0, // Placeholder
        'pending_assignments': 0, // Placeholder
        'average_grade': 'N/A', // Placeholder
      };
    } catch (e) {
      debugPrint('❌ Error getting child progress: $e');
      return null;
    }
  }

  // COMMON: Check if user is logged in
  User? get currentUser => _client.auth.currentUser;

  // COMMON: Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
    debugPrint('✅ User signed out');
  }

  // COMMON: Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response =
        await _client.from('profiles').select().eq('id', user.id).maybeSingle();

    return response;
  }
}
