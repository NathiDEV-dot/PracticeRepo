// lib/pages/student/auth_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:signsync_academy/core/services/auth_service.dart';

class StudentAuthScreen extends StatefulWidget {
  const StudentAuthScreen({super.key});

  @override
  State<StudentAuthScreen> createState() => _StudentAuthScreenState();
}

class _StudentAuthScreenState extends State<StudentAuthScreen> {
  final TextEditingController _studentCodeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _loginAsStudent() async {
    if (_studentCodeController.text.isEmpty) {
      _showError('Please enter your student code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final studentData = await _authService.studentLogin(
        _studentCodeController.text.trim().toUpperCase(),
      );

      if (studentData != null) {
        final studentInfo = studentData['student_info'];
        _showSuccess('Welcome back, ${studentInfo['first_name']}!');

        // Navigate to student dashboard with data
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/student/dashboard',
            arguments: studentData,
          );
        }
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Back button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Color(0xFF4CAF50),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        const Text(
                          'Student Portal',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        const Text(
                          'Enter your student code to access your classes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Student Code Input
                        TextFormField(
                          controller: _studentCodeController,
                          decoration: InputDecoration(
                            labelText: 'Student Code',
                            hintText: 'TOD001',
                            prefixIcon: const Icon(Icons.badge_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.characters,
                          onFieldSubmitted: (_) => _loginAsStudent(),
                        ),
                        const SizedBox(height: 20),

                        // Help text
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Use your assigned student code (e.g., TOD001, TOD002, etc.)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF4CAF50)),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _loginAsStudent,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    'Enter Classroom',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),

                        // Demo hint
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'Demo Student Codes:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'TOD001 (Grade 1) to TOD096 (Grade 12)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _studentCodeController.dispose();
    super.dispose();
  }
}
