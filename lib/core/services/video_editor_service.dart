import 'dart:io';
import 'dart:math';
import 'package:video_compress/video_compress.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';

class VideoEditorService {
  static final VideoEditorService _instance = VideoEditorService._internal();
  factory VideoEditorService() => _instance;
  VideoEditorService._internal();

  // Video compression and basic editing
  Future<MediaInfo?> compressVideo({
    required String inputPath,
    VideoQuality quality = VideoQuality.MediumQuality,
    bool deleteOrigin = false,
    bool includeAudio = true,
    int? frameRate,
  }) async {
    try {
      return await VideoCompress.compressVideo(
        inputPath,
        quality: quality,
        deleteOrigin: deleteOrigin,
        includeAudio: includeAudio,
        frameRate: frameRate ?? 30, // Provide default value
      );
    } catch (e) {
      throw Exception('Video compression failed: $e');
    }
  }

  // Trim video using video_compress
  Future<MediaInfo?> trimVideo({
    required String inputPath,
    required Duration startTime,
    required Duration endTime,
    VideoQuality quality = VideoQuality.MediumQuality,
  }) async {
    try {
      return await VideoCompress.compressVideo(
        inputPath,
        startTime: startTime.inMilliseconds,
        duration: (endTime - startTime)
            .inMilliseconds, // Use duration instead of endTime
        quality: quality,
        deleteOrigin: false,
        includeAudio: true,
      );
    } catch (e) {
      throw Exception('Video trimming failed: $e');
    }
  }

  // Advanced trimming with FFmpeg (more precise)
  Future<String?> trimVideoWithFFmpeg({
    required String inputPath,
    required Duration startTime,
    required Duration duration,
    String? outputPath,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputFile = File(outputPath ??
          '${tempDir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4');

      final startTimeStr = _formatDurationForFFmpeg(startTime);
      final durationStr = _formatDurationForFFmpeg(duration);

      final command =
          '-i "$inputPath" -ss $startTimeStr -t $durationStr -c copy "${outputFile.path}"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputFile.path;
      } else {
        throw Exception('FFmpeg trimming failed: ${await session.getOutput()}');
      }
    } catch (e) {
      throw Exception('FFmpeg trimming error: $e');
    }
  }

  // Change playback speed
  Future<String?> changePlaybackSpeed({
    required String inputPath,
    required double speed,
    String? outputPath,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputFile = File(outputPath ??
          '${tempDir.path}/speed_${DateTime.now().millisecondsSinceEpoch}.mp4');

      // Speed factor for video and audio
      final videoSpeed = 1.0 / speed;
      final audioSpeed = speed;

      final command =
          '-i "$inputPath" -filter_complex "[0:v]setpts=$videoSpeed*PTS[v];[0:a]atempo=$audioSpeed[a]" -map "[v]" -map "[a]" "${outputFile.path}"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputFile.path;
      } else {
        throw Exception('Speed change failed: ${await session.getOutput()}');
      }
    } catch (e) {
      throw Exception('Speed change error: $e');
    }
  }

  // Extract segment (cut multiple parts)
  Future<String?> extractVideoSegment({
    required String inputPath,
    required List<Map<String, Duration>>
        segments, // [{start: Duration, end: Duration}]
    String? outputPath,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputFile = File(outputPath ??
          '${tempDir.path}/segments_${DateTime.now().millisecondsSinceEpoch}.mp4');

      // Create filter complex for concatenating segments
      final filterComplex = StringBuffer();
      final inputs = StringBuffer();

      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i];
        final start = _formatDurationForFFmpeg(segment['start']!);
        final end = _formatDurationForFFmpeg(segment['end']!);
        final duration =
            _formatDurationForFFmpeg(segment['end']! - segment['start']!);

        filterComplex
            .write('[$i]trim=start=$start:end=$end,setpts=PTS-STARTPTS[v$i];');
        inputs.write('-ss $start -t $duration -i "$inputPath" ');
      }

      // Concatenate all segments
      for (int i = 0; i < segments.length; i++) {
        filterComplex.write('[v$i]');
      }
      filterComplex.write('concat=n=${segments.length}:v=1:a=0[outv]');

      final command =
          '$inputs -filter_complex "$filterComplex" -map "[outv]" "${outputFile.path}"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputFile.path;
      } else {
        throw Exception(
            'Segment extraction failed: ${await session.getOutput()}');
      }
    } catch (e) {
      throw Exception('Segment extraction error: $e');
    }
  }

  // Add watermark to video
  Future<String?> addWatermark({
    required String inputPath,
    required String watermarkPath,
    required String
        position, // 'top-left', 'top-right', 'bottom-left', 'bottom-right', 'center'
    String? outputPath,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputFile = File(outputPath ??
          '${tempDir.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.mp4');

      String overlayPosition;
      switch (position) {
        case 'top-left':
          overlayPosition = '10:10';
          break;
        case 'top-right':
          overlayPosition = 'main_w-overlay_w-10:10';
          break;
        case 'bottom-left':
          overlayPosition = '10:main_h-overlay_h-10';
          break;
        case 'bottom-right':
          overlayPosition = 'main_w-overlay_w-10:main_h-overlay_h-10';
          break;
        case 'center':
          overlayPosition = '(main_w-overlay_w)/2:(main_h-overlay_h)/2';
          break;
        default:
          overlayPosition = '10:10';
      }

      final command =
          '-i "$inputPath" -i "$watermarkPath" -filter_complex "overlay=$overlayPosition" "${outputFile.path}"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputFile.path;
      } else {
        throw Exception(
            'Watermark addition failed: ${await session.getOutput()}');
      }
    } catch (e) {
      throw Exception('Watermark addition error: $e');
    }
  }

  // Extract audio from video
  Future<String?> extractAudio({
    required String inputPath,
    String? outputPath,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputFile = File(outputPath ??
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp3');

      final command = '-i "$inputPath" -q:a 0 -map a "${outputFile.path}"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputFile.path;
      } else {
        throw Exception(
            'Audio extraction failed: ${await session.getOutput()}');
      }
    } catch (e) {
      throw Exception('Audio extraction error: $e');
    }
  }

  // Merge multiple videos
  Future<String?> mergeVideos({
    required List<String> videoPaths,
    String? outputPath,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputFile = File(outputPath ??
          '${tempDir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.mp4');

      // Create file list for concatenation
      final fileList = StringBuffer();
      for (int i = 0; i < videoPaths.length; i++) {
        fileList.writeln("file '${videoPaths[i]}'");
      }

      final listFile = File('${tempDir.path}/file_list.txt');
      await listFile.writeAsString(fileList.toString());

      final command =
          '-f concat -safe 0 -i "${listFile.path}" -c copy "${outputFile.path}"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      // Clean up temporary file
      await listFile.delete();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputFile.path;
      } else {
        throw Exception('Video merging failed: ${await session.getOutput()}');
      }
    } catch (e) {
      throw Exception('Video merging error: $e');
    }
  }

  // Get video information
  Future<Map<String, dynamic>> getVideoInfo(String filePath) async {
    try {
      final mediaInfo = await VideoCompress.getMediaInfo(filePath);

      // Calculate bitrate manually since it's not available in MediaInfo
      double bitrate = 0;
      if (mediaInfo.filesize != null && mediaInfo.duration != null) {
        bitrate = (mediaInfo.filesize! * 8) /
            (mediaInfo.duration! / 1000); // bits per second
      }

      return {
        'path': mediaInfo.path,
        'fileSize': mediaInfo.filesize,
        'duration': mediaInfo.duration,
        'width': mediaInfo.width,
        'height': mediaInfo.height,
        'bitrate': bitrate, // Calculated manually
        'title': mediaInfo.title,
        'author': mediaInfo.author,
      };
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }

  // Get video thumbnail
  Future<File?> getVideoThumbnail(String filePath, {int quality = 75}) async {
    try {
      final thumbnail = await VideoCompress.getFileThumbnail(
        filePath,
        quality: quality,
      );
      return thumbnail;
    } catch (e) {
      throw Exception('Failed to get thumbnail: $e');
    }
  }

  // Get multiple thumbnails for timeline
  Future<List<File>> getVideoThumbnails(
    String filePath, {
    int count = 10,
    int quality = 50,
  }) async {
    try {
      final mediaInfo = await VideoCompress.getMediaInfo(filePath);
      if (mediaInfo.duration == null) return [];

      final List<File> thumbnails = [];
      final interval = mediaInfo.duration! ~/ (count + 1);

      for (int i = 1; i <= count; i++) {
        final position = interval * i;
        final thumbnail = await VideoCompress.getFileThumbnail(
          filePath,
          quality: quality,
          position: position,
        );
        thumbnails.add(thumbnail);
      }

      return thumbnails;
    } catch (e) {
      throw Exception('Failed to get thumbnails: $e');
    }
  }

  // Utility method to format duration for FFmpeg
  String _formatDurationForFFmpeg(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds =
        (duration.inMilliseconds % 1000).toString().padLeft(3, '0');

    return '$hours:$minutes:$seconds.$milliseconds';
  }

  // Format duration for display
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? "$hours:$minutes:$seconds"
        : "$minutes:$seconds";
  }

  // Calculate file size in readable format
  String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Clean up temporary files
  Future<void> cleanup() async {
    await VideoCompress.deleteAllCache();
  }

  // Cancel ongoing operations
  Future<void> cancelCompression() async {
    await VideoCompress.cancelCompression();
  }

  // Dispose resources
  void dispose() {
    cleanup();
  }
}
