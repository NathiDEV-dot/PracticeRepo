import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class StudentDashboard extends StatefulWidget {
  final String username;
  final String role;

  const StudentDashboard({
    super.key,
    required this.username,
    required this.role,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late YoutubePlayerController _controller1;
  late YoutubePlayerController _controller2;
  late YoutubePlayerController _controller3;
  late YoutubePlayerController _controller4;
  late YoutubePlayerController _controller5;

  final List<Lesson> lessons = [
    Lesson(
      id: 1,
      title: 'Lesson 1: Basic Greetings',
      description: 'Learn basic greeting signs in South African Sign Language',
      videoId: 'dQw4w9WgXcQ', // Replace with actual YouTube video ID
    ),
    Lesson(
      id: 2,
      title: 'Lesson 2: Numbers 1-10',
      description: 'Master counting from 1 to 10 in SASL',
      videoId: 'jNQXAC9IVRw', // Replace with actual YouTube video ID
    ),
    Lesson(
      id: 3,
      title: 'Lesson 3: Alphabet & Fingerspelling',
      description: 'Learn the SASL alphabet and fingerspelling',
      videoId: '9bZkp7q19f0', // Replace with actual YouTube video ID
    ),
    Lesson(
      id: 4,
      title: 'Lesson 4: Common Phrases',
      description: 'Everyday phrases and conversations in SASL',
      videoId: 'kffacxfA7g4', // Replace with actual YouTube video ID
    ),
    Lesson(
      id: 5,
      title: 'Lesson 5: Family & Relationships',
      description: 'Signs for family members and relationships',
      videoId: 'L8DMsy0ER740', // Replace with actual YouTube video ID
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controller1 = YoutubePlayerController(
      initialVideoId: lessons[0].videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    _controller2 = YoutubePlayerController(
      initialVideoId: lessons[1].videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    _controller3 = YoutubePlayerController(
      initialVideoId: lessons[2].videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    _controller4 = YoutubePlayerController(
      initialVideoId: lessons[3].videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    _controller5 = YoutubePlayerController(
      initialVideoId: lessons[4].videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SASL Student Dashboard'),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpPagePlaceholder(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $username!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Learn South African Sign Language',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildLessonCard(lessons[0], _controller1),
                  const SizedBox(height: 20),
                  _buildLessonCard(lessons[1], _controller2),
                  const SizedBox(height: 20),
                  _buildLessonCard(lessons[2], _controller3),
                  const SizedBox(height: 20),
                  _buildLessonCard(lessons[3], _controller4),
                  const SizedBox(height: 20),
                  _buildLessonCard(lessons[4], _controller5),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson, YoutubePlayerController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${lesson.title} marked as complete!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mark as Complete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Lesson {
  final int id;
  final String title;
  final String description;
  final String videoId;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.videoId,
  });
}

// Placeholder - replace with actual import
class SignUpPagePlaceholder extends StatelessWidget {
  const SignUpPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
