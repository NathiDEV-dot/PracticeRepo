# SignSync Academy 📚

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

**A mobile learning platform designed specifically for Deaf students and educators using South African Sign Language (SASL)**

</div>

## 🌟 Overview

SignSync Academy is a Flutter-based mobile application that provides an accessible learning environment for the Deaf community. The platform eliminates communication barriers by using SASL videos as the primary medium for all educational content and interactions.

## 🎯 Key Features

### 👨‍🏫 Educator Features
- **Video Lesson Creation** - Record, edit, and publish SASL lessons
- **Content Management** - Organize lessons into classes and folders
- **Live Sessions** - Host real-time video tutoring sessions
- **Assignment Review** - Provide visual feedback using stars and stickers
- **Progress Tracking** - Monitor student engagement and completion

### 👨‍🎓 Student Features
- **Icon-Based Navigation** - Intuitive visual interface
- **Video Lessons** - Watch SASL content with playback controls
- **Assignment Submission** - Record and submit video responses
- **Live Participation** - Join interactive sessions
- **Progress Dashboard** - Track learning journey

### 👨‍👦 Parent Features
- **Progress Monitoring** - View child's assignments and feedback
- **Content Access** - See assigned materials and educator comments
- **View-Only Portal** - Monitor without interfering

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.13.0 or higher)
- Dart (3.1.0 or higher)
- Supabase account
- iOS/Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/signsync-academy.git
   cd signsync-academy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new project at [Supabase](https://supabase.com)
   - Run the SQL schema from `database/schema.sql`
   - Update `lib/core/constants/supabase_config.dart` with your credentials

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/          # App configuration
│   ├── services/          # Business logic & API calls
│   └── widgets/           # Reusable components
├── models/               # Data models
├── pages/
│   ├── shared/           # Common screens
│   │   ├── splash_screen.dart
│   │   └── welcome_screen.dart
│   ├── educator/         # Educator-specific screens
│   │   ├── auth_screen.dart
│   │   ├── dashboard.dart
│   │   ├── lesson_creation.dart
│   │   ├── video_editor.dart
│   │   ├── content_management.dart
│   │   ├── review_submissions.dart
│   │   └── live_sessions_manage.dart
│   ├── student/          # Student-specific screens
│   │   ├── auth_screen.dart
│   │   ├── dashboard.dart
│   │   ├── lesson_viewer.dart
│   │   ├── homework_submission.dart
│   │   └── live_session.dart
│   └── parent/           # Parent portal
│       ├── auth_screen.dart
│       └── dashboard.dart
├── providers/           # State management
└── main.dart           # App entry point
```

## 📱 Screen Flow

### Authentication Flow
1. `SplashScreen` → `WelcomeScreen` → Role Selection
2. `EducatorAuthScreen` / `StudentAuthScreen` / `ParentAuthScreen`
3. Respective `Dashboard`

### Educator Flow
- `EducatorDashboard` → `LessonCreation` → `VideoEditor`
- `EducatorDashboard` → `ContentManagement`
- `EducatorDashboard` → `ReviewSubmissions`
- `EducatorDashboard` → `LiveSessionsManage`

### Student Flow
- `StudentDashboard` → `LessonViewer`
- `StudentDashboard` → `HomeworkSubmission`
- `StudentDashboard` → `LiveSession`

## 🗄️ Database Schema

### Core Tables
- `profiles` - User accounts and roles
- `classes` - Classroom organization
- `lessons` - Educational content
- `assignments` - Student tasks
- `submissions` - Student work
- `live_sessions` - Real-time interactions

### Storage Buckets
- `videos` - Lesson and submission videos
- `thumbnails` - Video preview images

## 🎥 Video Features

### Recording & Playback
- **1080p Video Recording** - High-quality SASL capture
- **Built-in Editor** - Trim, cut, and enhance videos
- **Digital Zoom** - Emphasize specific signs
- **Compression** - Optimized storage and streaming

### Live Sessions
- **WebRTC Integration** - Real-time video communication
- **Session Recording** - Automatic recording of live sessions
- **Participant Management** - Control session access

## ♿ Accessibility Design

### Visual-First Interface
- **Icon-Driven Navigation** - Minimal text reliance
- **High Contrast** - Clear visual hierarchy
- **Gesture Support** - Intuitive touch interactions
- **Consistent Layout** - Predictable user experience

### SASL-Centric Communication
- **No Audio Dependency** - Pure visual communication
- **No AI-Generated Content** - Authentic human signing
- **Cultural Relevance** - South African Sign Language focus

## 🔧 Development

### Branch Strategy
```bash
# Feature development
git checkout -b feature/feature-name

# Bug fixes
git checkout -b fix/issue-description

# Hotfixes
git checkout -b hotfix/critical-issue
```

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for services

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 📱 Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- South African Deaf community for guidance and feedback
- Flutter team for excellent cross-platform framework
- Supabase for powerful backend infrastructure
- Contributors and testers who help improve the platform

## 📞 Support

For support and questions:
- 📧 Email: support@signsync.academy
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/signsync-academy/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/signsync-academy/discussions)

---

<div align="center">

**Made with ❤️ for the Deaf community**

*Breaking communication barriers through technology*

</div>
