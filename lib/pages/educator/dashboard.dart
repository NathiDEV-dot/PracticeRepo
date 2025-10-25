// lib/pages/educator/dashboard.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/dashboard_service.dart';
import 'content_management.dart';
import 'live_sessions_manage.dart';
import 'review_submissions.dart';

class EducatorDashboard extends StatefulWidget {
  const EducatorDashboard({super.key});

  @override
  State<EducatorDashboard> createState() => _EducatorDashboardState();
}

class _EducatorDashboardState extends State<EducatorDashboard> {
  int _currentIndex = 0;
  Map<String, dynamic>? _educatorData;
  bool _isLoading = true;
  String? _errorMessage;
  late final DashboardService _dashboardService;

  // Professional color palette
  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _secondaryColor = const Color(0xFF3A0CA3);
  final Color _accentColor = const Color(0xFF4CC9F0);
  final Color _successColor = const Color(0xFF4ADE80);
  final Color _warningColor = const Color(0xFFF59E0B);
  final Color _errorColor = const Color(0xFFEF4444);
  // ignore: unused_field
  final Color _infoColor = const Color(0xFF06B6D4);

  @override
  void initState() {
    super.initState();
    _dashboardService = DashboardService();
    _loadEducatorData();
  }

  Future<void> _loadEducatorData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await _dashboardService.getEducatorData(user.id);
        setState(() {
          _educatorData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No user logged in';
        });
      }
    } catch (e) {
      debugPrint('Error loading educator data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load dashboard data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _getBackgroundColor(isDark),
      appBar: _buildAppBar(isDark),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      title: Text(
        'Educator Dashboard',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _getTextColor(isDark),
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: _getTextColor(isDark)),
          onPressed: _loadEducatorData,
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: _getTextColor(isDark), size: 24),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _errorColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getCardColor(isDark),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _getCurrentBody(),
    );
  }

  Widget _getCurrentBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const ContentManagement();
      case 2:
        return const LiveSessionsManage();
      case 3:
        return const ReviewSubmissions();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    if (_educatorData == null && !_isLoading) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          _buildSectionHeader('Dashboard Overview'),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          if (_educatorData != null) ...[
            _buildSectionHeader('My Classes & Students'),
            const SizedBox(height: 16),
            _buildClassesOverview(),
            const SizedBox(height: 24),
          ],
          _buildSectionHeader('Quick Actions'),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildSectionHeader('Recent Activity'),
          const SizedBox(height: 16),
          _buildRecentActivity(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    if (_isLoading) {
      return _buildLoadingWelcomeHeader();
    }

    if (_educatorData == null) {
      return _buildErrorWelcomeHeader();
    }

    final educator = _educatorData!['educator'];
    final stats = _educatorData!['stats'];
    final subjects = _educatorData!['subjects'] as List<String>;
    final grades = _educatorData!['grades_taught'] as List<String>;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getWelcomeGradientStart(),
            _getWelcomeGradientEnd(),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${educator['first_name']} ${educator['last_name']}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _getTextColor(),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subjects.length} ${subjects.length == 1 ? 'Subject' : 'Subjects'} • ${grades.join(", ")}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getSecondaryTextColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getSuccessBackgroundColor(),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getSuccessBorderColor()),
                      ),
                      child: Text(
                        '${stats['total_students']} Students',
                        style: TextStyle(
                          fontSize: 12,
                          color: _successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: _primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${stats['total_classes']} Classes',
                        style: TextStyle(
                          fontSize: 12,
                          color: _primaryColor,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildLoadingWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getHintColor().withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  color: _getHintColor().withOpacity(0.3),
                  margin: const EdgeInsets.only(bottom: 8),
                ),
                Container(
                  width: 200,
                  height: 16,
                  color: _getHintColor().withOpacity(0.3),
                  margin: const EdgeInsets.only(bottom: 12),
                ),
                Container(
                  width: 120,
                  height: 24,
                  color: _getHintColor().withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: _errorColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Unable to load profile data',
              style: TextStyle(
                fontSize: 16,
                color: _getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _getTextColor(),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_isLoading || _educatorData == null) {
      return _buildLoadingStats();
    }

    final stats = _educatorData!['stats'];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          Icons.people_alt_rounded,
          '${stats['total_students']}',
          'Total Students',
          const [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        _buildStatCard(
          Icons.school_rounded,
          '${stats['total_classes']}',
          'Total Classes',
          const [Color(0xFF4CC9F0), Color(0xFF0891B2)],
        ),
        _buildStatCard(
          Icons.video_library_rounded,
          '${stats['published_lessons']}',
          'Published Lessons',
          const [Color(0xFF4361EE), Color(0xFF3A0CA3)],
        ),
        _buildStatCard(
          Icons.assignment_rounded,
          '${stats['total_lessons']}',
          'Total Lessons',
          const [Color(0xFF4ADE80), Color(0xFF16A34A)],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _getCardColor(),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _getBorderColor()),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _getTextColor(),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getSecondaryTextColor(),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _getCardColor(),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: _primaryColor,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassesOverview() {
    if (_isLoading || _educatorData == null) {
      return _buildLoadingClasses();
    }

    final classesByGrade =
        _educatorData!['classes_by_grade'] as Map<String, dynamic>;
    final allStudents = _educatorData!['all_students'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStudentsSummaryCard(allStudents),
        const SizedBox(height: 16),
        ...classesByGrade.keys
            .map((grade) => _buildGradeClassCard(grade, classesByGrade[grade]))
            .toList(),
      ],
    );
  }

  Widget _buildStudentsSummaryCard(List<dynamic> students) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_warningColor, _warningColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_alt_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${students.length} Students',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _getTextColor(),
                      ),
                    ),
                    Text(
                      'Across all your classes',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getSecondaryTextColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: students
                .take(8)
                .map<Widget>((student) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: _primaryColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        '${student['first_name']} ${student['last_name'][0]}.',
                        style: TextStyle(
                          fontSize: 11,
                          color: _primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
          if (students.length > 8) ...[
            const SizedBox(height: 8),
            Text(
              '+ ${students.length - 8} more students',
              style: TextStyle(
                fontSize: 11,
                color: _getSecondaryTextColor(),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradeClassCard(String grade, List<dynamic> classes) {
    final totalStudents = classes.fold(
        0, (sum, classData) => sum + (classData['student_count'] as int));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  grade,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _getTextColor(),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _accentColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '$totalStudents students',
                    style: TextStyle(
                      fontSize: 12,
                      color: _accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: classes
                  .map<Widget>((classData) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _primaryColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classData['subject'],
                              style: TextStyle(
                                fontSize: 12,
                                color: _primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${classData['student_count']} students',
                              style: TextStyle(
                                fontSize: 10,
                                color: _primaryColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingClasses() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: _primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      QuickAction(
        'Create New Lesson',
        Icons.video_library_rounded,
        _primaryColor,
        onTap: () => Navigator.pushNamed(context, '/educator/create-lesson'),
      ),
      QuickAction(
        'Manage Content',
        Icons.folder_open_rounded,
        _warningColor,
        onTap: () => setState(() => _currentIndex = 1),
      ),
      QuickAction(
        'Schedule Live Session',
        Icons.live_tv_rounded,
        _errorColor,
        onTap: () => setState(() => _currentIndex = 2),
      ),
      QuickAction(
        'Review Submissions',
        Icons.rate_review_rounded,
        _successColor,
        onTap: () => setState(() => _currentIndex = 3),
      ),
    ];

    return Column(
      children: actions.map((action) => _buildQuickActionItem(action)).toList(),
    );
  }

  Widget _buildQuickActionItem(QuickAction action) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getBorderColor()),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getActionIconBackgroundColor(action.color),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _getActionIconBorderColor(action.color)),
                  ),
                  child: Icon(action.icon, color: action.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to navigate',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getHintColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: _getHintColor(), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      ActivityItem(
        'Sarah Johnson submitted Math Assignment #4',
        '2 hours ago',
        Icons.assignment_turned_in_rounded,
        _successColor,
        onTap: () => setState(() => _currentIndex = 3),
      ),
      ActivityItem(
        'Live session "Advanced Calculus" starting in 30min',
        '1 hour ago',
        Icons.live_tv_rounded,
        _errorColor,
        onTap: () => setState(() => _currentIndex = 2),
      ),
      ActivityItem(
        'New student enrollment: Michael Chen',
        '3 hours ago',
        Icons.person_add_rounded,
        _accentColor,
        onTap: () {},
      ),
      ActivityItem(
        'Weekly performance report generated',
        '5 hours ago',
        Icons.analytics_rounded,
        _primaryColor,
        onTap: () {},
      ),
    ];

    return Column(
      children:
          activities.map((activity) => _buildActivityItem(activity)).toList(),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: activity.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getBorderColor()),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getActivityIconBackgroundColor(activity.color),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(activity.icon, color: activity.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _getTextColor(),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSecondaryTextColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: _getHintColor(), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading Dashboard...',
            style: TextStyle(
              fontSize: 16,
              color: _getTextColor(),
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
          Icon(Icons.error_outline_rounded, size: 64, color: _errorColor),
          const SizedBox(height: 16),
          Text(
            'Error Loading Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadEducatorData,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_rounded, size: 64, color: _getHintColor()),
          const SizedBox(height: 16),
          Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load educator data',
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(bool isDark) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: _getCardColor(isDark),
      selectedItemColor: _primaryColor,
      unselectedItemColor: _getHintColor(isDark),
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.dashboard_rounded),
          ),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getNavBarActiveBackground(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dashboard_rounded),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.video_library_rounded),
          ),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getNavBarActiveBackground(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.video_library_rounded),
          ),
          label: 'Content',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.live_tv_rounded),
          ),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getNavBarActiveBackground(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.live_tv_rounded),
          ),
          label: 'Live',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.rate_review_rounded),
          ),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getNavBarActiveBackground(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.rate_review_rounded),
          ),
          label: 'Review',
        ),
      ],
    );
  }

  // Color methods
  Color _getBackgroundColor([bool? isDark]) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    return dark ? const Color(0xFF0F0F1E) : const Color(0xFFF5F7FA);
  }

  Color _getTextColor([bool? isDark]) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    return dark ? Colors.white : const Color(0xFF1A202C);
  }

  Color _getSecondaryTextColor([bool? isDark]) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    return dark ? const Color(0xFFA0AEC0) : const Color(0xFF718096);
  }

  Color _getHintColor([bool? isDark]) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    return dark ? const Color(0xFF718096) : const Color(0xFFA0AEC0);
  }

  Color _getCardColor([bool? isDark]) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    return dark ? const Color(0xFF1E1E2E) : Colors.white;
  }

  Color _getBorderColor([bool? isDark]) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    return dark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0);
  }

  Color _getShadowColor([bool? isDark]) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    return dark
        ? Colors.black.withOpacity(0.4)
        : Colors.black.withOpacity(0.08);
  }

  Color _getWelcomeGradientStart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF1E3A8A).withOpacity(0.3)
        : const Color(0xFF4361EE).withOpacity(0.15);
  }

  Color _getWelcomeGradientEnd() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF0EA5E9).withOpacity(0.15)
        : const Color(0xFF4CC9F0).withOpacity(0.08);
  }

  Color _getSuccessBackgroundColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
  }

  Color _getSuccessBorderColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF047857) : const Color(0xFF86EFAC);
  }

  Color _getActionIconBackgroundColor(Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? _darkenColor(baseColor, 0.8)
        : _lightenColor(baseColor, 0.9);
  }

  Color _getActionIconBorderColor(Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? _darkenColor(baseColor, 0.6)
        : _lightenColor(baseColor, 0.7);
  }

  Color _getActivityIconBackgroundColor(Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? _darkenColor(baseColor, 0.85)
        : _lightenColor(baseColor, 0.95);
  }

  Color _getNavBarActiveBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF4361EE).withOpacity(0.3)
        : const Color(0xFF4361EE).withOpacity(0.15);
  }

  Color _darkenColor(Color color, double factor) {
    return Color.fromARGB(
      color.alpha,
      (color.red * factor).round(),
      (color.green * factor).round(),
      (color.blue * factor).round(),
    );
  }

  Color _lightenColor(Color color, double factor) {
    return Color.fromARGB(
      color.alpha,
      (color.red + (255 - color.red) * factor).round(),
      (color.green + (255 - color.green) * factor).round(),
      (color.blue + (255 - color.blue) * factor).round(),
    );
  }
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const QuickAction(this.title, this.icon, this.color, {this.onTap});
}

class ActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ActivityItem(this.title, this.time, this.icon, this.color,
      {this.onTap});
}
