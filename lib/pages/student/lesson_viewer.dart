import 'package:flutter/material.dart';

class LessonViewer extends StatefulWidget {
  const LessonViewer({super.key});

  @override
  State<LessonViewer> createState() => _LessonViewerState();
}

class _LessonViewerState extends State<LessonViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Algebra Basics', style: TextStyle(color: _getTextColor())),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.star_border, color: _getTextColor()),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notes, color: _getTextColor()),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_filled,
                    size: 60,
                    color: Colors.white.withAlpha((0.7 * 255).round()),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VIDEO PLAYER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Video Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.fast_rewind, color: _getTextColor()),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.pause_circle_filled,
                    color: _getTextColor(),
                    size: 40,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.fast_forward, color: _getTextColor()),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.zoom_in, color: _getTextColor()),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.download, color: _getTextColor()),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Lesson Details
            Text(
              '📝 LESSON DETAILS:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailItem('Duration: 15:30'),
            _buildDetailItem('Educator: Mr. Johnson'),
            _buildDetailItem('Posted: 2 days ago'),
            const SizedBox(height: 24),

            // Actions
            Text(
              '🎯 ACTIONS:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton('Watch Again', Icons.replay),
                _buildActionButton('Take Notes', Icons.edit_note),
                _buildActionButton('Ask Question', Icons.question_answer),
                _buildActionButton('Download', Icons.download),
              ],
            ),
            const SizedBox(height: 24),

            // Next Lesson
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getCardColor(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getBorderColor()),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_forward, color: _getTextColor()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '➡️ NEXT:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: _getTextColor()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: _getTextColor(),
        side: BorderSide(color: _getBorderColor()),
      ),
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
