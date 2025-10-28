// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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
  bool _isLoading = true;
  String? _errorMessage;

  // Student info
  late Map<String, dynamic> _studentInfo;
  late String _studentCode;
  late String _grade;

  @override
  void initState() {
    super.initState();

    // Safe initialization with null checks
    _studentInfo =
        (widget.studentData['student_info'] as Map<String, dynamic>?) ?? {};
    _studentCode = _studentInfo['student_code']?.toString() ?? 'unknown';
    _grade = _studentInfo['grade']?.toString() ?? 'unknown';

    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load all data in parallel
      final results = await Future.wait([
        _studentService.getStudentProgress(_studentCode),
        _studentService.getNewestLessons(limit: 10),
        _studentService.getRecommendedLessons(_studentCode, _grade),
        _studentService.getPopularLessons(limit: 5),
        _studentService.getLessonsByGrade(_grade),
        _studentService.getSubjectsByGrade(_grade),
      ], eagerError: true)
          .catchError((e) {
        _logError('Error in parallel loading', e);
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
    // TODO: Implement lesson navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${lesson['title']}'),
        backgroundColor: Colors.green,
      ),
    );
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
            icon: Icon(Icons.notifications_none,
                color: _getTextColor().withOpacity(0.7)),
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
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 16,
            ),
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
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _refreshData, // Fixed: Now returns Future<void>
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
              _buildSectionHeader('Your Grade ($_grade) Lessons', 'Browse All',
                  () {
                setState(() => _currentIndex = 1);
              }),
              const SizedBox(height: 16),
              _buildLessonList(_gradeLessons.take(2).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseTab() {
    return RefreshIndicator(
      onRefresh: _refreshData, // Fixed: Now returns Future<void>
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
      onRefresh: _refreshData, // Fixed: Now returns Future<void>
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
      onRefresh: _refreshData, // Fixed: Now returns Future<void>
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

  // ... (All the other helper methods remain exactly the same as in the previous code)
  // _buildWelcomeSection(), _buildProgressSection(), _buildLessonCard(), etc.
  // These methods don't need to change

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
            child: const Icon(
              Icons.school,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
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
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 24,
            ),
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
    final completed =
        (_studentProgress['completed_lessons'] as num?)?.toInt() ?? 0;
    final total = (_studentProgress['total_lessons'] as num?)?.toInt() ?? 0;

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
              const Icon(
                Icons.trending_up,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
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
                '$completed of $total lessons completed',
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
    final completed =
        (_studentProgress['completed_lessons'] as num?)?.toInt() ?? 0;
    final total = (_studentProgress['total_lessons'] as num?)?.toInt() ?? 0;

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
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    final progress =
        (_studentProgress['progress_percentage'] as num?)?.toInt() ?? 0;
    final completed =
        (_studentProgress['completed_lessons'] as num?)?.toInt() ?? 0;
    final total = (_studentProgress['total_lessons'] as num?)?.toInt() ?? 0;

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
              'Lessons Completed', '$completed', Icons.check_circle),
          const SizedBox(height: 16),
          _buildProfileStatItem('Total Lessons', '$total', Icons.video_library),
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
      String title, String actionText, VoidCallback onAction) {
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
        ),
        child: Row(
          children: [
            // Subject Icon
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

                      // Views (if available)
                      if (views != null)
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          prefixIcon:
              Icon(Icons.search, color: _getTextColor().withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Browse',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
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

  Color _getPrimaryColor() {
    return const Color(0xFF4CAF50);
  }
}
