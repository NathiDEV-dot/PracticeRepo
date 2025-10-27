// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/student_service.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  final StudentService _studentService = StudentService();

  // Data states
  Map<String, dynamic> _studentProgress = {};
  List<Map<String, dynamic>> _recommendedLessons = [];
  List<Map<String, dynamic>> _recentLessons = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Custom icons for better visual communication
  final Map<String, IconData> _customIcons = {
    'home': Icons.dashboard,
    'live': Icons.live_tv,
    'assignments': Icons.assignment_turned_in,
    'profile': Icons.account_circle,
    'math': Icons.calculate,
    'science': Icons.science,
    'progress': Icons.trending_up,
    'notifications': Icons.notifications_none,
    'settings': Icons.settings,
    'video': Icons.play_circle_filled,
    'record': Icons.video_call,
    'time': Icons.access_time,
    'calendar': Icons.calendar_today,
  };

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Load data in parallel
        final progress = await _studentService.getStudentProgress(user.id);
        final recommended =
            await _studentService.getRecommendedLessons(user.id);

        setState(() {
          _studentProgress = progress;
          _recommendedLessons = recommended;
          _recentLessons =
              recommended.take(2).toList(); // Show 2 recent lessons
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
  }

  void _navigateToLesson(Map<String, dynamic> lesson) {
    Navigator.pushNamed(
      context,
      '/student/lesson',
      arguments: lesson,
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
          _buildIconButton(_customIcons['notifications']!),
          _buildIconButton(_customIcons['settings']!),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your dashboard...'),
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
          const Text(
            'Failed to load dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadStudentData,
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
        return _buildLiveSessionsTab();
      case 2:
        return _buildHomeworkTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
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

          // Today's Activities (Recommended Lessons)
          if (_recommendedLessons.isNotEmpty) ...[
            _buildSectionHeader('Recommended for You'),
            const SizedBox(height: 16),
            ..._recommendedLessons.take(2).map(
                  (lesson) => _buildActivityCard(
                    lesson['title'] ?? 'Untitled Lesson',
                    lesson['subject'] ?? 'General',
                    _getSubjectIcon(lesson['subject']),
                    '${lesson['duration_minutes'] ?? 15} min',
                    'Watch Now',
                    _getSubjectColor(lesson['subject']),
                    onTap: () => _navigateToLesson(lesson),
                  ),
                ),
            const SizedBox(height: 12),
          ],

          // Recent Activity
          if (_recentLessons.isNotEmpty) ...[
            _buildSectionHeader('Continue Learning'),
            const SizedBox(height: 16),
            ..._recentLessons.map(
              (lesson) => _buildActivityCard(
                lesson['title'] ?? 'Untitled Lesson',
                lesson['subject'] ?? 'General',
                _getSubjectIcon(lesson['subject']),
                '${lesson['duration_minutes'] ?? 15} min',
                'Continue',
                _getSubjectColor(lesson['subject']),
                onTap: () => _navigateToLesson(lesson),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Quick Access Subjects
          _buildSectionHeader('Browse Subjects'),
          const SizedBox(height: 16),
          _buildSubjectGrid(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Student';

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
                  'Welcome Back, $userName!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grade 10 • ${_studentProgress['progress_percentage'] ?? 0}% Complete',
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

  Widget _buildProgressSection() {
    final progress = _studentProgress['progress_percentage'] ?? 0;
    final completed = _studentProgress['completed_lessons'] ?? 0;
    final total = _studentProgress['total_lessons'] ?? 0;

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

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _getTextColor().withOpacity(0.5),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String subject,
    IconData icon,
    String duration,
    String action,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getTextColor().withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: _getTextColor().withOpacity(0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTextColor().withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    action,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectGrid() {
    final subjects = [
      {
        'name': 'Mathematics',
        'icon': Icons.calculate,
        'color': const Color(0xFF2196F3)
      },
      {
        'name': 'Science',
        'icon': Icons.science,
        'color': const Color(0xFFFF9800)
      },
      {
        'name': 'History',
        'icon': Icons.history,
        'color': const Color(0xFF4CAF50)
      },
      {
        'name': 'Languages',
        'icon': Icons.language,
        'color': const Color(0xFF9C27B0)
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectCard(
          subject['name'] as String,
          subject['icon'] as IconData,
          subject['color'] as Color,
        );
      },
    );
  }

  Widget _buildSubjectCard(String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Navigate to subject lessons
        Navigator.pushNamed(
          context,
          '/student/subject-lessons',
          arguments: name,
        );
      },
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
          ],
        ),
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
      default:
        return const Color(0xFF607D8B);
    }
  }

  Widget _buildLiveSessionsTab() {
    return _buildPlaceholderTab(
      Icons.live_tv,
      'Live Sessions',
      'Join scheduled sessions with educators',
      'View Schedule',
      () => Navigator.pushNamed(context, '/student/live-session'),
    );
  }

  Widget _buildHomeworkTab() {
    return _buildPlaceholderTab(
      Icons.assignment_turned_in,
      'Assignments',
      'View and submit your work',
      'View Assignments',
      () => Navigator.pushNamed(context, '/student/homework'),
    );
  }

  Widget _buildProfileTab() {
    return _buildPlaceholderTab(
      Icons.account_circle,
      'Profile',
      'Manage your account and progress',
      'Edit Profile',
      () => Navigator.pushNamed(context, '/student/profile'),
    );
  }

  Widget _buildPlaceholderTab(
    IconData icon,
    String title,
    String subtitle,
    String buttonText,
    VoidCallback onPressed,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _getCardColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 48,
                color: _getTextColor().withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: _getTextColor().withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Icon(icon, color: _getTextColor().withOpacity(0.7)),
        onPressed: () {},
        style: IconButton.styleFrom(
          backgroundColor: _getCardColor().withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: _getCardColor(),
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: _getTextColor().withOpacity(0.5),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.live_tv),
          label: 'Live',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in),
          label: 'Assignments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
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
}
