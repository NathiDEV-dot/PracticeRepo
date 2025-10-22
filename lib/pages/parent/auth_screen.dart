import 'package:flutter/material.dart';

class ParentAuthScreen extends StatefulWidget {
  const ParentAuthScreen({super.key});

  @override
  State<ParentAuthScreen> createState() => _ParentAuthScreenState();
}

class _ParentAuthScreenState extends State<ParentAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();
  String? _childGrade;

  final List<String> _grades = [
    'Grade R',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9800),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
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
                      'Parent Registration',
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

                          // Parent Information
                          _buildSectionHeader('Parent Information'),
                          const SizedBox(height: 20),
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
                            controller: _emailController,
                            label: 'Email Address',
                            hintText: 'your.email@example.com',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Please enter email address';
                              if (!value.contains('@'))
                                return 'Please enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextFieldWithIcon(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hintText: '+27 12 345 6789',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter phone number'
                                : null,
                          ),

                          const SizedBox(height: 32),

                          // Child Information
                          _buildSectionHeader('Child Information'),
                          const SizedBox(height: 20),
                          _buildTextFieldWithIcon(
                            controller: _childNameController,
                            label: "Child's Name",
                            hintText: "Enter your child's name",
                            icon: Icons.child_care,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter child\'s name'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFieldWithIcon(
                            controller: _childAgeController,
                            label: "Child's Age",
                            hintText: 'Enter age',
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Please enter child\'s age';
                              if (int.tryParse(value) == null)
                                return 'Please enter a valid age';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGradeDropdown(),
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
              colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withOpacity(0.3),
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
          'Parent Registration',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Create an account to support your child\'s',
          style: TextStyle(
            fontSize: 16,
            color: _getTextColor().withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'South African Sign Language learning',
          style: TextStyle(
            fontSize: 16,
            color: _getTextColor().withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        ),
      ),
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
              hintStyle: TextStyle(color: _getTextColor().withOpacity(0.5)),
              prefixIcon: Icon(icon, color: _getTextColor().withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFFF9800), width: 2),
              ),
              filled: true,
              fillColor: _getBackgroundColor(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            style: TextStyle(color: _getTextColor(), fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGradeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Child's Grade",
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
          child: DropdownButtonFormField<String>(
            value: _childGrade,
            onChanged: (String? newValue) {
              setState(() {
                _childGrade = newValue;
              });
            },
            validator: (value) =>
                value == null ? 'Please select child\'s grade' : null,
            decoration: InputDecoration(
              hintText: 'Select grade',
              hintStyle: TextStyle(color: _getTextColor().withOpacity(0.5)),
              prefixIcon:
                  Icon(Icons.school, color: _getTextColor().withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFFF9800), width: 2),
              ),
              filled: true,
              fillColor: _getBackgroundColor(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            dropdownColor: _getCardColor(),
            style: TextStyle(color: _getTextColor(), fontSize: 16),
            icon: Icon(Icons.arrow_drop_down,
                color: _getTextColor().withOpacity(0.5)),
            items: _grades.map((String grade) {
              return DropdownMenuItem<String>(
                value: grade,
                child: Text(grade, style: TextStyle(color: _getTextColor())),
              );
            }).toList(),
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
            color: const Color(0xFFFF9800).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Create Parent Account',
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
                color: const Color(0xFFFF9800).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFFFF9800), size: 60),
            ),
            const SizedBox(height: 20),
            Text(
              'Account Created!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your parent account has been created. You can now monitor your child\'s progress and access learning resources.',
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
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/parent/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
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
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFF7FAFC);
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

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    super.dispose();
  }
}
