import 'package:flutter/material.dart';

class LiveSessionsManage extends StatefulWidget {
  const LiveSessionsManage({super.key});

  @override
  State<LiveSessionsManage> createState() => _LiveSessionsManageState();
}

class _LiveSessionsManageState extends State<LiveSessionsManage> {
  final List<Map<String, dynamic>> _sessions = [
    {
      'title': 'Advanced Calculus - Limits & Derivatives',
      'time': 'Today, 3:00 PM - 4:30 PM',
      'participants': 25,
      'status': 'scheduled',
      'subject': 'Mathematics',
      'duration': '90 mins',
      'instructor': 'Dr. John Doe',
      'joinLink': 'meet.google.com/abc-xyz-123',
    },
    {
      'title': 'Organic Chemistry Review Session',
      'time': 'Today, 4:30 PM - 6:00 PM',
      'participants': 18,
      'status': 'scheduled',
      'subject': 'Science',
      'duration': '90 mins',
      'instructor': 'Dr. Sarah Wilson',
      'joinLink': 'meet.google.com/def-uvw-456',
    },
    {
      'title': 'Linear Algebra Masterclass',
      'time': 'Tomorrow, 10:00 AM - 11:30 AM',
      'participants': 32,
      'status': 'scheduled',
      'subject': 'Mathematics',
      'duration': '90 mins',
      'instructor': 'Dr. John Doe',
      'joinLink': 'meet.google.com/ghi-rst-789',
    },
    {
      'title': 'Physics Problem Solving',
      'time': 'Yesterday, 2:00 PM - 3:30 PM',
      'participants': 28,
      'status': 'completed',
      'subject': 'Physics',
      'duration': '90 mins',
      'instructor': 'Dr. Mike Chen',
      'recordingLink': 'drive.google.com/recording-123',
    },
  ];

  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'scheduled', 'completed', 'recording'];

  // Professional color palette
  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _accentColor = const Color(0xFF4CC9F0);
  final Color _successColor = const Color(0xFF10B981);
  final Color _warningColor = const Color(0xFFF59E0B);
  final Color _infoColor = const Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredSessions = _getFilteredSessions();

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          // Stats Overview with enhanced design
          _buildStatsSection(),

          // Filter Chips
          _buildFilterSection(),

          // Sessions List
          Expanded(
            child: _buildSessionsList(filteredSessions),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      title: Text(
        'Live Sessions Management',
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
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.search, color: _primaryColor, size: 22),
            ),
            onPressed: _searchSessions,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.filter_list_rounded,
                  color: _primaryColor, size: 22),
            ),
            onPressed: _showAdvancedFilters,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final totalSessions = _sessions.length;
    final scheduledSessions =
        _sessions.where((s) => s['status'] == 'scheduled').length;
    final totalParticipants = _sessions.fold(
        0, (sum, session) => sum + (session['participants'] as int));

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor.withOpacity(0.08),
            _accentColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            totalSessions.toString(),
            'Total Sessions',
            Icons.video_library_rounded,
            _primaryColor,
          ),
          _buildStatItem(
            scheduledSessions.toString(),
            'Scheduled',
            Icons.schedule_rounded,
            _warningColor,
          ),
          _buildStatItem(
            totalParticipants.toString(),
            'Total Participants',
            Icons.people_alt_rounded,
            _successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  _getFilterLabel(filter),
                  style: TextStyle(
                    color: isSelected ? Colors.white : _getTextColor(),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? filter : 'all';
                  });
                },
                backgroundColor: _getCardColor(),
                selectedColor: _primaryColor,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? _primaryColor : _getBorderColor(),
                    width: 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSessionsList(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(sessions[index], index);
      },
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, int index) {
    final isScheduled = session['status'] == 'scheduled';
    final subjectColor = _getSubjectColor(session['subject']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _viewSessionDetails(session),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getBorderColor().withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isScheduled
                            ? _successColor.withOpacity(0.1)
                            : _infoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isScheduled
                              ? _successColor.withOpacity(0.3)
                              : _infoColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isScheduled
                                ? Icons.schedule_rounded
                                : Icons.play_circle_filled_rounded,
                            color: isScheduled ? _successColor : _infoColor,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isScheduled ? 'Scheduled' : 'Completed',
                            style: TextStyle(
                              fontSize: 11,
                              color: isScheduled ? _successColor : _infoColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (isScheduled)
                      _buildActionButton(
                          'Start', Icons.play_arrow_rounded, _successColor,
                          onTap: () => _startSession(session)),
                    if (!isScheduled)
                      _buildActionButton('View Recording',
                          Icons.play_circle_rounded, _infoColor,
                          onTap: () => _viewRecording(session)),
                    const SizedBox(width: 8),
                    _buildActionButton('More', Icons.more_vert_rounded,
                        _getTextColor().withOpacity(0.5),
                        onTap: () => _showSessionOptions(session)),
                  ],
                ),
                const SizedBox(height: 16),

                // Session content
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [subjectColor, _darkenColor(subjectColor)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.live_tv_rounded,
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
                            session['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _getTextColor(),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _buildSessionDetail(
                              Icons.schedule_rounded, session['time']),
                          const SizedBox(height: 4),
                          _buildSessionDetail(
                              Icons.timer_rounded, session['duration']),
                          const SizedBox(height: 4),
                          _buildSessionDetail(
                              Icons.person_rounded, session['instructor']),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildSessionDetail(Icons.people_rounded,
                                  '${session['participants']} participants'),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: subjectColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: subjectColor.withOpacity(0.2)),
                                ),
                                child: Text(
                                  session['subject'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subjectColor,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _getTextColor().withOpacity(0.5)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: _getTextColor().withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.live_tv_rounded, size: 48, color: _primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'No Live Sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule your first live session to get started',
            style: TextStyle(
              fontSize: 14,
              color: _getTextColor().withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildFloatingActionButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _scheduleNewSession,
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add_rounded, size: 20),
      label: const Text('New Session',
          style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  List<Map<String, dynamic>> _getFilteredSessions() {
    if (_selectedFilter == 'all') return _sessions;
    return _sessions
        .where((session) => session['status'] == _selectedFilter)
        .toList();
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All Sessions';
      case 'scheduled':
        return 'Scheduled';
      case 'completed':
        return 'Completed';
      case 'recording':
        return 'Recordings';
      default:
        return filter;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return const Color(0xFF4361EE);
      case 'science':
        return const Color(0xFF10B981);
      case 'physics':
        return const Color(0xFFF59E0B);
      case 'chemistry':
        return const Color(0xFF8B5CF6);
      default:
        return _primaryColor;
    }
  }

  Color _darkenColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness(hsl.lightness * 0.7).toColor();
  }

  void _searchSessions() {
    // Implement search functionality
  }

  void _showAdvancedFilters() {
    // Implement advanced filters
  }

  void _viewSessionDetails(Map<String, dynamic> session) {
    // Implement session details view
  }

  void _startSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting: ${session['title']}'),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _viewRecording(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening recording: ${session['title']}'),
        backgroundColor: _infoColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSessionOptions(Map<String, dynamic> session) {
    // Implement session options menu
  }

  void _scheduleNewSession() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Schedule new live session'),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
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
