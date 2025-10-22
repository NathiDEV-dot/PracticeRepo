import 'package:flutter/material.dart';

class ContentManagement extends StatefulWidget {
  const ContentManagement({super.key});

  @override
  State<ContentManagement> createState() => _ContentManagementState();
}

class _ContentManagementState extends State<ContentManagement> {
  int _selectedFolder = 0;
  final List<String> _folders = [
    'All Content',
    'Mathematics',
    'Science',
    'History',
    'Languages',
    'Archived'
  ];

  final List<Map<String, dynamic>> _videos = [
    {
      'title': 'Algebra Basics',
      'duration': '15:30',
      'views': 125,
      'students': 25,
      'icon': Icons.play_arrow,
      'color': const Color(0xFF3B82F6),
    },
    {
      'title': 'Geometry Concepts',
      'duration': '22:15',
      'views': 98,
      'students': 18,
      'icon': Icons.play_arrow,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'title': 'Science Lab Safety',
      'duration': '08:45',
      'views': 156,
      'students': 32,
      'icon': Icons.play_arrow,
      'color': const Color(0xFF10B981),
    },
    {
      'title': 'Chemical Reactions',
      'duration': '18:20',
      'views': 87,
      'students': 15,
      'icon': Icons.play_arrow,
      'color': const Color(0xFFF59E0B),
    },
    {
      'title': 'World History Overview',
      'duration': '28:40',
      'views': 203,
      'students': 41,
      'icon': Icons.play_arrow,
      'color': const Color(0xFFEF4444),
    },
    {
      'title': 'Physics Fundamentals',
      'duration': '25:10',
      'views': 134,
      'students': 28,
      'icon': Icons.play_arrow,
      'color': const Color(0xFF06B6D4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: const Text(
          'Content Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: _getPrimaryColor()),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              _buildStatsSection(),
              const SizedBox(height: 24),

              // Search and Filter
              _buildSearchSection(),
              const SizedBox(height: 24),

              // Folder Navigation
              _buildFolderSection(),
              const SizedBox(height: 24),

              // Content Grid
              _buildContentSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor()),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            icon: Icons.video_library_rounded,
            value: '45',
            label: 'Videos',
            iconColor: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFDBEAFE),
          ),
          _buildStatCard(
            icon: Icons.people_rounded,
            value: '127',
            label: 'Students',
            iconColor: const Color(0xFF16A34A),
            bgColor: const Color(0xFFDCFCE7),
          ),
          _buildStatCard(
            icon: Icons.remove_red_eye_rounded,
            value: '2.4K',
            label: 'Total Views',
            iconColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFEF3C7),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
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
            color: _getTextColorSecondary(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search content...',
                hintStyle: TextStyle(color: _getTextColorSecondary()),
                prefixIcon:
                    Icon(Icons.search_rounded, color: _getTextColorSecondary()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: _getCardColor(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: _getCardColor(),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.filter_list_rounded, color: _getTextColor()),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildFolderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text(
            'Folders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _folders.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFolder = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedFolder == index
                          ? _getPrimaryColor()
                          : _getCardColor(),
                      borderRadius: BorderRadius.circular(25),
                      border: _selectedFolder == index
                          ? null
                          : Border.all(color: _getBorderColor()),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedFolder == index
                              ? const Color(0x33000000)
                              : const Color(0x0D000000),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _folders[index],
                      style: TextStyle(
                        color: _selectedFolder == index
                            ? Colors.white
                            : _getTextColor(),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Videos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1A3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_videos.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getPrimaryColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72, // Adjusted to prevent overflow
          ),
          itemCount: _videos.length,
          itemBuilder: (context, index) {
            final video = _videos[index];
            return _buildContentCard(video);
          },
        ),
      ],
    );
  }

  Widget _buildContentCard(Map<String, dynamic> video) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 200, // Added constraint to prevent overflow
      ),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Changed to min to prevent expansion
        children: [
          // Header with icon and title
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getLightColor(video['color'] as Color),
                        _getLighterColor(video['color'] as Color),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getMediumColor(video['color'] as Color),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    video['icon'] as IconData,
                    color: video['color'] as Color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['title'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTextColor(),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getBackgroundColor(),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 10, color: _getTextColorTertiary()),
                            const SizedBox(width: 2),
                            Text(
                              video['duration'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _getTextColorTertiary(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getBackgroundColorLight(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye_rounded,
                          size: 12, color: _getTextColorTertiary()),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${video['views']} views',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getTextColorTertiary(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_rounded,
                          size: 12, color: _getTextColorTertiary()),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${video['students']} students this week',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getTextColorTertiary(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: _getBorderColorLight()),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  onPressed: () => _editContent(video['title']),
                ),
                Container(
                  height: 16,
                  width: 1,
                  color: _getBorderColorLight(),
                ),
                _buildActionButton(
                  icon: Icons.analytics_rounded,
                  label: 'Analytics',
                  onPressed: () => _viewAnalytics(video['title']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 12, color: _getPrimaryColor()),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _getPrimaryColor(),
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          minimumSize: Size.zero,
        ),
      ),
    );
  }

  void _editContent(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit "$title"'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _viewAnalytics(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Analytics for "$title"'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Color helper methods
  Color _getLightColor(Color baseColor) {
    return baseColor.withAlpha(51);
  }

  Color _getLighterColor(Color baseColor) {
    return baseColor.withAlpha(26);
  }

  Color _getMediumColor(Color baseColor) {
    return baseColor.withAlpha(77);
  }

  Color _getTextColorSecondary() {
    return _getTextColor().withAlpha(153);
  }

  Color _getTextColorTertiary() {
    return _getTextColor().withAlpha(128);
  }

  Color _getBackgroundColorLight() {
    return _getBackgroundColor().withAlpha(128);
  }

  Color _getBorderColorLight() {
    return _getBorderColor().withAlpha(128);
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
    return const Color(0xFF3B82F6);
  }
}
