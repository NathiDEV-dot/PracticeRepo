// lib/pages/parent/auth_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:signsync_academy/core/services/auth_service.dart';

class ParentAuthScreen extends StatefulWidget {
  const ParentAuthScreen({super.key});

  @override
  State<ParentAuthScreen> createState() => _ParentAuthScreenState();
}

class _ParentAuthScreenState extends State<ParentAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentCodeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final parentData =
            await _authService.parentLogin(_studentCodeController.text.trim());

        if (parentData != null) {
          _showSuccess('Access granted! Loading student information...');

          // Navigate to parent dashboard
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/parent/dashboard',
              arguments: parentData,
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
  }

  void _fillDemoCode() {
    setState(() {
      _studentCodeController.text = 'TOD001';
    });
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF667EEA),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Parent Access',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getCardColor(),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 32),

                          // Student Code Field
                          _buildTextFieldWithIcon(
                            controller: _studentCodeController,
                            label: 'Student Code',
                            hintText: 'Enter student code (e.g., TOD001)',
                            icon: Icons.person_rounded,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter student code';
                              }
                              if (!value.toUpperCase().startsWith('TOD')) {
                                return 'Please enter a valid student code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Demo Code Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _fillDemoCode,
                              icon: const Icon(Icons.visibility_rounded,
                                  size: 18),
                              label: const Text('Fill Demo Student Code'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF667EEA),
                                side:
                                    const BorderSide(color: Color(0xFF667EEA)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Info Text
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Enter your child\'s student code to access their academic information',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: _getTextColor().withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Submit Button
                          _buildSubmitButton(),

                          // Student Codes Info
                          const SizedBox(height: 30),
                          _buildStudentCodesInfo(),
                        ],
                      ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.family_restroom_rounded,
              color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          'Parent Portal',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Track your child\'s academic progress and attendance',
          style: TextStyle(
            fontSize: 16,
            color: _getTextColor().withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            onFieldSubmitted: (_) => _submitForm(),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: _getHintColor()),
              prefixIcon: Icon(icon, color: _getIconColor()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _getBorderColor()),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _getBorderColor()),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
              filled: true,
              fillColor: _getTextFieldBackgroundColor(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: TextStyle(color: _getTextColor(), fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Access Student Info',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildStudentCodesInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_rounded, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text(
                'Student Codes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use student codes starting with TOD (e.g., TOD001, TOD002, etc.)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildStudentChip('TOD001 - Lihle Mthembu (Gr1)'),
              _buildStudentChip('TOD009 - Ayanda Zulu (Gr2)'),
              _buildStudentChip('TOD017 - Inez Viljoen (Gr3)'),
              _buildStudentChip('TOD025 - Qhawe Khumalo (Gr4)'),
              _buildStudentChip('TOD033 - Yanga Mbatha (Gr5)'),
              _buildStudentChip('TOD041 - Gail Botha (Gr6)'),
              _buildStudentChip('TOD049 - Oliver Cohen (Gr7)'),
              _buildStudentChip('TOD057 - Wesley Moloi (Gr8)'),
              _buildStudentChip('TOD065 - Elaine de Wet (Gr9)'),
              _buildStudentChip('TOD073 - Michael Mthembu (Gr10)'),
              _buildStudentChip('TOD081 - Ulrich Zulu (Gr11)'),
              _buildStudentChip('TOD089 - Candice Viljoen (Gr12)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.blue[800],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Color methods
  Color _getTextFieldBackgroundColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2D2D3E)
        : const Color(0xFFF0F4F8);
  }

  Color _getTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF2D3748);
  }

  Color _getCardColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E2E)
        : Colors.white;
  }

  Color _getBorderColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3D3D4E)
        : const Color(0xFFE2E8F0);
  }

  Color _getHintColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF888888)
        : const Color(0xFF718096);
  }

  Color _getIconColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF888888)
        : const Color(0xFF718096);
  }

  @override
  void dispose() {
    _studentCodeController.dispose();
    super.dispose();
  }
}
