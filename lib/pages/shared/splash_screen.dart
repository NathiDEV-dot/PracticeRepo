import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // ✅ SAFE AUTH CHECK - Wait for Supabase to be ready
    _safeAuthCheck();
  }

  void _safeAuthCheck() async {
    try {
      // Wait for animations and ensure Supabase is ready
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // ✅ SAFE ACCESS: Use Supabase.instance only after ensuring it's initialized
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser != null) {
        _redirectToDashboard(currentUser);
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
      // If Supabase isn't ready, just go to welcome screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  void _redirectToDashboard(User user) async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = profile?['role'] ?? 'student';

      if (mounted) {
        switch (role) {
          case 'educator':
            Navigator.pushReplacementNamed(context, '/educator/dashboard');
            break;
          case 'student':
            Navigator.pushReplacementNamed(context, '/student/dashboard');
            break;
          case 'parent':
            Navigator.pushReplacementNamed(context, '/parent/dashboard');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/welcome');
        }
      }
    } catch (e) {
      // If error, go to welcome screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
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
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main Logo with Scale and Rotation Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withAlpha(102),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Hand shapes forming a circle
                          Center(
                            child: Icon(
                              Icons.handshake,
                              size: 60,
                              color: _getLightIconColor(),
                            ),
                          ),
                          // Animated ring
                          ..._buildAnimatedRings(),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App Name with Fade and Slide Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Text(
                          'SignSync',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: _getTextColor(),
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: _getShadowColor(),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ACADEMY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: _getSecondaryTextColor(),
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Loading Indicator with Fade Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _getProgressBackgroundColor(),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Stack(
                          children: [
                            // Animated progress bar
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Container(
                                  width: 100 * _controller.value,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tagline
                      Text(
                        'South African Sign Language Learning',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getTertiaryTextColor(),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedRings() {
    return [
      // Outer ring
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _RingPainter(
                progress: _controller.value,
                color: _getRingColor(),
              ),
            );
          },
        ),
      ),
    ];
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

  // New method to replace Colors.white.withOpacity(0.9)
  Color _getLightIconColor() {
    return const Color(0xFFE6E6E6); // Equivalent to white.withOpacity(0.9)
  }

  // New method to replace Colors.black.withOpacity(0.1)
  Color _getShadowColor() {
    return const Color(0x1A000000); // Equivalent to black.withOpacity(0.1)
  }

  // New method to replace .withOpacity(0.8) for secondary text
  Color _getSecondaryTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFCCCCCC) // Equivalent to white.withOpacity(0.8)
        : const Color(
            0xFF666666); // Equivalent to Color(0xFF2D3748).withOpacity(0.8)
  }

  // New method to replace .withOpacity(0.7) for tertiary text
  Color _getTertiaryTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFB3B3B3) // Equivalent to white.withOpacity(0.7)
        : const Color(
            0xFF777777); // Equivalent to Color(0xFF2D3748).withOpacity(0.7)
  }

  // New method to replace .withOpacity(0.3) for progress background
  Color _getProgressBackgroundColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF4D4D4D) // Equivalent to white.withOpacity(0.3)
        : const Color(
            0xFFD1D1D1); // Equivalent to Color(0xFF2D3748).withOpacity(0.3)
  }

  // New method to replace Colors.white.withOpacity(0.3) for ring
  Color _getRingColor() {
    return const Color(0xFF4D4D4D); // Equivalent to white.withOpacity(0.3)
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 2;

    // Draw animated ring
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
