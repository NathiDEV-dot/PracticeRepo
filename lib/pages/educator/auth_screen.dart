// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class EducatorAuthScreen extends StatefulWidget {
  const EducatorAuthScreen({super.key});

  @override
  State<EducatorAuthScreen> createState() => _EducatorAuthScreenState();
}

class _EducatorAuthScreenState extends State<EducatorAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _gradesController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _schoolController = TextEditingController();
  final _emailController = TextEditingController();

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
                      'Educator Registration',
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
                          _buildTextFieldWithIcon(
                            controller: _nameController,
                            label: 'First Name',
                            hintText: 'Enter your first name',
                            icon: Icons.person,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your first name'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFieldWithIcon(
                            controller: _surnameController,
                            label: 'Last Name',
                            hintText: 'Enter your last name',
                            icon: Icons.person_outline,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your last name'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFieldWithIcon(
                            controller: _gradesController,
                            label: 'Grades You Teach',
                            hintText: 'e.g., Grade 4-7, Grade 8-9',
                            icon: Icons.school,
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter grades' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFieldWithIcon(
                            controller: _subjectsController,
                            label: 'Subjects You Teach',
                            hintText: 'e.g., English, Mathematics, SASL',
                            icon: Icons.menu_book,
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter subjects' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFieldWithIcon(
                            controller: _schoolController,
                            label: 'School Name',
                            hintText: 'Enter your school name',
                            icon: Icons.business,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter school name'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFieldWithIcon(
                            controller: _emailController,
                            label: 'School Email',
                            hintText: 'your.name@school.edu.za',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter school email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          _buildSubmitButton(),
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
          child:
              const Icon(Icons.school_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          'Educator Registration',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Create your professional account',
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
            validator: validator,
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
              fillColor:
                  _getTextFieldBackgroundColor(), // FIXED: Different background for text fields
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
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Create Educator Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => _buildSuccessDialog(),
      );
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: _getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFF4CAF50), size: 60),
            ),
            const SizedBox(height: 20),
            Text(
              'Registration Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your educator account has been created successfully. You can now access all teaching resources.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _getTextColor().withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Container(
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
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(
                      context, '/educator/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: Color methods for better contrast
  Color _getBackgroundColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFF7FAFC);
  }

  Color _getTextFieldBackgroundColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2D2D3E) // Darker than card for contrast
        : const Color(
            0xFFF0F4F8); // Lighter shade for contrast against white card
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
    _nameController.dispose();
    _surnameController.dispose();
    _gradesController.dispose();
    _subjectsController.dispose();
    _schoolController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
