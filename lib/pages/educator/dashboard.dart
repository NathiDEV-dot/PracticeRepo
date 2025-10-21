import 'package:flutter/material.dart';

class EducatorDashboard extends StatefulWidget {
  const EducatorDashboard({super.key});

  @override
  State<EducatorDashboard> createState() => _EducatorDashboardState();
}

class _EducatorDashboardState extends State<EducatorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: const Text('Educator Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: _getTextColor()),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: _getTextColor()),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildContentTab();
      case 2:
        return _buildLiveTab();
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
          // Welcome Header
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                child: const Icon(Icons.person, color: Color(0xFF667EEA)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe (Educator)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
                    Text(
                      'Mathematics Teacher • Grade 10-12',
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
          const SizedBox(height: 24),

          // Dashboard Overview
          Text(
            '📊 DASHBOARD OVERVIEW',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('📹', '12', 'Lessons', const Color(0xFF2196F3)),
              _buildStatCard(
                '📚',
                '45',
                'Assignments',
                const Color(0xFF4CAF50),
              ),
              _buildStatCard('👥', '25', 'Students', const Color(0xFFFF9800)),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            '🎯 QUICK ACTIONS:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            '➕ Create Lesson',
            Icons.video_library,
            onTap: () =>
                Navigator.pushNamed(context, '/educator/create-lesson'),
          ),
          _buildQuickActionButton(
            '📅 Schedule Live',
            Icons.live_tv,
            onTap: () =>
                Navigator.pushNamed(context, '/educator/schedule-live'),
          ),
          _buildQuickActionButton(
            '📁 Manage Content',
            Icons.folder_open,
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            '📅 RECENT ACTIVITY:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityItem('Sarah submitted Math Assignment', '2 hours ago'),
          _buildActivityItem('Live session starting in 30min', '1 hour ago'),
          _buildActivityItem('3 new student enrollments', 'Yesterday'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _getTextColor(),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _getTextColor().withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String text,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getBorderColor()),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF667EEA)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: _getTextColor().withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: _getTextColor()),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTextColor().withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 64,
            color: _getTextColor().withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Content Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your lessons and teaching materials',
            style: TextStyle(color: _getTextColor().withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.live_tv,
            size: 64,
            color: _getTextColor().withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Live Sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule and host live teaching sessions',
            style: TextStyle(color: _getTextColor().withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: _getTextColor().withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Educator Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your account and settings',
            style: TextStyle(color: _getTextColor().withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: _getCardColor(),
      selectedItemColor: const Color(0xFF667EEA),
      unselectedItemColor: _getTextColor().withOpacity(0.5),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library),
          label: 'Content',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
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
}
