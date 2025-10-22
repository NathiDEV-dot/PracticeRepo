import 'package:flutter/material.dart';

class LessonViewer extends StatefulWidget {
  const LessonViewer({super.key});

  @override
  State<LessonViewer> createState() => _LessonViewerState();
}

class _LessonViewerState extends State<LessonViewer> {
  bool _isPlaying = false;
  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 20),

              // Video Player
              _buildVideoPlayer(isDark),
              const SizedBox(height: 16),

              // Video Controls
              _buildVideoControls(),
              const SizedBox(height: 24),

              // Lesson Details
              _buildLessonDetails(),
              const SizedBox(height: 24),

              // Actions
              _buildActionButtons(),
              const SizedBox(height: 24),

              // Next Lesson
              _buildNextLesson(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Back button with text
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_rounded,
                    size: 18, color: _getTextColor()),
                const SizedBox(width: 8),
                Text(
                  'Algebra Basics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _getTextColor(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Header actions
        Row(
          children: [
            IconButton(
              icon: Icon(
                _isFavorited ? Icons.star : Icons.star_border,
                color: _isFavorited ? const Color(0xFFF6AD55) : _getTextColor(),
              ),
              onPressed: () {
                setState(() {
                  _isFavorited = !_isFavorited;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert_rounded, color: _getTextColor()),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(bool isDark) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_filled_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'Algebra Basics - Video Lesson',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left controls
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.fast_rewind_rounded,
                    color: Colors.white, size: 24),
                onPressed: () {},
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4299E1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.fast_forward_rounded,
                    color: Colors.white, size: 24),
                onPressed: () {},
              ),
            ],
          ),
          // Right controls
          Row(
            children: [
              IconButton(
                icon:
                    Icon(Icons.zoom_in_rounded, color: Colors.white, size: 24),
                onPressed: () {},
              ),
              IconButton(
                icon:
                    Icon(Icons.download_rounded, color: Colors.white, size: 24),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLessonDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Section title
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: const Color(0xFF4299E1), size: 20),
              const SizedBox(width: 10),
              Text(
                'Lesson Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Details grid
          Wrap(
            spacing: 20,
            runSpacing: 15,
            children: [
              _buildDetailItem(Icons.access_time_rounded, 'Duration: 15:30'),
              _buildDetailItem(Icons.school_rounded, 'Educator: Mr. Johnson'),
              _buildDetailItem(
                  Icons.calendar_today_rounded, 'Posted: 2 days ago'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Container(
      width: 200,
      child: Row(
        children: [
          Icon(icon, size: 18, color: _getSecondaryTextColor()),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Section title
          Row(
            children: [
              Icon(Icons.flash_on_rounded,
                  color: const Color(0xFF4299E1), size: 20),
              const SizedBox(width: 10),
              Text(
                'Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Action buttons grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
            children: [
              _buildActionButton('Watch Again', Icons.replay_rounded, true),
              _buildActionButton('Take Notes', Icons.edit_note_rounded, false),
              _buildActionButton(
                  'Ask Question', Icons.help_outline_rounded, false),
              _buildActionButton('Download', Icons.download_rounded, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, bool isPrimary) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: isPrimary ? const Color(0xFF4299E1) : _getActionButtonColor(),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: isPrimary ? Colors.white : _getTextColor()),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isPrimary ? Colors.white : _getTextColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextLesson() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF8FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4299E1), width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.arrow_forward_rounded, color: const Color(0xFF4299E1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Lesson',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getTextColor(),
                  ),
                ),
                Text(
                  'Geometry Concepts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _getTextColor(),
                  ),
                ),
              ],
            ),
          ),
          Material(
            borderRadius: BorderRadius.circular(6),
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {},
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4299E1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: const Color(0xFF4299E1)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0F0F1E)
        : const Color(0xFFF5F7FA);
  }

  Color _getTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF2D3748);
  }

  Color _getSecondaryTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFA0AEC0)
        : const Color(0xFF718096);
  }

  Color _getCardColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E2E)
        : Colors.white;
  }

  Color _getActionButtonColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2D3748)
        : const Color(0xFFEDF2F7);
  }
}
