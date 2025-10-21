import 'package:flutter/material.dart';

class LiveSession extends StatefulWidget {
  const LiveSession({super.key});

  @override
  State<LiveSession> createState() => _LiveSessionState();
}

class _LiveSessionState extends State<LiveSession> {
  bool _isMuted = true;
  bool _cameraOn = false;

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
          'Math Help Session',
          style: TextStyle(color: _getTextColor()),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              Icon(Icons.people, color: _getTextColor()),
              const SizedBox(width: 4),
              Text(
                '25',
                style: TextStyle(
                  color: _getTextColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Main Speaker
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[600],
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'MR. JOHNSON',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Host',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Student View
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[600],
                            child: const Icon(
                              Icons.person,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'SARAH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'You',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Participants List
          Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCardColor(),
              border: Border(top: BorderSide(color: _getBorderColor())),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👥 Participants (25)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      _buildParticipantItem('Mr. Johnson (Host)'),
                      _buildParticipantItem('Sarah (You)'),
                      _buildParticipantItem('Mike'),
                      _buildParticipantItem('Lisa'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getCardColor(),
              border: Border(top: BorderSide(color: _getBorderColor())),
            ),
            child: Column(
              children: [
                // Main Actions
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionButton('✋ Raise Hand', Icons.back_hand),
                    _buildActionButton('❤️ React', Icons.favorite_border),
                    _buildToggleButton(
                      '📹 Camera',
                      Icons.videocam,
                      Icons.videocam_off,
                      _cameraOn,
                      (value) => setState(() => _cameraOn = value),
                    ),
                    _buildToggleButton(
                      '🎤 Mute',
                      Icons.mic,
                      Icons.mic_off,
                      !_isMuted,
                      (value) => setState(() => _isMuted = !value),
                    ),
                    _buildActionButton('Share', Icons.share),
                  ],
                ),
                const SizedBox(height: 16),

                // Bottom Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.record_voice_over),
                        label: const Text('Record Session'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _getTextColor(),
                          side: BorderSide(color: _getBorderColor()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Leave'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Colors.green, size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 14, color: _getTextColor()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getCardColor(),
        foregroundColor: _getTextColor(),
        side: BorderSide(color: _getBorderColor()),
      ),
    );
  }

  Widget _buildToggleButton(
    String text,
    IconData activeIcon,
    IconData inactiveIcon,
    bool isActive,
    ValueChanged<bool> onChanged,
  ) {
    return ElevatedButton.icon(
      onPressed: () => onChanged(!isActive),
      icon: Icon(isActive ? activeIcon : inactiveIcon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF4CAF50) : _getCardColor(),
        foregroundColor: isActive ? Colors.white : _getTextColor(),
        side: BorderSide(color: _getBorderColor()),
      ),
    );
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
