import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:signsync_academy/core/constants/supabase_config.dart';
import 'pages/shared/splash_screen.dart' as splash;
import 'pages/shared/welcome_screen.dart' as welcome;
import 'pages/educator/auth_screen.dart';
import 'pages/student/auth_screen.dart';
import 'pages/parent/auth_screen.dart';
import 'pages/educator/dashboard.dart';
import 'pages/student/dashboard.dart';
import 'pages/parent/dashboard.dart';
import 'pages/student/lesson_viewer.dart';
import 'pages/student/homework_submission.dart';
import 'pages/student/live_session.dart';
import 'pages/educator/lesson_creation.dart';
import 'pages/educator/video_editor.dart';
import 'pages/educator/content_management.dart';
import 'pages/educator/review_submissions.dart';
import 'pages/educator/live_sessions_manage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ INITIALIZE SUPABASE FIRST - CORRECT PARAMETERS
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    // Session persistence is now enabled by default
  );

  runApp(const SignSyncApp());
}

class SignSyncApp extends StatelessWidget {
  const SignSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignSync Academy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const AuthWrapper(), // ✅ Use auth wrapper instead of direct splash
      debugShowCheckedModeBanner: false,
      routes: {
        // Shared Routes
        '/welcome': (context) => const welcome.WelcomeScreen(),

        // Authentication Routes
        '/educator/auth': (context) => const EducatorAuthScreen(),
        '/student/auth': (context) => const StudentAuthScreen(),
        '/parent/auth': (context) => const ParentAuthScreen(),

        // Dashboard Routes
        '/educator/dashboard': (context) => const EducatorDashboard(),
        '/student/dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return StudentDashboard(
            studentData: args ?? {},
          );
        },
        '/parent/dashboard': (context) => const ParentDashboard(),

        // Student Learning Routes
        '/student/lesson': (context) => const LessonViewer(),
        '/student/homework': (context) => const HomeworkSubmission(),
        '/student/live-session': (context) => const LiveSession(),

        // Educator Content Creation Routes
        '/educator/create-lesson': (context) => const LessonCreation(),
        '/educator/video-editor': (context) => const VideoEditor(
              filePath: '',
            ),

        // Educator Management Routes
        '/educator/content-management': (context) => const ContentManagement(),
        '/educator/review-submissions': (context) => const ReviewSubmissions(),
        '/educator/live-sessions-manage': (context) =>
            const LiveSessionsManage(),
      },
    );
  }
}

// ✅ AUTH WRAPPER TO CHECK EXISTING SESSIONS
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingAuth = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _safeCheckAuthState();
  }

  void _safeCheckAuthState() async {
    try {
      // ✅ Wait for Supabase to fully initialize
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // ✅ Now safely check for current user
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });

        if (currentUser != null) {
          // User is already logged in - go to dashboard
          _redirectToDashboard(currentUser);
        } else {
          // No session - go to splash screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const splash.SplashScreen()),
          );
        }
      }
    } catch (e) {
      // If Supabase fails, show error and go to splash screen
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
          _errorMessage =
              'Unable to connect. Please check your internet connection.';
        });

        // After showing error, proceed to splash screen
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const splash.SplashScreen()),
          );
        }
      }
    }
  }

  void _redirectToDashboard(User user) async {
    try {
      // Get user profile with role and student info
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role, student_info')
          .eq('id', user.id)
          .maybeSingle();

      final role = profile?['role'] ?? 'student';
      final studentInfo =
          profile?['student_info'] as Map<String, dynamic>? ?? {};

      if (mounted) {
        switch (role) {
          case 'educator':
            Navigator.pushReplacementNamed(context, '/educator/dashboard');
            break;
          case 'student':
            // ✅ FIX: Pass required studentData parameter using named route with arguments
            Navigator.pushReplacementNamed(
              context,
              '/student/dashboard',
              arguments: {
                'student_info': studentInfo,
                'user_id': user.id,
              },
            );
            break;
          case 'parent':
            Navigator.pushReplacementNamed(context, '/parent/dashboard');
            break;
          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const splash.SplashScreen()),
            );
        }
      }
    } catch (e) {
      // If error getting profile, go to splash screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const splash.SplashScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF667EEA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
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
              child: const Icon(
                Icons.handshake,
                color: Colors.white,
                size: 60,
              ),
            ),

            const SizedBox(height: 40),

            // Loading or Error State
            if (_isCheckingAuth) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Loading SignSync Academy...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else if (_errorMessage != null) ...[
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 60),

            // App Name
            const Text(
              'SignSync Academy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'South African Sign Language Learning',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
