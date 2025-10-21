import 'package:flutter/material.dart';

class LessonCreation extends StatefulWidget {
  const LessonCreation({super.key});

  @override
  State<LessonCreation> createState() => _LessonCreationState();
}

class _LessonCreationState extends State<LessonCreation> {
  final _titleController = TextEditingController();
  bool _isRecording = false;
  final Duration _recordingTime = const Duration(minutes: 2, seconds: 45);
  final Map<String, bool> _selectedGrades = {
    'Grade 10A': false,
    'Grade 10B': false,
    'Grade 11A': false,
    'All Students': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('CREATE LESSON', style: TextStyle(color: _getTextColor())),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: _canSave() ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _canSave() ? const Color(0xFF667EEA) : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson Title
            Text(
              'Lesson Title:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Mathematics: Algebra',
                hintStyle: TextStyle(color: _getHintColor()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _getBorderColor()),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _getBorderColor()),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF667EEA),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: _getCardColor(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(color: _getTextColor()),
            ),
            const SizedBox(height: 24),

            // Video Recorder
            Text(
              '🎥 VIDEO RECORDER:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
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
                  if (_isRecording) ...[
                    const Icon(
                      Icons.radio_button_checked,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '● RECORDING...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🕐 ${_formatDuration(_recordingTime)}',
                      style: TextStyle(color: _getLightTextColor()),
                    ),
                  ] else ...[
                    Icon(
                      Icons.videocam,
                      size: 60,
                      color: _getLightTextColor(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'READY TO RECORD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getLightTextColor(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recording Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.stop, color: _getTextColor()),
                  onPressed: _isRecording ? _stopRecording : null,
                ),
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.pause : Icons.play_arrow,
                    color: _getTextColor(),
                    size: 40,
                  ),
                  onPressed: _isRecording ? _pauseRecording : _startRecording,
                ),
                IconButton(
                  icon: Icon(Icons.zoom_in, color: _getTextColor()),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.content_cut, color: _getTextColor()),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Assign To
            Text(
              '📁 ASSIGN TO:',
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
              children: _selectedGrades.keys.map((grade) {
                return FilterChip(
                  label: Text(grade),
                  selected: _selectedGrades[grade]!,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGrades[grade] = selected;
                    });
                  },
                  backgroundColor: _getCardColor(),
                  selectedColor: _getSelectedChipColor(),
                  checkmarkColor: const Color(0xFF667EEA),
                  labelStyle: TextStyle(
                    color: _selectedGrades[grade]!
                        ? const Color(0xFF667EEA)
                        : _getTextColor(),
                  ),
                  side: BorderSide(color: _getBorderColor()),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Schedule
            Text(
              '🕐 SCHEDULE:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getTextColor(),
                      side: BorderSide(color: _getBorderColor()),
                    ),
                    child: const Text('Now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getTextColor(),
                      side: BorderSide(color: _getBorderColor()),
                    ),
                    child: const Text('Later'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Calendar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getTextColor(),
                      side: BorderSide(color: _getBorderColor()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.access_time),
                    label: const Text('Time Picker'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getTextColor(),
                      side: BorderSide(color: _getBorderColor()),
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

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
  }

  void _pauseRecording() {
    setState(() {
      _isRecording = false;
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      // Navigate to video editor
      Navigator.pushNamed(context, '/educator/video-editor');
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  bool _canSave() {
    return _titleController.text.isNotEmpty &&
        _selectedGrades.values.any((selected) => selected);
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

  // New method to replace .withAlpha((0.5 * 255).round())
  Color _getHintColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF808080) // Equivalent to white.withOpacity(0.5)
        : const Color(
            0xFF888888); // Equivalent to Color(0xFF2D3748).withOpacity(0.5)
  }

  // New method to replace Colors.white.withAlpha((0.7 * 255).round())
  Color _getLightTextColor() {
    return const Color(0xFFB3B3B3); // Equivalent to white.withOpacity(0.7)
  }

  // New method to replace Color(0xFF667EEA).withAlpha(51)
  Color _getSelectedChipColor() {
    return const Color(0x33667EEA); // 0.2 opacity = 51 alpha = 0x33
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
