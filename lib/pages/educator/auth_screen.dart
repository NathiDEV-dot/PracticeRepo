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
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: const Text('Educator Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                label: 'First Name',
                hintText: 'Enter your first name',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your first name' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _surnameController,
                label: 'Last Name',
                hintText: 'Enter your last name',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your last name' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _gradesController,
                label: 'Grades You Teach',
                hintText: 'e.g., Grade 4-7, Grade 8-9',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter grades' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _subjectsController,
                label: 'Subjects You Teach',
                hintText: 'e.g., English, Mathematics, SASL',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter subjects' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _schoolController,
                label: 'School Name',
                hintText: 'Enter your school name',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter school name' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'School Email',
                hintText: 'your.name@school.edu.za',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter school email';
                  if (!value.contains('@')) return 'Please enter a valid email';
                  // Remove the strict .edu.za validation for testing
                  return null;
                },
              ),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 30,
          ),
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
        const SizedBox(height: 8),
        Text(
          'Please provide your professional information to create your educator account',
          style: TextStyle(
            fontSize: 16,
            color: _getTextColor().withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: _getTextColor().withOpacity(0.5)),
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
              borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
            ),
            filled: true,
            fillColor: _getCardColor(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: TextStyle(color: _getTextColor()),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Create Educator Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      showDialog(context: context, builder: (context) => _buildSuccessDialog());
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
            Icon(Icons.check_circle, color: const Color(0xFF4CAF50), size: 60),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(
                    context,
                    '/educator/dashboard',
                  );
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

  Color _getBackgroundColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0F0F1E)
        : const Color(0xFFF8FAFF);
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
        ? const Color(0xFF333344)
        : const Color(0xFFE2E8F0);
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
