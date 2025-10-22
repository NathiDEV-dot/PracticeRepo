import 'package:flutter/material.dart';
import 'dart:io';
import 'video_editor.dart'; // Add this import

class LessonCreation extends StatefulWidget {
  const LessonCreation({super.key});

  @override
  State<LessonCreation> createState() => _LessonCreationState();
}

class _LessonCreationState extends State<LessonCreation> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController(text: 'Mathematics');
  final _durationController = TextEditingController(text: '45 mins');

  File? _selectedVideo;
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingTime = const Duration();
  final Map<String, bool> _selectedGrades = {
    'Grade 10A': false,
    'Grade 10B': false,
    'Grade 11A': false,
    'Grade 11B': false,
    'Grade 12A': false,
    'All Students': false,
  };

  // Professional color palette
  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _successColor = const Color(0xFF10B981);
  final Color _warningColor = const Color(0xFFF59E0B);
  final Color _errorColor = const Color(0xFFEF4444);
  final Color _infoColor = const Color(0xFF3B82F6);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCardColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getBorderColor()),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: _getTextColor(), size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Create New Lesson',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _getTextColor(),
          letterSpacing: -0.3,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.help_outline_rounded,
                  color: _primaryColor, size: 20),
            ),
            onPressed: _showHelp,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          const SizedBox(height: 32),

          // Lesson Information Section
          _buildSectionHeader(
            'Lesson Information',
            Icons.info_outline_rounded,
            _infoColor,
          ),
          const SizedBox(height: 20),
          _buildLessonInfoForm(),
          const SizedBox(height: 32),

          // Video Section
          _buildSectionHeader(
            'Video Content',
            Icons.videocam_rounded,
            _primaryColor,
          ),
          const SizedBox(height: 20),
          _buildVideoOptions(),
          const SizedBox(height: 32),

          // Audience Section
          _buildSectionHeader(
            'Target Audience',
            Icons.people_alt_rounded,
            _successColor,
          ),
          const SizedBox(height: 20),
          _buildGradeSelection(),
          const SizedBox(height: 32),

          // Scheduling Section
          _buildSectionHeader(
            'Scheduling',
            Icons.schedule_rounded,
            _warningColor,
          ),
          const SizedBox(height: 20),
          _buildSchedulingOptions(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _calculateProgress(),
              backgroundColor: _getBorderColor(),
              color: _primaryColor,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lesson Creation Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getTextColor().withOpacity(0.7),
              ),
            ),
            Text(
              '${(_calculateProgress() * 100).round()}% Complete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _getTextColor(),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonInfoForm() {
    return Column(
      children: [
        _buildFormField(
          label: 'Lesson Title',
          hintText: 'Advanced Calculus: Derivatives & Applications',
          controller: _titleController,
          icon: Icons.title_rounded,
          maxLines: 1,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'Description (Optional)',
          hintText: 'Describe the lesson content and learning objectives...',
          controller: _descriptionController,
          icon: Icons.description_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Subject',
                hintText: 'Mathematics',
                controller: _subjectController,
                icon: Icons.category_rounded,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                label: 'Duration',
                hintText: '45 mins',
                controller: _durationController,
                icon: Icons.timer_rounded,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: _getTextColor().withOpacity(0.4),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _getBorderColor()),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _getBorderColor()),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            filled: true,
            fillColor: _getCardColor(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon:
                Icon(icon, color: _getTextColor().withOpacity(0.5), size: 20),
          ),
          style: TextStyle(
            color: _getTextColor(),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoOptions() {
    return Column(
      children: [
        // Video Preview
        if (_selectedVideo != null) _buildVideoPreview(),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: _buildVideoOptionCard(
                'Upload Video',
                Icons.upload_rounded,
                _infoColor,
                'Choose from gallery',
                onTap: _uploadVideo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVideoOptionCard(
                'Record Video',
                Icons.videocam_rounded,
                _errorColor,
                'Use camera',
                onTap: _openCamera,
              ),
            ),
          ],
        ),

        // Recording Controls (shown only when recording)
        if (_isRecording) ...[
          const SizedBox(height: 20),
          _buildRecordingInterface(),
        ],

        // Edit Button (shown when video is selected)
        if (_selectedVideo != null) ...[
          const SizedBox(height: 16),
          _buildEditButton(),
        ],
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor().withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Video thumbnail placeholder
            Container(
              color: _primaryColor.withOpacity(0.1),
              child: const Icon(Icons.videocam_rounded,
                  size: 60, color: Colors.grey),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDuration(const Duration(
                      minutes: 5, seconds: 23)), // Example duration
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Video Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoOptionCard(
      String title, IconData icon, Color color, String subtitle,
      {VoidCallback? onTap}) {
    return Material(
      color: _getCardColor(),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBorderColor().withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: _getTextColor().withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingInterface() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _isPaused ? 'RECORDING PAUSED' : '● RECORDING LIVE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _isPaused ? _warningColor : _errorColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDuration(_recordingTime),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'RobotoMono',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                Icons.stop_rounded,
                'Stop',
                _errorColor,
                onTap: _stopRecording,
                size: 60,
              ),
              const SizedBox(width: 20),
              _buildControlButton(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                _isPaused ? 'Resume' : 'Pause',
                _warningColor,
                onTap: _isPaused ? _resumeRecording : _pauseRecording,
                size: 60,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openVideoEditor,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: const Text(
          'Edit Video',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, Color color,
      {VoidCallback? onTap, double size = 50}) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: size * 0.5),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _selectedGrades.entries.map((entry) {
        final isSelected = entry.value;
        return FilterChip(
          label: Text(
            entry.key,
            style: TextStyle(
              color: isSelected ? _primaryColor : _getTextColor(),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedGrades[entry.key] = selected;
            });
          },
          backgroundColor: _getCardColor(),
          selectedColor: _primaryColor.withOpacity(0.1),
          checkmarkColor: _primaryColor,
          side: BorderSide(
            color: isSelected ? _primaryColor : _getBorderColor(),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildSchedulingOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildScheduleOption(
                'Publish Now',
                Icons.play_arrow_rounded,
                _successColor,
                onTap: () => _scheduleLesson(immediate: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildScheduleOption(
                'Schedule Later',
                Icons.schedule_rounded,
                _warningColor,
                onTap: () => _scheduleLesson(immediate: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleOption(String title, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return Material(
      color: _getCardColor(),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBorderColor().withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _getTextColor(),
                side: BorderSide(color: _getBorderColor()),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canSave() ? _saveLesson : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _canSave() ? _primaryColor : _primaryColor.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Save Lesson',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Video Methods
  void _uploadVideo() async {
    // Simulate video upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening gallery to select video...'),
        backgroundColor: _infoColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Simulate file selection
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _selectedVideo = File('/path/to/selected/video.mp4'); // Simulated file
    });
  }

  void _openCamera() async {
    // Navigate to full-screen camera
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraRecordingPage(),
        fullscreenDialog: true,
      ),
    );

    if (result != null && result is File) {
      setState(() {
        _selectedVideo = result;
      });
    }
  }

  void _openVideoEditor() {
    // Navigate to video editor page using named route
    Navigator.pushNamed(context, '/educator/video-editor');
  }

  // Recording Methods
  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingTime = const Duration();
    });
    _startTimer();
  }

  void _pauseRecording() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeRecording() {
    setState(() {
      _isPaused = false;
    });
    _startTimer();
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
    // Simulate saving recorded video
    _selectedVideo = File('/path/to/recorded/video.mp4');
  }

  void _startTimer() {
    if (_isRecording && !_isPaused) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isRecording && !_isPaused && mounted) {
          setState(() {
            _recordingTime += const Duration(seconds: 1);
          });
          _startTimer();
        }
      });
    }
  }

  // Helper Methods
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  double _calculateProgress() {
    double progress = 0.0;
    if (_titleController.text.isNotEmpty) progress += 0.3;
    if (_selectedGrades.values.any((selected) => selected)) progress += 0.3;
    if (_selectedVideo != null) progress += 0.4;
    return progress.clamp(0.0, 1.0);
  }

  bool _canSave() {
    return _titleController.text.isNotEmpty &&
        _selectedGrades.values.any((selected) => selected) &&
        _selectedVideo != null;
  }

  // Action Methods
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lesson Creation Help'),
        content: const Text(
            'Fill in all required fields, add video content (upload or record), select target audience, and schedule when to publish.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _scheduleLesson({bool immediate = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(immediate
            ? 'Lesson will be published immediately'
            : 'Lesson scheduled for later'),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _saveLesson() {
    if (_canSave()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lesson saved successfully!'),
          backgroundColor: _successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // Theme Methods
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

// Full-screen Camera Recording Page
class CameraRecordingPage extends StatefulWidget {
  const CameraRecordingPage({super.key});

  @override
  State<CameraRecordingPage> createState() => _CameraRecordingPageState();
}

class _CameraRecordingPageState extends State<CameraRecordingPage> {
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingTime = const Duration();
  bool _flashOn = false;
  bool _frontCamera = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    _formatDuration(_recordingTime),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _flashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),

            // Camera Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[900],
                ),
                child: const Center(
                  child: Icon(Icons.videocam_rounded,
                      size: 80, color: Colors.white54),
                ),
              ),
            ),

            // Recording Indicator
            if (_isRecording) ...[
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'RECORDING',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Controls
            Container(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Flip
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios_rounded,
                        color: Colors.white, size: 28),
                    onPressed: _flipCamera,
                  ),

                  // Record Button
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isRecording ? Colors.red : Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Pause/Resume
                  if (_isRecording)
                    IconButton(
                      icon: Icon(
                        _isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                    )
                  else
                    const SizedBox(width: 48), // Placeholder for spacing
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
    });
    _startTimer();
  }

  void _pauseRecording() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeRecording() {
    setState(() {
      _isPaused = false;
    });
    _startTimer();
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
    // Return the recorded video file
    Navigator.pop(context, File('/path/to/recorded/video.mp4'));
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  void _flipCamera() {
    setState(() {
      _frontCamera = !_frontCamera;
    });
  }

  void _startTimer() {
    if (_isRecording && !_isPaused) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isRecording && !_isPaused && mounted) {
          setState(() {
            _recordingTime += const Duration(seconds: 1);
          });
          _startTimer();
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
