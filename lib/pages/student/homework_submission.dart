// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:signsync_academy/core/services/student_service.dart';
import 'dart:developer' as developer;

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const StudentDashboard({super.key, required this.studentData});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  final StudentService _studentService = StudentService();
  final String _loggerName = 'StudentDashboard';

  // Data states
  Map<String, dynamic> _studentProgress = {};
  List<Map<String, dynamic>> _newestLessons = [];
  List<Map<String, dynamic>> _recommendedLessons = [];
  List<Map<String, dynamic>> _popularLessons = [];
  List<Map<String, dynamic>> _gradeLessons = [];
  List<String> _gradeSubjects = [];
  List<Map<String, dynamic>> _homeworkAssignments = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Student info
  late Map<String, dynamic> _studentInfo;
  late String _studentCode;
  late String _grade;

  // Progress tracking
  Map<String, String> _homeworkAnswers = {};
  final Map<String, bool> _homeworkCompletion = {};
  final Map<String, bool> _lessonCompletion = {};
  int _totalLessons = 10; // Default total lessons
  int _completedLessons = 0;

  @override
  void initState() {
    super.initState();

    // Safe initialization with null checks
    _studentInfo =
        (widget.studentData['student_info'] as Map<String, dynamic>?) ?? {};
    _studentCode = _studentInfo['student_code']?.toString() ?? 'unknown';
    _grade = _studentInfo['grade']?.toString() ?? 'unknown';

    _loadStudentData();
    _loadHomeworkData();
    _calculateProgress();
  }

  Future<void> _loadStudentData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load all data in parallel
      final results =
          await Future.wait([
            _studentService.getStudentProgress(_studentCode),
            _studentService.getNewestLessons(limit: 10),
            _studentService.getRecommendedLessons(_studentCode, _grade),
            _studentService.getPopularLessons(limit: 5),
            _studentService.getLessonsByGrade(_grade),
            _studentService.getSubjectsByGrade(_grade),
          ], eagerError: true).catchError((e) {
            _logError('Error in parallel loading', e);
            // ignore: invalid_return_type_for_catch_error
            return List.filled(6, null);
          });

      if (results.length == 6) {
        setState(() {
          _studentProgress = results[0] as Map<String, dynamic>? ?? {};
          _newestLessons = results[1] as List<Map<String, dynamic>>? ?? [];
          _recommendedLessons = results[2] as List<Map<String, dynamic>>? ?? [];
          _popularLessons = results[3] as List<Map<String, dynamic>>? ?? [];
          _gradeLessons = results[4] as List<Map<String, dynamic>>? ?? [];
          _gradeSubjects = results[5] as List<String>? ?? [];
          _isLoading = false;
        });

        // Calculate total lessons from loaded data
        _totalLessons =
            _newestLessons.length +
            _recommendedLessons.length +
            _popularLessons.length +
            _gradeLessons.length;
        _calculateProgress();
      }

      _debugLessonData();
    } catch (e) {
      _logError('Failed to load student dashboard data', e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data. Please try again.';
      });
    }
  }

  Future<void> _loadHomeworkData() async {
    // Simulate loading homework assignments
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _homeworkAssignments = [
        {
          'id': 'sasl_hl_p1_2023',
          'title': 'SASL Home Language Paper 1 - November 2023',
          'subject': 'SASL Home Language',
          'due_date': '2023-11-30',
          'total_marks': 70,
          'time_allowed': '2 hours',
          'status': 'pending',
          'description': 'Grade 10 SASL Home Language Paper 1 Examination',
        },
      ];
    });
  }

  void _calculateProgress() {
    int completedCount = _lessonCompletion.values
        .where((completed) => completed)
        .length;
    int homeworkCount = _homeworkCompletion.values
        .where((completed) => completed)
        .length;

    // Each completed lesson and homework contributes to progress
    _completedLessons = completedCount + homeworkCount;

    // Update progress in backend (simulated)
    _updateProgressInBackend();
  }

  void _updateProgressInBackend() {
    // Simulate updating progress in backend
    final progressPercentage = _totalLessons > 0
        ? ((_completedLessons / _totalLessons) * 100).round()
        : 0;

    setState(() {
      _studentProgress = {
        'progress_percentage': progressPercentage,
        'completed_lessons': _completedLessons,
        'total_lessons': _totalLessons,
      };
    });

    // In a real app, you would call _studentService.updateStudentProgress here
    _logInfo(
      'Progress updated: $_completedLessons/$_totalLessons ($progressPercentage%)',
    );
  }

  void _debugLessonData() {
    _logInfo('=== DEBUG LESSON DATA ===');
    _logInfo('Student Grade: $_grade');
    _logInfo('Student Code: $_studentCode');
    _logInfo('Grade Lessons Count: ${_gradeLessons.length}');
    _logInfo('Grade Subjects: $_gradeSubjects');

    if (_gradeLessons.isNotEmpty) {
      _logInfo('Sample Lesson: ${_gradeLessons.first}');
    }

    _logInfo('Newest Lessons Count: ${_newestLessons.length}');
    _logInfo('Recommended Lessons Count: ${_recommendedLessons.length}');
    _logInfo('Popular Lessons Count: ${_popularLessons.length}');
    _logInfo('Progress Data: $_studentProgress');
  }

  void _navigateToLesson(Map<String, dynamic> lesson) {
    if (lesson.isEmpty) {
      _logWarning('Attempted to navigate to empty lesson');
      return;
    }

    _logInfo('Navigating to lesson: ${lesson['title']}');

    // Navigate to video player
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          lesson: lesson,
          onVideoCompleted: () {
            _markLessonAsCompleted(lesson);
          },
        ),
      ),
    );
  }

  void _markLessonAsCompleted(Map<String, dynamic> lesson) {
    final lessonId = lesson['id']?.toString() ?? lesson['title'];

    if (!_lessonCompletion.containsKey(lessonId) ||
        !_lessonCompletion[lessonId]!) {
      setState(() {
        _lessonCompletion[lessonId] = true;
        _calculateProgress();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Completed: ${lesson['title']}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToSubjectLessons(String subject) {
    _logInfo('Navigating to subject lessons: $subject');
    // TODO: Implement subject navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing $subject lessons'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _logout() {
    _logInfo('User logging out');
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }

  Future<void> _refreshData() async {
    await _loadStudentData();
    await _loadHomeworkData();
  }

  // Homework Methods
  void _navigateToHomework(Map<String, dynamic> homework) {
    _logInfo('Navigating to homework: ${homework['title']}');

    if (homework['id'] == 'sasl_hl_p1_2023') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SASLHomeworkPage(
            homework: homework,
            answers: _homeworkAnswers,
            onAnswersUpdate: (Map<String, String> updatedAnswers) {
              setState(() {
                _homeworkAnswers = updatedAnswers;
                _homeworkCompletion[homework['id']] = true;
                _calculateProgress(); // Update progress when homework is completed
              });
            },
          ),
        ),
      );
    }
  }

  // Private logging methods
  void _logError(String message, dynamic error) {
    developer.log(
      message,
      error: error,
      name: _loggerName,
      level: 1000, // SEVERE level
    );
  }

  void _logInfo(String message) {
    developer.log(
      message,
      name: _loggerName,
      level: 800, // INFO level
    );
  }

  void _logWarning(String message) {
    developer.log(
      message,
      name: _loggerName,
      level: 900, // WARNING level
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          'My Learning',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _getPrimaryColor()),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: _getTextColor().withOpacity(0.7),
            ),
            onPressed: () {
              _logInfo('Notifications button pressed');
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _getPrimaryColor()),
          const SizedBox(height: 16),
          Text(
            'Loading your dashboard...',
            style: TextStyle(color: _getTextColor(), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getTextColor().withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPrimaryColor(),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildBrowseTab();
      case 2:
        return _buildProgressTab();
      case 3:
        return _buildHomeworkTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // Progress Section
            _buildProgressSection(),
            const SizedBox(height: 24),

            // Pending Homework
            if (_homeworkAssignments.isNotEmpty) ...[
              _buildSectionHeader('Pending Homework', 'View All', () {
                setState(() => _currentIndex = 3);
              }),
              const SizedBox(height: 16),
              _buildHomeworkList(_homeworkAssignments.take(2).toList()),
              const SizedBox(height: 24),
            ],

            // Newest Lessons Section
            if (_newestLessons.isNotEmpty) ...[
              _buildSectionHeader('Newest Lessons', 'See All', () {
                _logInfo('Newest lessons see all pressed');
              }),
              const SizedBox(height: 16),
              _buildLessonList(_newestLessons.take(3).toList()),
              const SizedBox(height: 24),
            ],

            // Recommended for You
            if (_recommendedLessons.isNotEmpty) ...[
              _buildSectionHeader('Recommended for You', 'View All', () {
                _logInfo('Recommended lessons view all pressed');
              }),
              const SizedBox(height: 16),
              _buildLessonGrid(_recommendedLessons),
              const SizedBox(height: 24),
            ],

            // Popular Lessons
            if (_popularLessons.isNotEmpty) ...[
              _buildSectionHeader('Popular Lessons', 'See More', () {
                _logInfo('Popular lessons see more pressed');
              }),
              const SizedBox(height: 16),
              _buildLessonList(_popularLessons.take(3).toList()),
              const SizedBox(height: 24),
            ],

            // Grade Lessons Preview
            if (_gradeLessons.isNotEmpty) ...[
              _buildSectionHeader(
                'Your Grade ($_grade) Lessons',
                'Browse All',
                () {
                  setState(() => _currentIndex = 1);
                },
              ),
              const SizedBox(height: 16),
              _buildLessonList(_gradeLessons.take(2).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Homework Header
            _buildHomeworkHeaderSection(),
            const SizedBox(height: 24),

            // Pending Assignments
            _buildSectionHeader('Pending Assignments', '', () {}),
            const SizedBox(height: 16),
            _homeworkAssignments.isNotEmpty
                ? _buildHomeworkList(_homeworkAssignments)
                : _buildEmptyState('No homework assignments'),

            const SizedBox(height: 24),

            // Completed Assignments
            _buildSectionHeader('Completed Assignments', '', () {}),
            const SizedBox(height: 16),
            _buildEmptyState('No completed homework yet'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkHeaderSection() {
    final pendingCount = _homeworkAssignments
        .where((hw) => !(_homeworkCompletion[hw['id']] ?? false))
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2196F3).withOpacity(0.1),
            const Color(0xFF4CAF50).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Homework Center',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pendingCount pending assignment${pendingCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getTextColor().withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkList(List<Map<String, dynamic>> homeworkList) {
    return Column(
      children: homeworkList
          .map((homework) => _buildHomeworkCard(homework))
          .toList(),
    );
  }

  Widget _buildHomeworkCard(Map<String, dynamic> homework) {
    final isCompleted = _homeworkCompletion[homework['id']] ?? false;
    final dueDate = homework['due_date']?.toString() ?? 'No due date';

    return GestureDetector(
      onTap: () => _navigateToHomework(homework),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF4CAF50)
                : const Color(0xFF2196F3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCompleted ? Icons.assignment_turned_in : Icons.assignment,
                color: isCompleted
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF2196F3),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homework['title']?.toString() ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${homework['subject']} • Due: $dueDate',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getTextColor().withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: _getTextColor().withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        homework['time_allowed']?.toString() ?? 'No time limit',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTextColor().withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${homework['total_marks']} marks',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTextColor().withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isCompleted ? Icons.check_circle : Icons.arrow_forward_ios,
              color: isCompleted
                  ? const Color(0xFF4CAF50)
                  : _getTextColor().withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ... (Keep all the existing methods: _buildBrowseTab, _buildProgressTab, _buildProfileTab, etc.)

  Widget _buildBrowseTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome to Grade Section
            _buildGradeWelcomeSection(),
            const SizedBox(height: 24),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),

            // Quick Access - Subjects available in student's grade
            _buildGradeSubjectsSection(),
            const SizedBox(height: 24),

            // All Lessons for Student's Grade
            _buildGradeLessonsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressDetailSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('Continue Learning', '', () {}),
            const SizedBox(height: 16),
            _newestLessons.isNotEmpty
                ? _buildLessonList(_newestLessons.take(2).toList())
                : _buildEmptyState('No lessons available'),
            const SizedBox(height: 24),
            _buildSectionHeader('Your Favorites', '', () {}),
            const SizedBox(height: 16),
            _buildEmptyState('No favorites yet'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getCardColor(),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF4CAF50),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_studentInfo['first_name']?.toString() ?? 'Student'} ${_studentInfo['last_name']?.toString() ?? ''}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_grade • ${_studentInfo['school_name']?.toString() ?? 'Transorange School for the Deaf'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _getTextColor().withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.badge, color: Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        Text(
                          'Student Code: ${_studentInfo['student_code']?.toString() ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            _buildProfileStats(),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back, ${_studentInfo['first_name']?.toString() ?? 'Student'}!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to learn something new today?',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getTextColor().withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF2196F3).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_grade Lessons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All lessons curated for your grade level',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getTextColor().withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress =
        (_studentProgress['progress_percentage'] as num?)?.toInt() ?? 0;
    final completed = _completedLessons;
    final total = _totalLessons;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Text(
                'Learning Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: _getBorderColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width:
                    MediaQuery.of(context).size.width * (progress / 100) * 0.85,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed of $total activities completed',
                style: TextStyle(
                  fontSize: 14,
                  color: _getTextColor().withOpacity(0.6),
                ),
              ),
              Text(
                '$progress%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetailSection() {
    final progress =
        (_studentProgress['progress_percentage'] as num?)?.toInt() ?? 0;
    final completed = _completedLessons;
    final total = _totalLessons;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat('Completed', '$completed', Icons.check_circle),
              _buildProgressStat('Total', '$total', Icons.library_books),
              _buildProgressStat('Progress', '$progress%', Icons.trending_up),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: _getBorderColor(),
            color: const Color(0xFF4CAF50),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          _buildActivityBreakdown(),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdown() {
    final completedLessons = _lessonCompletion.values
        .where((completed) => completed)
        .length;
    final completedHomework = _homeworkCompletion.values
        .where((completed) => completed)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Breakdown:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 12),
        _buildBreakdownItem(
          'Lessons Watched',
          completedLessons,
          Icons.video_library,
        ),
        const SizedBox(height: 8),
        _buildBreakdownItem(
          'Homework Completed',
          completedHomework,
          Icons.assignment_turned_in,
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(String label, int count, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: _getTextColor().withOpacity(0.8),
            ),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStats() {
    final progress =
        (_studentProgress['progress_percentage'] as num?)?.toInt() ?? 0;
    final completed = _completedLessons;
    final total = _totalLessons;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileStatItem(
            'Activities Completed',
            '$completed',
            Icons.check_circle,
          ),
          const SizedBox(height: 16),
          _buildProfileStatItem(
            'Total Activities',
            '$total',
            Icons.video_library,
          ),
          const SizedBox(height: 16),
          _buildProfileStatItem('Progress', '$progress%', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildProfileStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: _getTextColor().withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _getTextColor().withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
        if (actionText.isNotEmpty)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGradeSubjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Subjects in $_grade', '', () {}),
        const SizedBox(height: 16),
        _gradeSubjects.isNotEmpty
            ? _buildSubjectChips(_gradeSubjects)
            : _buildEmptyState('No subjects available for $_grade'),
      ],
    );
  }

  Widget _buildSubjectChips(List<String> subjects) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: subjects.map((subject) {
        return FilterChip(
          label: Text(subject),
          selected: false,
          onSelected: (selected) {
            _navigateToSubjectLessons(subject);
          },
          backgroundColor: _getCardColor(),
          selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
          labelStyle: TextStyle(
            color: _getTextColor(),
            fontWeight: FontWeight.w500,
          ),
          checkmarkColor: const Color(0xFF4CAF50),
        );
      }).toList(),
    );
  }

  Widget _buildGradeLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('All $_grade Lessons', '', () {}),
            Text(
              '${_gradeLessons.length} lessons',
              style: TextStyle(
                color: _getTextColor().withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _gradeLessons.isNotEmpty
            ? _buildLessonList(_gradeLessons)
            : _buildEmptyState('No lessons available for $_grade yet'),
      ],
    );
  }

  Widget _buildLessonList(List<Map<String, dynamic>> lessons) {
    return Column(
      children: lessons.map((lesson) => _buildLessonCard(lesson)).toList(),
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    final educator = lesson['profiles'] as Map<String, dynamic>?;
    final educatorName = educator != null
        ? '${educator['first_name'] ?? ''} ${educator['last_name'] ?? ''}'
              .trim()
        : 'Unknown Educator';

    final subject = lesson['subject']?.toString() ?? 'General';
    final title = lesson['title']?.toString() ?? 'Untitled Lesson';
    final lessonId = lesson['id']?.toString() ?? title;
    final isCompleted = _lessonCompletion[lessonId] ?? false;

    // Fix duration handling - your database uses 'duration' in seconds
    final durationSeconds = (lesson['duration'] as num?)?.toInt() ?? 0;
    final durationMinutes = (durationSeconds / 60).ceil();

    final views = (lesson['views'] as num?)?.toInt();
    final grade = lesson['grade']?.toString() ?? 'Unknown Grade';

    return GestureDetector(
      onTap: () => _navigateToLesson(lesson),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Subject Icon with completion badge
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getSubjectColor(subject).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSubjectIcon(subject),
                    color: _getSubjectColor(subject),
                    size: 24,
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Lesson Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Educator and Subject
                  Text(
                    'By $educatorName • $subject',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getTextColor().withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Metadata
                  Row(
                    children: [
                      // Duration
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: _getTextColor().withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$durationMinutes min',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getTextColor().withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      // Grade
                      Row(
                        children: [
                          Icon(
                            Icons.grade,
                            size: 14,
                            color: _getTextColor().withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            grade,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getTextColor().withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Completion Status
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),

                      // Views (if available)
                      if (views != null && !isCompleted)
                        Text(
                          '$views views',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTextColor().withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonGrid(List<Map<String, dynamic>> lessons) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _buildLessonGridCard(lesson);
      },
    );
  }

  Widget _buildLessonGridCard(Map<String, dynamic> lesson) {
    final subject = lesson['subject']?.toString() ?? 'General';
    final title = lesson['title']?.toString() ?? 'Untitled Lesson';
    final lessonId = lesson['id']?.toString() ?? title;
    final isCompleted = _lessonCompletion[lessonId] ?? false;
    final durationSeconds = (lesson['duration'] as num?)?.toInt() ?? 0;
    final durationMinutes = (durationSeconds / 60).ceil();

    return GestureDetector(
      onTap: () => _navigateToLesson(lesson),
      child: Container(
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: _getSubjectColor(subject).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getSubjectIcon(subject),
                      color: _getSubjectColor(subject),
                      size: 32,
                    ),
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getTextColor().withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: _getTextColor().withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$durationMinutes min',
                        style: TextStyle(
                          fontSize: 11,
                          color: _getTextColor().withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search lessons...',
          hintStyle: TextStyle(color: _getTextColor().withOpacity(0.5)),
          prefixIcon: Icon(
            Icons.search,
            color: _getTextColor().withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          _logInfo('Search query: $value');
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: _getTextColor().withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: _getTextColor().withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String? subject) {
    switch (subject?.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history;
      case 'languages':
      case 'language':
        return Icons.language;
      case 'physics':
        return Icons.rocket_launch;
      case 'chemistry':
        return Icons.emoji_objects;
      default:
        return Icons.school;
    }
  }

  Color _getSubjectColor(String? subject) {
    switch (subject?.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return const Color(0xFF2196F3);
      case 'science':
        return const Color(0xFFFF9800);
      case 'history':
        return const Color(0xFF4CAF50);
      case 'languages':
      case 'language':
        return const Color(0xFF9C27B0);
      case 'physics':
        return const Color(0xFF607D8B);
      case 'chemistry':
        return const Color(0xFF795548);
      default:
        return const Color(0xFF607D8B);
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        _logInfo('Bottom navigation changed to index: $index');
        setState(() => _currentIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: _getCardColor(),
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: _getTextColor().withOpacity(0.5),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Browse'),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Homework',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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

  Color _getPrimaryColor() {
    return const Color(0xFF4CAF50);
  }
}

// Video Player Screen
class VideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final VoidCallback onVideoCompleted;

  const VideoPlayerScreen({
    super.key,
    required this.lesson,
    required this.onVideoCompleted,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _videoCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      // For demo purposes, using a sample video URL
      // In production, you would use the actual video URL from the lesson data
      final videoUrl =
          widget.lesson['video_url']?.toString() ??
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..addListener(() {
          if (_controller.value.isInitialized && !_isLoading) {
            setState(() {});
          }

          // Check if video reached the end
          if (_controller.value.position >= _controller.value.duration &&
              _controller.value.duration > Duration.zero) {
            if (!_videoCompleted) {
              _videoCompleted = true;
              widget.onVideoCompleted();
            }
          }
        })
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
          });
          _controller.setLooping(false);
        });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _seekForward() {
    final newPosition =
        _controller.value.position + const Duration(seconds: 10);
    _controller.seekTo(
      newPosition < _controller.value.duration
          ? newPosition
          : _controller.value.duration,
    );
  }

  void _seekBackward() {
    final newPosition =
        _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(
      newPosition > Duration.zero ? newPosition : Duration.zero,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
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
      appBar: AppBar(
        title: Text(
          widget.lesson['title']?.toString() ?? 'Video Lesson',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your internet connection',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeVideoPlayer,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Video Player
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),

                // Video Controls
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black87,
                  child: Column(
                    children: [
                      // Progress Bar
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFF4CAF50),
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Seek Backward
                          IconButton(
                            onPressed: _seekBackward,
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),

                          // Play/Pause
                          IconButton(
                            onPressed: _togglePlayPause,
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),

                          // Seek Forward
                          IconButton(
                            onPressed: _seekForward,
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Time Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lesson Info
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[900],
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lesson['title']?.toString() ??
                                'Untitled Lesson',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (widget.lesson['description'] != null)
                            Text(
                              widget.lesson['description'].toString(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 16),
                          if (_videoCompleted)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Lesson completed! Progress updated.',
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.w600,
                                    ),
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
    );
  }
}

// SASL Homework Page (keep the existing implementation)
class SASLHomeworkPage extends StatefulWidget {
  final Map<String, dynamic> homework;
  final Map<String, String> answers;
  final Function(Map<String, String>) onAnswersUpdate;

  const SASLHomeworkPage({
    super.key,
    required this.homework,
    required this.answers,
    required this.onAnswersUpdate,
  });

  @override
  State<SASLHomeworkPage> createState() => _SASLHomeworkPageState();
}

class _SASLHomeworkPageState extends State<SASLHomeworkPage> {
  final Map<String, String> _currentAnswers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentAnswers.addAll(widget.answers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SASL Homework'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveProgress),
          IconButton(
            icon: const Icon(Icons.assignment_turned_in),
            onPressed: _submitHomework,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exam Header
              _buildExamHeader(),
              const SizedBox(height: 24),

              // Instructions
              _buildInstructions(),
              const SizedBox(height: 32),

              // Section A: Comprehension
              _buildSectionA(),
              const SizedBox(height: 32),

              // Section B: Language Structures
              _buildSectionB(),
              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2196F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.homework['title']?.toString() ?? 'SASL Homework',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Total Marks: ${widget.homework['total_marks']} • Time: ${widget.homework['time_allowed']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Due: ${widget.homework['due_date']}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INSTRUCTIONS:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '1. Answer ALL questions in both sections.\n'
            '2. Write your answers in the spaces provided.\n'
            '3. Pay attention to mark allocation for each question.\n'
            '4. Use proper SASL grammar and structure in Section B.\n'
            '5. Review your work before submitting.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionA() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SECTION A: COMPREHENSION',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Answer ALL questions in this section.',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),

          // Question 1.1
          _buildQuestion(
            '1.1',
            'Watch the provided SASL video narrative and answer the following questions:',
            15,
          ),
          const SizedBox(height: 16),

          _buildSubQuestion(
            '1.1.1',
            'What is the main theme of the narrative? (3 marks)',
            'q1_1_1',
          ),
          const SizedBox(height: 12),

          _buildSubQuestion(
            '1.1.2',
            'List THREE key events that occur in the narrative. (6 marks)',
            'q1_1_2',
          ),
          const SizedBox(height: 12),

          _buildSubQuestion(
            '1.1.3',
            'Describe the relationship between the two main characters. (6 marks)',
            'q1_1_3',
          ),
          const SizedBox(height: 16),

          // Question 1.2
          _buildQuestion(
            '1.2',
            'Based on the narrative, answer the following:',
            10,
          ),
          const SizedBox(height: 16),

          _buildSubQuestion(
            '1.2.1',
            'What cultural elements are represented in the story? Provide TWO examples. (4 marks)',
            'q1_2_1',
          ),
          const SizedBox(height: 12),

          _buildSubQuestion(
            '1.2.2',
            'What is the significance of the setting in the narrative? (3 marks)',
            'q1_2_2',
          ),
          const SizedBox(height: 12),

          _buildSubQuestion(
            '1.2.3',
            'How does the narrative conclude, and what message does it convey? (3 marks)',
            'q1_2_3',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionB() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SECTION B: LANGUAGE STRUCTURES AND CONVENTIONS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Answer ALL questions in this section.',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),

          // Question 2.1
          _buildQuestion('2.1', 'SASL Grammar and Structure:', 20),
          const SizedBox(height: 16),

          _buildSubQuestion(
            '2.1.1',
            'Explain the difference between directional verbs and plain verbs in SASL. Provide TWO examples of each. (8 marks)',
            'q2_1_1',
          ),
          const SizedBox(height: 12),

          _buildSubQuestion(
            '2.1.2',
            'Describe how non-manual markers (facial expressions, body shifts) change the meaning of signs in SASL. Provide THREE examples. (6 marks)',
            'q2_1_2',
          ),
          const SizedBox(height: 12),

          _buildSubQuestion(
            '2.1.3',
            'What is the role of classifiers in SASL? Provide TWO examples of how classifiers are used. (6 marks)',
            'q2_1_3',
          ),
          const SizedBox(height: 16),

          // Question 2.2
          _buildQuestion('2.2', 'SASL Conversation and Dialogue:', 25),
          const SizedBox(height: 16),

          _buildSubQuestion(
            '2.2.1',
            'Create a short SASL dialogue (8-10 sentences) between two friends discussing their weekend plans. Focus on proper turn-taking and question formation. (15 marks)',
            'q2_2_1',
            maxLines: 8,
          ),
          const SizedBox(height: 12),

          _buildSubQuestion(
            '2.2.2',
            'Explain the cultural considerations you incorporated in your dialogue. (5 marks)',
            'q2_2_2',
          ),
          const SizedBox(height: 12),

          _buildSubQuestion(
            '2.2.3',
            'Identify THREE different sentence types used in your dialogue (declarative, interrogative, imperative, etc.). (5 marks)',
            'q2_2_3',
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(String number, String text, int marks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'QUESTION $number',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '[$marks marks]',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
      ],
    );
  }

  Widget _buildSubQuestion(
    String number,
    String text,
    String key, {
    int maxLines = 4,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _currentAnswers[key],
          onChanged: (value) {
            _currentAnswers[key] = value;
          },
          maxLines: maxLines,
          decoration: const InputDecoration(
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please provide an answer';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitHomework,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'SUBMIT HOMEWORK',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _saveProgress() {
    widget.onAnswersUpdate(_currentAnswers);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress saved successfully!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _submitHomework() {
    if (_formKey.currentState!.validate()) {
      widget.onAnswersUpdate(_currentAnswers);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Homework submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required questions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
