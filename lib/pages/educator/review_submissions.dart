// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ReviewSubmissions extends StatefulWidget {
  const ReviewSubmissions({super.key});

  @override
  State<ReviewSubmissions> createState() => _ReviewSubmissionsState();
}

class _ReviewSubmissionsState extends State<ReviewSubmissions> {
  int _selectedFilter = 0; // 0: All, 1: Pending, 2: Graded
  final List<String> _filters = ['All', 'Pending', 'Graded'];

  final List<Map<String, dynamic>> _submissions = [
    {
      'student': 'Sarah Johnson',
      'assignment': 'Math: Algebra Basics',
      'submitted': '2 hours ago',
      'status': 'pending',
      'grade': null,
      'avatar': 'SJ',
      'subject': 'Mathematics',
      'dueDate': 'Due yesterday',
      'priority': 'high',
    },
    {
      'student': 'Mike Wilson',
      'assignment': 'Science Lab Report - Chemical Reactions',
      'submitted': '5 hours ago',
      'status': 'graded',
      'grade': 'A-',
      'avatar': 'MW',
      'subject': 'Science',
      'dueDate': 'Due today',
      'priority': 'medium',
    },
    {
      'student': 'Lisa Chen',
      'assignment': 'History Essay: World War II Analysis',
      'submitted': '1 day ago',
      'status': 'pending',
      'grade': null,
      'avatar': 'LC',
      'subject': 'History',
      'dueDate': 'Due in 2 days',
      'priority': 'low',
    },
    {
      'student': 'David Brown',
      'assignment': 'Math: Geometry Final Project',
      'submitted': '2 days ago',
      'status': 'graded',
      'grade': 'B+',
      'avatar': 'DB',
      'subject': 'Mathematics',
      'dueDate': 'Due 3 days ago',
      'priority': 'medium',
    },
    {
      'student': 'Emma Garcia',
      'assignment': 'Physics: Motion and Forces',
      'submitted': '3 hours ago',
      'status': 'pending',
      'grade': null,
      'avatar': 'EG',
      'subject': 'Physics',
      'dueDate': 'Due tomorrow',
      'priority': 'high',
    },
    {
      'student': 'Alex Thompson',
      'assignment': 'Literature: Poetry Analysis',
      'submitted': '6 hours ago',
      'status': 'graded',
      'grade': 'A',
      'avatar': 'AT',
      'subject': 'Literature',
      'dueDate': 'Due today',
      'priority': 'medium',
    },
  ];

  List<Map<String, dynamic>> get _filteredSubmissions {
    if (_selectedFilter == 0) return _submissions;
    if (_selectedFilter == 1) {
      return _submissions.where((s) => s['status'] == 'pending').toList();
    }
    return _submissions.where((s) => s['status'] == 'graded').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: const Text(
          'Review Submissions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: _getTextColor()),
            onPressed: _searchSubmissions,
          ),
          IconButton(
            icon: Icon(Icons.sort, color: _getTextColor()),
            onPressed: _sortSubmissions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview
          _buildStatsSection(),

          // Filter Chips
          _buildFilterSection(),

          // Submissions List
          Expanded(
            child: _filteredSubmissions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSubmissions.length,
                    itemBuilder: (context, index) {
                      return _buildSubmissionCard(_filteredSubmissions[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _quickGrade,
        backgroundColor: _getPrimaryColor(),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.edit_document),
      ),
    );
  }

  Widget _buildStatsSection() {
    final pendingCount =
        _submissions.where((s) => s['status'] == 'pending').length;
    final gradedCount =
        _submissions.where((s) => s['status'] == 'graded').length;
    final overdueCount = _submissions
        .where((s) =>
            s['dueDate']?.contains('ago') == true && s['status'] == 'pending')
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getPrimaryColor().withOpacity(0.1),
            _getPrimaryColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            pendingCount.toString(),
            'Pending',
            Icons.pending_actions_rounded,
            Colors.orange,
          ),
          _buildStatItem(
            gradedCount.toString(),
            'Graded',
            Icons.assignment_turned_in_rounded,
            Colors.green,
          ),
          _buildStatItem(
            overdueCount.toString(),
            'Overdue',
            Icons.warning_amber_rounded,
            Colors.red,
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
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _getTextColor().withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: _selectedFilter == index,
              label: Text(_filters[index]),
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = index;
                });
              },
              backgroundColor: _getCardColor(),
              selectedColor: _getPrimaryColor(),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color:
                    _selectedFilter == index ? Colors.white : _getTextColor(),
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: _getBorderColor()),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission) {
    final isPending = submission['status'] == 'pending';
    final priorityColor = _getPriorityColor(submission['priority']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isPending ? priorityColor.withOpacity(0.3) : _getBorderColor(),
          width: isPending ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _viewSubmission(submission),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with priority indicator
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getSubjectColor(submission['subject'])
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getSubjectColor(submission['subject'])
                              .withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          submission['avatar'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getSubjectColor(submission['subject']),
                          ),
                        ),
                      ),
                    ),
                    if (isPending)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: _getCardColor(), width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              submission['student'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getTextColor(),
                              ),
                            ),
                          ),
                          _buildStatusBadge(submission),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        submission['assignment'],
                        style: TextStyle(
                          fontSize: 16,
                          color: _getTextColor().withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 14,
                              color: _getTextColor().withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text(
                            submission['submitted'],
                            style: TextStyle(
                              fontSize: 12,
                              color: _getTextColor().withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.calendar_today_rounded,
                              size: 14,
                              color: _getTextColor().withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text(
                            submission['dueDate'],
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDueDateColor(submission['dueDate']),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (isPending) _buildActionButtons(submission),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> submission) {
    final isPending = submission['status'] == 'pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPending
            ? Colors.orange.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending ? Colors.orange : Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending ? Icons.pending_rounded : Icons.check_circle_rounded,
            size: 14,
            color: isPending ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            isPending ? 'Pending' : 'Graded ${submission['grade']}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPending ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> submission) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _gradeSubmission(submission),
            icon: const Icon(Icons.grading_rounded, size: 18),
            label: const Text('Grade Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPrimaryColor(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _viewSubmission(submission),
          icon: Icon(Icons.visibility_rounded,
              color: _getTextColor().withOpacity(0.6)),
          style: IconButton.styleFrom(
            backgroundColor: _getBackgroundColor(),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_rounded,
            size: 80,
            color: _getTextColor().withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 1
                ? 'No Pending Submissions'
                : _selectedFilter == 2
                    ? 'No Graded Submissions'
                    : 'No Submissions Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _getTextColor().withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All caught up! New submissions will appear here.',
            style: TextStyle(
              fontSize: 14,
              color: _getTextColor().withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Mathematics':
        return const Color(0xFF3B82F6);
      case 'Science':
        return const Color(0xFF10B981);
      case 'History':
        return const Color(0xFFF59E0B);
      case 'Physics':
        return const Color(0xFFEF4444);
      case 'Literature':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getDueDateColor(String dueDate) {
    if (dueDate.contains('ago')) return Colors.red;
    if (dueDate.contains('today') || dueDate.contains('tomorrow')) {
      return Colors.orange;
    }
    return _getTextColor().withOpacity(0.6);
  }

  void _gradeSubmission(Map<String, dynamic> submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGradingSheet(submission),
    );
  }

  void _viewSubmission(Map<String, dynamic> submission) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing submission from ${submission['student']}'),
        backgroundColor: _getPrimaryColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _searchSubmissions() {
    // Implement search functionality
  }

  void _sortSubmissions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 16),
            // Add sort options here
          ],
        ),
      ),
    );
  }

  void _quickGrade() {
    // Implement quick grade functionality
  }

  Widget _buildGradingSheet(Map<String, dynamic> submission) {
    return Container(); // Implement grading sheet
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
