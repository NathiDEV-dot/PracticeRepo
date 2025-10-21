import 'package:flutter/material.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key});

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  bool _enableZoom = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('EDIT VIDEO', style: TextStyle(color: _getTextColor())),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Preview
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
                  Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getVideoPreviewButtonColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VIDEO PREVIEW',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getLightTextColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timeline
            Text(
              '🎬 TIMELINE:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getCardColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getBorderColor()),
              ),
              child: Column(
                children: [
                  // Timeline segments
                  Expanded(
                    child: Row(
                      children: [
                        _buildTimelineSegment(true),
                        _buildTimelineSegment(true),
                        _buildTimelineSegment(true),
                        _buildTimelineSegment(false),
                        _buildTimelineSegment(false),
                        _buildTimelineSegment(true),
                        _buildTimelineSegment(true),
                        _buildTimelineSegment(true),
                      ],
                    ),
                  ),
                  // Time labels
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0:00',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSecondaryTextColor(),
                        ),
                      ),
                      Text(
                        '3:45',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSecondaryTextColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Editing Tools
            Text(
              '✂️ EDITING TOOLS:',
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
                _buildToolButton('Trim Start', Icons.content_cut),
                _buildToolButton('Trim End', Icons.content_cut),
                _buildToolButton('Split', Icons.call_split),
                _buildToolButton('Zoom Area', Icons.zoom_in),
                _buildToolButton('Delete Segment', Icons.delete),
              ],
            ),
            const SizedBox(height: 24),

            // Zoom Settings
            Text(
              '🔍 ZOOM:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getCardColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getBorderColor()),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _enableZoom,
                    onChanged: (value) {
                      setState(() => _enableZoom = value!);
                    },
                    activeColor: const Color(0xFF667EEA),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enable Digital Zoom',
                      style: TextStyle(fontSize: 14, color: _getTextColor()),
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

  Widget _buildTimelineSegment(bool isFilled) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: isFilled ? const Color(0xFF667EEA) : _getBorderColor(),
          borderRadius: BorderRadius.circular(2),
        ),
        height: 20,
      ),
    );
  }

  Widget _buildToolButton(String text, IconData icon) {
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

  // New method to replace Colors.white.withOpacity(0.2)
  Color _getVideoPreviewButtonColor() {
    return const Color(0xFF333333); // Equivalent to white.withOpacity(0.2)
  }

  // New method to replace Colors.white.withOpacity(0.7)
  Color _getLightTextColor() {
    return const Color(0xFFB3B3B3); // Equivalent to white.withOpacity(0.7)
  }

  // New method to replace .withOpacity(0.6) for secondary text
  Color _getSecondaryTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF999999) // Equivalent to white.withOpacity(0.6)
        : const Color(
            0xFF888888); // Equivalent to Color(0xFF2D3748).withOpacity(0.6)
  }
}
