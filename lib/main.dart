import 'package:flutter/material.dart';
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

void main() {
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
      home: const splash.SplashScreen(),
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
        '/student/dashboard': (context) => const StudentDashboard(),
        '/parent/dashboard': (context) => const ParentDashboard(),

        // Student Learning Routes
        '/student/lesson': (context) => const LessonViewer(),
        '/student/homework': (context) => const HomeworkSubmission(),
        '/student/live-session': (context) => const LiveSession(),

        // Educator Content Creation Routes
        '/educator/create-lesson': (context) => const LessonCreation(),
        '/educator/video-editor': (context) => const VideoEditor(),

        // Educator Management Routes
        '/educator/content-management': (context) => const ContentManagement(),
        '/educator/review-submissions': (context) => const ReviewSubmissions(),
        '/educator/live-sessions-manage': (context) =>
            const LiveSessionsManage(),
      },
    );
  }
}
