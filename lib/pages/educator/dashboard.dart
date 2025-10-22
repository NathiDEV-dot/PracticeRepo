// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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

  // Professional color palette
  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _secondaryColor = const Color(0xFF3A0CA3);
  final Color _accentColor = const Color(0xFF4CC9F0);
  final Color _successColor = const Color(0xFF4ADE80);
  final Color _warningColor = const Color(0xFFF59E0B);
  final Color _errorColor = const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
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
          color: _getTextColor(),
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: _getTextColor(), size: 24),
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
                      color: _getCardColor(),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header with improved design
          _buildWelcomeHeader(),
          const SizedBox(height: 32),

          // Dashboard Overview
          _buildSectionHeader('Dashboard Overview'),
          const SizedBox(height: 20),

          // Stats Cards Grid
          _buildStatsGrid(),
          const SizedBox(height: 32),

          // Quick Actions
          _buildSectionHeader('Quick Actions'),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 32),

          // Recent Activity
          _buildSectionHeader('Recent Activity'),
          const SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor.withOpacity(0.1),
            _accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor().withOpacity(0.3),
        ),
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
                  'Dr. John Doe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _getTextColor(),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mathematics Department • Grade 10-12',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getTextColor().withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _successColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Last login: Today, 08:45 AM',
                    style: TextStyle(
                      fontSize: 12,
                      color: _successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // CORRECTED CLASS NAME
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          Icons.video_library_rounded,
          '12',
          'Video Lessons',
          _primaryColor,
          const [Color(0xFF4361EE), Color(0xFF3A0CA3)],
        ),
        _buildStatCard(
          Icons.assignment_rounded,
          '45',
          'Assignments',
          _successColor,
          const [Color(0xFF4ADE80), Color(0xFF16A34A)],
        ),
        _buildStatCard(
          Icons.people_alt_rounded,
          '25',
          'Active Students',
          _warningColor,
          const [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        _buildStatCard(
          Icons.schedule_rounded,
          '8',
          'Live Sessions',
          _accentColor,
          const [Color(0xFF4CC9F0), Color(0xFF0891B2)],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color,
      List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _getCardColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getBorderColor().withOpacity(0.5),
        ),
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
                    color: _getTextColor().withOpacity(0.6),
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

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        'Create New Lesson',
        Icons.video_library_rounded,
        _primaryColor,
        onTap: () => Navigator.pushNamed(context, '/educator/create-lesson'),
      ),
      _QuickAction(
        'Manage Content',
        Icons.folder_open_rounded,
        _warningColor,
        onTap: () => setState(() => _currentIndex = 1),
      ),
      _QuickAction(
        'Schedule Live Session',
        Icons.live_tv_rounded,
        _errorColor,
        onTap: () => setState(() => _currentIndex = 2),
      ),
      _QuickAction(
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

  Widget _buildQuickActionItem(_QuickAction action) {
    return Container(
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
              border: Border.all(
                color: _getBorderColor().withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: action.color.withOpacity(0.2),
                    ),
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
                          color: _getTextColor().withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _getTextColor().withOpacity(0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      _ActivityItem(
        'Sarah Johnson submitted Math Assignment #4',
        '2 hours ago',
        Icons.assignment_turned_in_rounded,
        _successColor,
        onTap: () => setState(() => _currentIndex = 3),
      ),
      _ActivityItem(
        'Live session "Advanced Calculus" starting in 30min',
        '1 hour ago',
        Icons.live_tv_rounded,
        _errorColor,
        onTap: () => setState(() => _currentIndex = 2),
      ),
      _ActivityItem(
        'New student enrollment: Michael Chen',
        '3 hours ago',
        Icons.person_add_rounded,
        _accentColor,
        onTap: () {},
      ),
      _ActivityItem(
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

  Widget _buildActivityItem(_ActivityItem activity) {
    return Container(
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
              border: Border.all(
                color: _getBorderColor().withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: activity.color.withOpacity(0.1),
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
                          color: _getTextColor().withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _getTextColor().withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(bool isDark) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: _getCardColor(),
      selectedItemColor: _primaryColor,
      unselectedItemColor: _getTextColor().withOpacity(0.5),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
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
              color: _primaryColor.withOpacity(0.1),
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
              color: _primaryColor.withOpacity(0.1),
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
              color: _primaryColor.withOpacity(0.1),
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
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.rate_review_rounded),
          ),
          label: 'Review',
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0A0A14)
        : const Color(0xFFF8FAFF);
  }

  Color _getTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1A202C);
  }

  Color _getCardColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1A1A2E)
        : Colors.white;
  }

  Color _getBorderColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2D3748)
        : const Color(0xFFE2E8F0);
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  _QuickAction(this.title, this.icon, this.color, {this.onTap});
}

class _ActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  _ActivityItem(this.title, this.time, this.icon, this.color, {this.onTap});
}
