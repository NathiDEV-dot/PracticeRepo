// lib/pages/educator/auth_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:signsync_academy/core/services/auth_service.dart';

class EducatorAuthScreen extends StatefulWidget {
  const EducatorAuthScreen({super.key});

  @override
  State<EducatorAuthScreen> createState() => _EducatorAuthScreenState();
}

class _EducatorAuthScreenState extends State<EducatorAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _toggleAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _passwordController.clear();
      _confirmPasswordController.clear();
      _obscurePassword = true;
      _obscureConfirmPassword = true;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        AuthResponse? authResponse;

        if (_isLoginMode) {
          // Login existing educator
          authResponse = await _authService.educatorLogin(
            _emailController.text.trim(),
            _passwordController.text,
          );
        } else {
          // Register new educator
          authResponse = await _authService.educatorSignUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
        }

        if (authResponse != null && authResponse.user != null) {
          _showSuccess(_isLoginMode
              ? 'Welcome back to SignSync Academy!'
              : 'Your educator account has been created successfully!');

          // Navigate to dashboard after a brief delay
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/educator/dashboard');
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
                    Text(
                      _isLoginMode ? 'Educator Login' : 'Educator Registration',
                      style: const TextStyle(
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

                          // Email Field
                          _buildTextFieldWithIcon(
                            controller: _emailController,
                            label: 'School Email',
                            hintText: 'your.name@school.edu.za',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter school email';
                              }
                              if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          _buildTextFieldWithIcon(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'Enter your password',
                            icon: Icons.lock,
                            isPassword: _obscurePassword,
                            textInputAction: _isLoginMode
                                ? TextInputAction.done
                                : TextInputAction.next,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: _getIconColor(),
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                            onFieldSubmitted: (_) {
                              if (_isLoginMode) {
                                _submitForm();
                              }
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password Field (only for signup)
                          if (!_isLoginMode)
                            _buildTextFieldWithIcon(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hintText: 'Confirm your password',
                              icon: Icons.lock_outline,
                              isPassword: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: _getIconColor(),
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                              ),
                              onFieldSubmitted: (_) => _submitForm(),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please confirm password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                          if (!_isLoginMode) const SizedBox(height: 20),

                          // Info Text
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              _isLoginMode
                                  ? 'Use your school email to access your educator account'
                                  : 'Your email must be pre-verified in our school records',
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
                          const SizedBox(height: 20),

                          // Toggle Auth Mode
                          _buildToggleAuthMode(),

                          // Password reset temporarily removed
                          // Will be implemented in future update
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
          _isLoginMode ? 'Educator Login' : 'Educator Registration',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isLoginMode
              ? 'Welcome back to your teaching dashboard'
              : 'Create your professional educator account',
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
    TextInputAction textInputAction = TextInputAction.next,
    bool isPassword = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
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
            obscureText: isPassword,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: _getHintColor()),
              prefixIcon: Icon(icon, color: _getIconColor()),
              suffixIcon: suffixIcon,
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
            : Text(
                _isLoginMode ? 'Sign In' : 'Create Account',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleAuthMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLoginMode ? "Don't have an account?" : 'Already have an account?',
          style: TextStyle(
            color: _getTextColor().withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _isLoading ? null : _toggleAuthMode,
          child: Text(
            _isLoginMode ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
