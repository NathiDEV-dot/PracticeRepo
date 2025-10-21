import 'package:flutter/material.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
          // Welcome Header
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF4CAF50)
                    .withAlpha(26), // 0.1 opacity = 26 alpha
                child: const Icon(Icons.person, color: Color(0xFF4CAF50)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sarah (Student)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
                    Text(
                      'Grade 10 • Progress: 85% Complete',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getSecondaryTextColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCardColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getBorderColor()),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
                    const Text(
                      '85%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.85,
                    backgroundColor: _getBorderColor(),
                    color: const Color(0xFF4CAF50),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // My Learning Section
          Text(
            '📚 MY LEARNING',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 16),

          // Today's Activities
          Text(
            '🎯 TODAY\'S ACTIVITIES:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            '📹 Math: Algebra Basics',
            'Due: Today',
            '⏱️ 15 min',
            '▶️ Watch Now',
            const Color(0xFF2196F3),
            onTap: () => Navigator.pushNamed(context, '/student/lesson'),
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            '📝 Science Lab Report',
            'Due: Tomorrow',
            '⏱️ 30 min',
            '🎥 Record',
            const Color(0xFFFF9800),
            onTap: () => Navigator.pushNamed(context, '/student/homework'),
          ),
          const SizedBox(height: 24),

          // Live Sessions
          Text(
            '📅 LIVE SESSIONS:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 12),
          _buildLiveSessionItem('Math Help Session - 3:00 PM'),
          _buildLiveSessionItem('Science Review - 4:30 PM'),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String due,
    String duration,
    String action,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getBorderColor()),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26), // 0.1 opacity = 26 alpha
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title.split(' ')[0], // Emoji
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
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
                      ),
                      Text(
                        due,
                        style: TextStyle(
                          fontSize: 14,
                          color: _getSecondaryTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 14,
                    color: _getTertiaryTextColor(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    action,
                    style: const TextStyle(
                      fontSize: 14,
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

  Widget _buildLiveSessionItem(String session) {
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
          const Icon(Icons.circle, color: Colors.green, size: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              session,
              style: TextStyle(fontSize: 14, color: _getTextColor()),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: _getQuaternaryTextColor(),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSessionsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_camera_front,
            size: 64,
            color: _getTertiaryTextColor(),
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
            'Join scheduled live sessions with educators',
            style: TextStyle(color: _getSecondaryTextColor()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/student/live-session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('View Live Sessions'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 64,
            color: _getTertiaryTextColor(),
          ),
          const SizedBox(height: 16),
          Text(
            'Homework & Assignments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View and submit your assignments',
            style: TextStyle(color: _getSecondaryTextColor()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/student/homework'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('View Assignments'),
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
          Icon(
            Icons.person,
            size: 64,
            color: _getTertiaryTextColor(),
          ),
          const SizedBox(height: 16),
          Text(
            'Student Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your account and settings',
            style: TextStyle(color: _getSecondaryTextColor()),
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
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: _getQuaternaryTextColor(),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_camera_front),
          label: 'Live',
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

  // Method for secondary text
  Color _getSecondaryTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFB3B3B3) // Equivalent to white.withOpacity(0.7)
        : const Color(
            0xFF666666); // Equivalent to Color(0xFF2D3748).withOpacity(0.7)
  }

  // Method for tertiary text
  Color _getTertiaryTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF999999) // Equivalent to white.withOpacity(0.6)
        : const Color(
            0xFF888888); // Equivalent to Color(0xFF2D3748).withOpacity(0.6)
  }

  // Method for quaternary text
  Color _getQuaternaryTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF808080) // Equivalent to white.withOpacity(0.5)
        : const Color(
            0xFF999999); // Equivalent to Color(0xFF2D3748).withOpacity(0.5)
  }
}
