import 'package:flutter/material.dart';

class HomeworkSubmission extends StatefulWidget {
  const HomeworkSubmission({super.key});

  @override
  State<HomeworkSubmission> createState() => _HomeworkSubmissionState();
}

class _HomeworkSubmissionState extends State<HomeworkSubmission> {
  bool _reviewedVideo = false;
  bool _meetsRequirements = false;
  Duration _recordingTime = const Duration(minutes: 3, seconds: 45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Science Lab Report',
          style: TextStyle(color: _getTextColor()),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: _canSubmit() ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canSubmit()
                  ? const Color(0xFF4CAF50)
                  : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Details
            Text(
              '📋 ASSIGNMENT DETAILS:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailItem('Due: Tomorrow, 5:00 PM'),
            _buildDetailItem(
              'Instructions: Record your lab demonstration (5-10 minutes)',
            ),
            const SizedBox(height: 24),

            // Video Recording Section
            Text(
              '🎥 YOUR SUBMISSION:',
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.videocam, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'RECORD VIDEO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Max: 10:00 • Current: ${_formatDuration(_recordingTime)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recording Controls
            Text(
              '📹 RECORDING CONTROLS:',
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
                _buildControlButton('Start', Icons.play_arrow),
                _buildControlButton('Pause', Icons.pause),
                _buildControlButton('Stop', Icons.stop),
                _buildControlButton('Review', Icons.play_circle),
              ],
            ),
            const SizedBox(height: 24),

            // Submission Checklist
            Text(
              '✅ READY TO SUBMIT?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 12),
            _buildCheckboxItem('I have reviewed my video', _reviewedVideo, (
              value,
            ) {
              setState(() => _reviewedVideo = value!);
            }),
            _buildCheckboxItem('This meets requirements', _meetsRequirements, (
              value,
            ) {
              setState(() => _meetsRequirements = value!);
            }),
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

  Widget _buildControlButton(String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getCardColor(),
        foregroundColor: _getTextColor(),
        side: BorderSide(color: _getBorderColor()),
      ),
    );
  }

  Widget _buildCheckboxItem(
    String text,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
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
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  bool _canSubmit() {
    return _reviewedVideo && _meetsRequirements;
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
