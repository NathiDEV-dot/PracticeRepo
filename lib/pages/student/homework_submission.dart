// ignore_for_file: deprecated_member_use

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
  bool _isRecording = false;
  bool _isPaused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDark ? Colors.white : const Color(0xFF475569),
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Science Lab Report',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton(
                  onPressed: _canSubmit() ? _submitAssignment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit()
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF94A3B8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Submit',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Assignment Details
                    _buildSection(
                      icon: Icons.assignment_outlined,
                      title: 'Assignment Details',
                      children: [
                        const SizedBox(height: 16),
                        _buildDetailItem('Due: Tomorrow, 5:00 PM'),
                        _buildDetailItem(
                            'Instructions: Record your lab demonstration (5-10 minutes)'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Your Submission
                    _buildSection(
                      icon: Icons.video_camera_back_rounded,
                      title: 'Your Submission',
                      children: [
                        const SizedBox(height: 16),
                        // Video Recording Area
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF475569),
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
                                Icons.videocam_rounded,
                                size: 48,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Ready to record your lab demonstration',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Recording Status Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _isRecording
                                          ? (_isPaused
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFFEF4444))
                                          : const Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                    child: _isRecording && !_isPaused
                                        ? TweenAnimationBuilder(
                                            tween: Tween(begin: 0.5, end: 1.0),
                                            duration: const Duration(
                                                milliseconds: 1500),
                                            builder: (context, value, child) {
                                              return Opacity(
                                                opacity: value,
                                                child: child,
                                              );
                                            },
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isRecording
                                        ? (_isPaused
                                            ? 'Recording Paused'
                                            : 'Recording in progress')
                                        : 'Ready to Record',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Max: 10:00 • Current: ${_formatDuration(_recordingTime)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Progress Bar
                        Column(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      0.35, // 35% progress
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_recordingTime),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  '10:00',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Recording Controls
                    _buildSection(
                      icon: Icons.control_camera_rounded,
                      title: 'Recording Controls',
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                              'Start',
                              Icons.fiber_manual_record_rounded,
                              _isRecording
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF3B82F6),
                              isPrimary: _isRecording,
                              onTap: _toggleRecording,
                            ),
                            _buildControlButton(
                              _isPaused ? 'Resume' : 'Pause',
                              _isPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              const Color(0xFF6B7280),
                              onTap: _togglePause,
                            ),
                            _buildControlButton(
                              'Stop',
                              Icons.stop_rounded,
                              const Color(0xFFEF4444),
                              onTap: _stopRecording,
                            ),
                            _buildControlButton(
                              'Review',
                              Icons.play_circle_outline_rounded,
                              const Color(0xFF6B7280),
                              onTap: _reviewRecording,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Ready to Submit
                    _buildSection(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Ready to Submit?',
                      children: [
                        const SizedBox(height: 16),
                        _buildChecklistItem(
                          'I have reviewed my video',
                          _reviewedVideo,
                          (value) => setState(() => _reviewedVideo = value!),
                        ),
                        const SizedBox(height: 12),
                        _buildChecklistItem(
                          'This meets assignment requirements',
                          _meetsRequirements,
                          (value) =>
                              setState(() => _meetsRequirements = value!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
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
          // Section Header
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String text,
    IconData icon,
    Color color, {
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isPrimary ? color.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
      String text, bool value, ValueChanged<bool?> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF3B82F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ],
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

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _isPaused = false;
      }
    });
  }

  void _togglePause() {
    if (_isRecording) {
      setState(() {
        _isPaused = !_isPaused;
      });
    }
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _isPaused = false;
      // Simulate recording completion
      _recordingTime = const Duration(minutes: 10);
    });
  }

  void _reviewRecording() {
    // Show dialog or navigate to review screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Recording'),
        content: const Text('Video review functionality would open here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _submitAssignment() {
    if (_canSubmit()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green),
              SizedBox(width: 8),
              Text('Assignment Submitted'),
            ],
          ),
          content: const Text(
              'Your Science Lab Report has been submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
