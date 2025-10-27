import 'dart:io';

class LessonData {
  String title;
  String subject;
  String grade;
  String durationText;
  String? description;
  File? videoFile;
  String? videoUrl;
  bool publishImmediately;
  DateTime? scheduledDate;
  Duration? videoDuration;

  LessonData({
    this.title = '',
    this.subject = '',
    this.grade = '',
    this.durationText = 'Calculating...',
    this.description,
    this.videoFile,
    this.videoUrl,
    this.publishImmediately = true,
    this.scheduledDate,
    this.videoDuration,
  });

  LessonData copyWith({
    String? title,
    String? description,
    String? subject,
    String? grade,
    String? durationText,
    File? videoFile,
    String? videoUrl,
    bool? publishImmediately,
    DateTime? scheduledDate,
    Duration? videoDuration,
  }) {
    return LessonData(
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      durationText: durationText ?? this.durationText,
      videoFile: videoFile ?? this.videoFile,
      videoUrl: videoUrl ?? this.videoUrl,
      publishImmediately: publishImmediately ?? this.publishImmediately,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      videoDuration: videoDuration ?? this.videoDuration,
    );
  }

  bool get canSave {
    return title.isNotEmpty &&
        subject.isNotEmpty &&
        grade.isNotEmpty &&
        (videoFile != null || videoUrl != null);
  }

  double get progress {
    double progress = 0.0;
    if (title.isNotEmpty) progress += 0.3;
    if (grade.isNotEmpty) progress += 0.3;
    if (videoFile != null || videoUrl != null) progress += 0.4;
    return progress.clamp(0.0, 1.0);
  }
}
