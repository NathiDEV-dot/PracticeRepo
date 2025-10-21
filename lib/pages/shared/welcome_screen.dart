import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedRole;
  bool _hasViewedIntro = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  void _viewIntroduction() {
    setState(() {
      _hasViewedIntro = true;
    });

    // Show introduction dialog
    showDialog(
      context: context,
      builder: (context) => _buildIntroductionDialog(),
    );
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _navigateToAuth() {
    if (_selectedRole == 'educator') {
      Navigator.pushReplacementNamed(context, '/educator/auth');
    } else if (_selectedRole == 'student') {
      Navigator.pushReplacementNamed(context, '/student/auth');
    } else if (_selectedRole == 'parent') {
      Navigator.pushReplacementNamed(context, '/parent/auth');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.vertical,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),
                        const SizedBox(height: 32),

                        // Introduction Section
                        _buildIntroductionSection(),
                        const SizedBox(height: 32),

                        // Role Selection
                        _buildRoleSelection(),
                        const SizedBox(height: 32),

                        // Get Started Button
                        _buildGetStartedButton(),
                        const SizedBox(height: 20), // Extra padding at bottom
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
          child: const Icon(Icons.handshake, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome to\nSignSync Academy',
          style: TextStyle(
            fontSize: 28, // Reduced from 32
            fontWeight: FontWeight.w700,
            color: _getTextColor(),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Master South African Sign Language through immersive learning experiences',
          style: TextStyle(
            fontSize: 14, // Reduced from 16
            color: _getTextColor().withAlpha((0.7 * 255).round()),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroductionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Reduced padding
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasViewedIntro ? const Color(0xFF667EEA) : _getBorderColor(),
          width: _hasViewedIntro ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, // Reduced from 56
            height: 48, // Reduced from 56
            decoration: BoxDecoration(
              color: _hasViewedIntro
                  ? const Color(0xFF667EEA)
                      .withAlpha(51) // 0.2 opacity = 51 alpha
                  : const Color(0xFF667EEA)
                      .withAlpha(26), // 0.1 opacity = 26 alpha
              borderRadius: BorderRadius.circular(12),
              border: _hasViewedIntro
                  ? Border.all(color: const Color(0xFF667EEA), width: 2)
                  : null,
            ),
            child: Icon(
              Icons.info_rounded,
              color: _hasViewedIntro
                  ? const Color(0xFF667EEA)
                  : const Color(0xFF667EEA).withAlpha((0.7 * 255).round()),
              size: 24, // Reduced from 32
            ),
          ),
          const SizedBox(width: 12), // Reduced from 16
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Introduction',
                  style: TextStyle(
                    fontSize: 16, // Reduced from 18
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 2), // Reduced from 4
                Text(
                  _hasViewedIntro
                      ? 'Introduction completed ✓'
                      : 'Learn about our platform features',
                  style: TextStyle(
                    fontSize: 12, // Reduced from 14
                    color: _getTextColor().withAlpha((0.6 * 255).round()),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: _getTextColor().withAlpha((0.4 * 255).round()),
            size: 16, // Reduced from 18
          ),
        ],
      ),
    ).clickable(_viewIntroduction);
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Role',
          style: TextStyle(
            fontSize: 18, // Reduced from 20
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 16), // Reduced from 20
        // Use Wrap instead of Row for better responsiveness
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildRoleCard(
              icon: Icons.school_rounded,
              title: 'Educator',
              subtitle: 'Teacher',
              role: 'educator',
              isSelected: _selectedRole == 'educator',
            ),
            _buildRoleCard(
              icon: Icons.person_rounded,
              title: 'Student',
              subtitle: 'Learner',
              role: 'student',
              isSelected: _selectedRole == 'student',
            ),
            _buildRoleCard(
              icon: Icons.family_restroom_rounded,
              title: 'Parent',
              subtitle: 'Guardian',
              role: 'parent',
              isSelected: _selectedRole == 'parent',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String role,
    required bool isSelected,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 72) / 3, // Responsive width
      child: Container(
        height: 120, // Reduced from 140
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667EEA).withAlpha(26) // 0.1 opacity = 26 alpha
              : _getCardColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : _getBorderColor(),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _selectRole(role),
            child: Padding(
              padding: const EdgeInsets.all(16), // Reduced from 20
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36, // Reduced from 40
                    height: 36, // Reduced from 40
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF667EEA)
                          : _getTextColor().withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : _getTextColor().withAlpha((0.7 * 255).round()),
                      size: 18, // Reduced from 20
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, // Reduced from 16
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(),
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced from 4
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11, // Reduced from 12
                      color: _getTextColor().withAlpha((0.6 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    final isEnabled = _hasViewedIntro && _selectedRole != null;

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: isEnabled ? _navigateToAuth : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEnabled ? const Color(0xFF667EEA) : Colors.grey[400],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ), // Reduced from 18
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroductionDialog() {
    return Dialog(
      backgroundColor: _getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA)
                        .withAlpha(26), // 0.1 opacity = 26 alpha
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_rounded,
                    color: Color(0xFF667EEA),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Welcome to SignSync Academy',
                    style: TextStyle(
                      fontSize: 18, // Reduced from 20
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Reduced from 20
            _buildFeatureItem(
              'Interactive SASL Lessons',
              'Learn through video tutorials and practice sessions',
            ),
            const SizedBox(height: 10), // Reduced from 12
            _buildFeatureItem(
              'Progress Tracking',
              'Monitor your learning journey with analytics',
            ),
            const SizedBox(height: 10), // Reduced from 12
            _buildFeatureItem(
              'Expert Educators',
              'Learn from certified SASL instructors',
            ),
            const SizedBox(height: 10), // Reduced from 12
            _buildFeatureItem(
              'Community Support',
              'Connect with other learners',
            ),
            const SizedBox(height: 20), // Reduced from 24
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ), // Reduced from 16
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF4CAF50),
          size: 18, // Reduced from 20
        ),
        const SizedBox(width: 10), // Reduced from 12
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: _getTextColor().withAlpha((0.6 * 255).round()),
                ),
              ),
            ],
          ),
        ),
      ],
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
}

extension Clickable on Widget {
  Widget clickable(VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: this,
      ),
    );
  }
}
