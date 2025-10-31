// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/video_editor_service.dart';

class VideoEditor extends StatefulWidget {
  final String filePath;

  const VideoEditor({super.key, required this.filePath});

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  late VideoPlayerController _videoController;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isExporting = false;
  double _exportProgress = 0.0;

  // Editing state
  Duration _trimStart = Duration.zero;
  Duration _trimEnd = Duration.zero;
  final List<Duration> _cutMarkers = [];
  double _playbackSpeed = 1.0;
  final List<Map<String, Duration>> _selectedSegments = [];

  // Service instance
  final VideoEditorService _videoService = VideoEditorService();

  // Video info
  Map<String, dynamic> _videoInfo = {};

  double get _videoProgress {
    if (!_isInitialized ||
        _videoController.value.duration.inMilliseconds == 0) {
      return 0.0;
    }
    return _videoController.value.position.inMilliseconds /
        _videoController.value.duration.inMilliseconds;
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadVideoInfo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.file(File(widget.filePath));
      await _videoController.initialize();
      _videoController.addListener(_videoListener);

      setState(() {
        _isInitialized = true;
        _trimEnd = _videoController.value.duration;
      });

      _videoController.play();
      _isPlaying = true;
    } catch (e) {
      _showSnackBar('Error loading video: $e');
    }
  }

  Future<void> _loadVideoInfo() async {
    try {
      final info = await _videoService.getVideoInfo(widget.filePath);
      setState(() {
        _videoInfo = info;
      });
    } catch (e) {
      print('Error loading video info: $e');
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  // Video processing methods
  Future<void> _trimVideo() async {
    if (!_isInitialized) return;

    if (_trimStart == Duration.zero &&
        _trimEnd == _videoController.value.duration) {
      _showSnackBar('No trim points set');
      return;
    }

    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
    });

    try {
      final String? outputPath = await _videoService.trimVideoWithFFmpeg(
        inputPath: widget.filePath,
        startTime: _trimStart,
        duration: _trimEnd - _trimStart,
      );

      setState(() {
        _isExporting = false;
      });

      if (outputPath != null) {
        _showSnackBar('Video trimmed successfully!');
        if (mounted) {
          Navigator.pop(context, outputPath);
        }
      } else {
        _showSnackBar('Failed to trim video');
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      _showSnackBar('Error trimming video: $e');
    }
  }

  Future<void> _compressVideo() async {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
    });

    try {
      final MediaInfo? mediaInfo = await _videoService.compressVideo(
        inputPath: widget.filePath,
        quality: VideoQuality.MediumQuality,
      );

      setState(() {
        _isExporting = false;
      });

      if (mediaInfo?.file != null) {
        _showSnackBar('Video compressed successfully!');
        if (mounted) {
          Navigator.pop(context, mediaInfo!.file!.path);
        }
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      _showSnackBar('Error compressing video: $e');
    }
  }

  Future<void> _changeSpeedWithService() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final String? outputPath = await _videoService.changePlaybackSpeed(
        inputPath: widget.filePath,
        speed: _playbackSpeed,
      );

      setState(() {
        _isExporting = false;
      });

      if (outputPath != null) {
        _showSnackBar('Speed changed successfully!');
        if (mounted) {
          Navigator.pop(context, outputPath);
        }
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      _showSnackBar('Error changing speed: $e');
    }
  }

  Future<void> _extractSelectedSegments() async {
    if (_selectedSegments.isEmpty) {
      _showSnackBar('No segments selected');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final String? outputPath = await _videoService.extractVideoSegment(
        inputPath: widget.filePath,
        segments: _selectedSegments,
      );

      setState(() {
        _isExporting = false;
      });

      if (outputPath != null) {
        _showSnackBar('Segments extracted successfully!');
        if (mounted) {
          Navigator.pop(context, outputPath);
        }
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      _showSnackBar('Error extracting segments: $e');
    }
  }

  void _changePlaybackSpeed(double speed) async {
    if (!_isInitialized) return;

    setState(() {
      _playbackSpeed = speed;
    });
    await _videoController.setPlaybackSpeed(speed);
    _showSnackBar('Playback speed: ${speed}x');
  }

  void _setTrimStart() {
    if (!_isInitialized) return;

    setState(() {
      _trimStart = _videoController.value.position;
    });
    _showSnackBar(
        'Trim start set to ${_videoService.formatDuration(_trimStart)}');
  }

  void _setTrimEnd() {
    if (!_isInitialized) return;

    setState(() {
      _trimEnd = _videoController.value.position;
    });
    _showSnackBar('Trim end set to ${_videoService.formatDuration(_trimEnd)}');
  }

  void _addCutMarker() {
    if (!_isInitialized) return;

    setState(() {
      _cutMarkers.add(_videoController.value.position);
    });
    _showSnackBar(
        'Cut marker added at ${_videoService.formatDuration(_videoController.value.position)}');
  }

  void _addSegment() {
    if (!_isInitialized) return;

    setState(() {
      _selectedSegments.add({
        'start': _trimStart,
        'end': _trimEnd,
      });
    });
    _showSnackBar(
        'Segment added from ${_videoService.formatDuration(_trimStart)} to ${_videoService.formatDuration(_trimEnd)}');
  }

  void _seekToMarker(Duration marker) {
    if (!_isInitialized) return;
    _videoController.seekTo(marker);
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;

    setState(() {
      if (_isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _seekToPosition(double progress) {
    if (!_isInitialized) return;

    final duration = _videoController.value.duration;
    final position = duration * progress;
    _videoController.seekTo(position);
  }

  void _clearAllMarkers() {
    setState(() {
      _cutMarkers.clear();
      _selectedSegments.clear();
      _trimStart = Duration.zero;
      _trimEnd = _videoController.value.duration;
    });
    _showSnackBar('All markers cleared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: _buildAppBar(),
      body: !_isInitialized ? _buildLoadingState() : _buildEditorInterface(),
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
        onPressed: _isExporting ? null : () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video Editor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _getTextColor(),
            ),
          ),
          if (_videoInfo.isNotEmpty)
            Text(
              '${_videoService.formatFileSize(_videoInfo['fileSize'] ?? 0)} • ${_videoService.formatDuration(Duration(milliseconds: _videoInfo['duration']?.toInt() ?? 0))}',
              style: TextStyle(
                fontSize: 12,
                color: _getTextColor().withOpacity(0.6),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        if (_isExporting)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _primaryColor),
                ),
                const SizedBox(width: 8),
                Text('Processing...', style: TextStyle(color: _getTextColor())),
              ],
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _trimVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.done_rounded, size: 18),
              label: const Text('Export'),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading video...',
            style: TextStyle(color: _getTextColor(), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorInterface() {
    return Column(
      children: [
        // Video Preview
        Expanded(
          flex: 4,
          child: _buildVideoPreview(),
        ),

        // Timeline & Progress
        Expanded(
          flex: 2,
          child: _buildTimelineSection(),
        ),

        // Editing Tools
        Expanded(
          flex: 3,
          child: _buildEditingTools(),
        ),

        // Export Progress
        if (_isExporting) _buildExportProgress(),
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
            AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            ),

            // Play/Pause Overlay
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

            // Top Info Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Speed Indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_playbackSpeed}x',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
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
                      '${_videoService.formatDuration(_videoController.value.position)} / ${_videoService.formatDuration(_videoController.value.duration)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'RobotoMono'),
                    ),
                  ),
                ],
              ),
            ),

            // Trim Indicators
            if (_trimStart > Duration.zero ||
                _trimEnd < _videoController.value.duration)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_trimStart > Duration.zero)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Start: ${_videoService.formatDuration(_trimStart)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (_trimEnd < _videoController.value.duration)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'End: ${_videoService.formatDuration(_trimEnd)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
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

  Widget _buildTimelineSection() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Timeline',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _getTextColor())),
              IconButton(
                icon: Icon(Icons.clear_all,
                    color: _getTextColor().withOpacity(0.6)),
                onPressed: _clearAllMarkers,
                tooltip: 'Clear all markers',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Timeline visualization
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _getCardColor(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getBorderColor().withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (details) {
                        final box = context.findRenderObject() as RenderBox?;
                        if (box == null) return;

                        final localPosition =
                            box.globalToLocal(details.globalPosition);
                        final width = box.size.width;
                        final progress =
                            (localPosition.dx / width).clamp(0.0, 1.0);
                        _seekToPosition(progress);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Stack(
                          children: [
                            // Timeline Background
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[400]!,
                                    Colors.grey[600]!,
                                    Colors.grey[400]!
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),

                            // Trim area
                            if (_trimStart > Duration.zero ||
                                _trimEnd < _videoController.value.duration)
                              Positioned(
                                left: (_trimStart.inMilliseconds /
                                        _videoController
                                            .value.duration.inMilliseconds) *
                                    (screenWidth - 64),
                                right: (1 -
                                        (_trimEnd.inMilliseconds /
                                            _videoController.value.duration
                                                .inMilliseconds)) *
                                    (screenWidth - 64),
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _primaryColor.withOpacity(0.3),
                                    border: Border.all(color: _primaryColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),

                            // Progress
                            Container(
                              height: 40,
                              width: (screenWidth - 64) * _videoProgress,
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),

                            // Cut Markers
                            ..._cutMarkers.map((marker) {
                              if (_videoController
                                      .value.duration.inMilliseconds ==
                                  0) {
                                return const SizedBox.shrink();
                              }
                              final position = marker.inMilliseconds /
                                  _videoController
                                      .value.duration.inMilliseconds;
                              return Positioned(
                                left: (screenWidth - 64) * position,
                                top: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => _seekToMarker(marker),
                                  child: Container(
                                    width: 4,
                                    color: Colors.red,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.place,
                                            color: Colors.white, size: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Time labels
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_videoService.formatDuration(_trimStart),
                            style: TextStyle(
                                fontSize: 12, color: _getTextColor())),
                        Text(_videoService.formatDuration(_trimEnd),
                            style: TextStyle(
                                fontSize: 12, color: _getTextColor())),
                      ],
                    ),
                  ),

                  // Segments list
                  if (_selectedSegments.isNotEmpty)
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedSegments.length,
                        itemBuilder: (context, index) {
                          final segment = _selectedSegments[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Text(
                              '${_videoService.formatDuration(segment['start']!)}-${_videoService.formatDuration(segment['end']!)}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600),
                            ),
                          );
                        },
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

  Widget _buildEditingTools() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(),
        border: Border(top: BorderSide(color: _getBorderColor())),
      ),
      child: Column(
        children: [
          // Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolButton(Icons.play_arrow, 'Play/Pause', _togglePlayPause,
                  _primaryColor),
              _buildToolButton(
                  Icons.content_cut, 'Trim Start', _setTrimStart, Colors.green),
              _buildToolButton(
                  Icons.content_cut, 'Trim End', _setTrimEnd, Colors.red),
              _buildToolButton(
                  Icons.add, 'Add Marker', _addCutMarker, Colors.orange),
              _buildToolButton(
                  Icons.segment, 'Add Segment', _addSegment, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // Speed Control
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Speed:',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: _getTextColor())),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                      return ChoiceChip(
                        label: Text('${speed}x'),
                        selected: _playbackSpeed == speed,
                        onSelected: (_) => _changePlaybackSpeed(speed),
                        selectedColor: _primaryColor,
                        labelStyle: TextStyle(
                          color: _playbackSpeed == speed
                              ? Colors.white
                              : _getTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Export Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _trimVideo,
                icon: const Icon(Icons.cut),
                label: const Text('Trim'),
                style: _getButtonStyle(),
              ),
              ElevatedButton.icon(
                onPressed: _compressVideo,
                icon: const Icon(Icons.compress),
                label: const Text('Compress'),
                style: _getButtonStyle(),
              ),
              if (_selectedSegments.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _extractSelectedSegments,
                  icon: const Icon(Icons.content_cut),
                  label: const Text('Extract Segments'),
                  style: _getButtonStyle(backgroundColor: Colors.orange),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _getButtonStyle({Color? backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? _primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildToolButton(
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
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getTextColor()),
        ),
      ],
    );
  }

  Widget _buildExportProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(),
        border: Border(top: BorderSide(color: _getBorderColor())),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(value: _exportProgress, color: _primaryColor),
          const SizedBox(height: 8),
          Text(
            'Processing: ${(_exportProgress * 100).toStringAsFixed(1)}%',
            style:
                TextStyle(color: _getTextColor(), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Theme colors
  final Color _primaryColor = const Color(0xFF4361EE);

  Color _getBackgroundColor() => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF0A0A14)
      : const Color(0xFFF8FAFF);
  Color _getTextColor() => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF1A202C);
  Color _getCardColor() => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1A1A2E)
      : Colors.white;
  Color _getBorderColor() => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF2D3748)
      : const Color(0xFFE2E8F0);

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    _videoService.dispose();
    super.dispose();
  }
}
