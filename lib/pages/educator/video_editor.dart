import 'package:flutter/material.dart';

class VideoEditor extends StatefulWidget {
  final File? videoFile;

  const VideoEditor({super.key, this.videoFile});

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  bool _isPlaying = false;
  bool _enableZoom = false;
  double _zoomLevel = 1.0;
  double _videoProgress = 0.3;
  Duration _currentTime = const Duration(seconds: 45);
  Duration _totalDuration = const Duration(minutes: 2, seconds: 30);

  // Timeline markers for cuts
  final List<double> _cutMarkers = [0.2, 0.5, 0.8];
  double _draggingPosition = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Video Preview with Zoom
          Expanded(
            flex: 4,
            child: _buildVideoPreview(),
          ),

          // Timeline Section
          Expanded(
            flex: 3,
            child: _buildTimelineSection(),
          ),

          // Editing Tools
          _buildEditingTools(),
        ],
      ),
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
        'Video Editor',
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
          child: ElevatedButton.icon(
            onPressed: _exportVideo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.done_rounded, size: 18),
            label: const Text(
              'Export',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Video Background
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_rounded,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Video Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Zoom Overlay
            if (_enableZoom && _zoomLevel > 1.0) _buildZoomOverlay(),

            // Play/Pause Controls
            Positioned.fill(
              child: Center(
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                ),
              ),
            ),

            // Top Controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Zoom Indicator
                  if (_enableZoom)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_zoomLevel.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // Time Indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_formatDuration(_currentTime)} / ${_formatDuration(_totalDuration)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'RobotoMono',
                      ),
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

  Widget _buildZoomOverlay() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Text(
                '${_zoomLevel.toStringAsFixed(1)}x\nZoom',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Timeline Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _getTextColor(),
                ),
              ),
              Text(
                'Drag to scrub • Tap markers to cut',
                style: TextStyle(
                  fontSize: 12,
                  color: _getTextColor().withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Timeline
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _getCardColor(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getBorderColor().withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Timeline Visualization
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (details) => _handleTimelineTap(details),
                      onPanUpdate: (details) => _handleTimelineDrag(details),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Stack(
                          children: [
                            // Timeline Background
                            _buildTimelineBackground(),

                            // Cut Markers
                            ..._buildCutMarkers(),

                            // Progress Indicator (Draggable)
                            _buildProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Time Labels
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_currentTime),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getTextColor(),
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                        Text(
                          _formatDuration(_totalDuration),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getTextColor(),
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineBackground() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[400]!,
            Colors.grey[600]!,
            Colors.grey[400]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  List<Widget> _buildCutMarkers() {
    return _cutMarkers.map((position) {
      return Positioned(
        left: position * (MediaQuery.of(context).size.width - 32),
        top: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () => _deleteCutMarker(position),
          child: Container(
            width: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      left: _draggingPosition * (MediaQuery.of(context).size.width - 32),
      top: 0,
      bottom: 0,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newPosition = _draggingPosition +
                (details.delta.dx / (MediaQuery.of(context).size.width - 32));
            _draggingPosition = newPosition.clamp(0.0, 1.0);
            _videoProgress = _draggingPosition;
            _currentTime = Duration(
                milliseconds:
                    (_totalDuration.inMilliseconds * _videoProgress).round());
          });
        },
        child: Container(
          width: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF4361EE),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4361EE).withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF4361EE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.drag_handle_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingTools() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(),
        border: Border(
          top: BorderSide(color: _getBorderColor()),
        ),
      ),
      child: Column(
        children: [
          // Tool Categories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolCategory(
                  'Cut & Crop', Icons.content_cut_rounded, _buildCutTools()),
              _buildToolCategory(
                  'Zoom', Icons.zoom_in_map_rounded, _buildZoomTools()),
              _buildToolCategory(
                  'Effects', Icons.auto_awesome_rounded, _buildEffectTools()),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildToolCategory(String title, IconData icon, Widget content) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: Icon(icon, color: _primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCutTools() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildToolButton(
            'Split', Icons.call_split_rounded, () => _splitAtCurrentTime()),
        _buildToolButton(
            'Trim Start', Icons.vertical_align_top_rounded, () => _trimStart()),
        _buildToolButton(
            'Trim End', Icons.vertical_align_bottom_rounded, () => _trimEnd()),
        _buildToolButton(
            'Add Marker', Icons.add_rounded, () => _addCutMarker()),
      ],
    );
  }

  Widget _buildZoomTools() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: Text(
                  'Digital Zoom',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
                value: _enableZoom,
                onChanged: (value) {
                  setState(() => _enableZoom = value);
                },
                activeColor: _primaryColor,
              ),
            ),
          ],
        ),
        if (_enableZoom) ...[
          const SizedBox(height: 8),
          Text(
            'Zoom Level: ${_zoomLevel.toStringAsFixed(1)}x',
            style: TextStyle(
              fontSize: 12,
              color: _getTextColor().withOpacity(0.7),
            ),
          ),
          Slider(
            value: _zoomLevel,
            min: 1.0,
            max: 3.0,
            divisions: 20,
            onChanged: (value) {
              setState(() => _zoomLevel = value);
            },
            activeColor: _primaryColor,
          ),
        ],
      ],
    );
  }

  Widget _buildEffectTools() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildToolButton('Brightness', Icons.brightness_6_rounded, () {}),
        _buildToolButton('Contrast', Icons.contrast_rounded, () {}),
        _buildToolButton('Filters', Icons.filter_rounded, () {}),
        _buildToolButton('Speed', Icons.speed_rounded, () {}),
      ],
    );
  }

  Widget _buildToolButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getCardColor(),
        foregroundColor: _getTextColor(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _getBorderColor()),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickActionButton(
          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          _isPlaying ? 'Pause' : 'Play',
          _togglePlayPause,
          _primaryColor,
        ),
        _buildQuickActionButton(
          Icons.content_cut_rounded,
          'Split Here',
          () => _splitAtCurrentTime(),
          const Color(0xFF10B981),
        ),
        _buildQuickActionButton(
          Icons.undo_rounded,
          'Undo',
          _undoAction,
          const Color(0xFFF59E0B),
        ),
        _buildQuickActionButton(
          Icons.redo_rounded,
          'Redo',
          _redoAction,
          const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
      IconData icon, String label, VoidCallback onTap, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 20),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _getTextColor().withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Action Methods
  void _togglePlayPause() {
    setState(() => _isPlaying = !_isPlaying);
  }

  void _splitAtCurrentTime() {
    setState(() {
      _cutMarkers.add(_videoProgress);
      _cutMarkers.sort();
    });
    _showSnackBar('Video split at ${_formatDuration(_currentTime)}');
  }

  void _trimStart() {
    _showSnackBar('Trim start point set');
  }

  void _trimEnd() {
    _showSnackBar('Trim end point set');
  }

  void _addCutMarker() {
    setState(() {
      _cutMarkers.add(_videoProgress);
      _cutMarkers.sort();
    });
    _showSnackBar('Cut marker added');
  }

  void _deleteCutMarker(double position) {
    setState(() {
      _cutMarkers.remove(position);
    });
    _showSnackBar('Cut marker removed');
  }

  void _handleTimelineTap(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final width = box.size.width - 32;
    final newProgress = (localPosition.dx / width).clamp(0.0, 1.0);

    setState(() {
      _videoProgress = newProgress;
      _draggingPosition = newProgress;
      _currentTime = Duration(
          milliseconds:
              (_totalDuration.inMilliseconds * _videoProgress).round());
    });
  }

  void _handleTimelineDrag(DragUpdateDetails details) {
    final width = MediaQuery.of(context).size.width - 32;
    final newPosition = _draggingPosition + (details.delta.dx / width);

    setState(() {
      _draggingPosition = newPosition.clamp(0.0, 1.0);
      _videoProgress = _draggingPosition;
      _currentTime = Duration(
          milliseconds:
              (_totalDuration.inMilliseconds * _videoProgress).round());
    });
  }

  void _undoAction() {
    _showSnackBar('Undo last action');
  }

  void _redoAction() {
    _showSnackBar('Redo last action');
  }

  void _exportVideo() {
    _showSnackBar('Exporting video...');
    // Navigate back when done
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  // Color getters
  final Color _primaryColor = const Color(0xFF4361EE);

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

// File class for compatibility
class File {
  final String path;
  const File(this.path);
}
