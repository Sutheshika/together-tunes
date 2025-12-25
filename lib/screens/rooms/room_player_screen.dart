import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/music_player.dart';
import '../../services/audio_service.dart';
import '../../services/mock_music_library.dart';
import '../../services/socket_service.dart';
import 'dart:async';

class RoomPlayerScreen extends StatefulWidget {
  final String roomName;
  final String roomId;
  final bool isHost;
  final List<String> members;

  const RoomPlayerScreen({
    super.key,
    required this.roomName,
    required this.roomId,
    required this.isHost,
    required this.members,
  });

  @override
  State<RoomPlayerScreen> createState() => _RoomPlayerScreenState();
}

class _RoomPlayerScreenState extends State<RoomPlayerScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  List<Map<String, dynamic>> chatMessages = [];
  List<Map<String, String>> currentMembers = [];
  bool isPlayerVisible = true;
  late StreamSubscription _chatSubscription;
  late StreamSubscription _memberUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeRoom();
    _initializeSocketListeners();
    _startMockChat();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    _chatSubscription.cancel();
    _memberUpdateSubscription.cancel();
    SocketService().leaveRoom();
    super.dispose();
  }

  void _initializeSocketListeners() {
    final socketService = SocketService();
    
    // Join the room
    socketService.joinRoom(
      widget.roomId,
      'user_${DateTime.now().millisecondsSinceEpoch}', // Mock user ID
      'You',
    );
    
    // Listen to chat messages
    _chatSubscription = socketService.chatMessageStream.listen((chatData) {
      if (mounted) {
        _addChatMessage(
          chatData['username'],
          chatData['message'],
          chatData['username'] == 'You',
        );
      }
    });
    
    // Listen to member updates
    _memberUpdateSubscription = socketService.memberUpdateStream.listen((memberData) {
      if (mounted && memberData['type'] == 'joined') {
        setState(() {
          currentMembers.add({
            'name': memberData['username'],
            'status': 'online',
          });
        });
      } else if (mounted && memberData['type'] == 'left') {
        setState(() {
          currentMembers.removeWhere((member) => member['name'] == memberData['username']);
        });
      }
    });
  }

  void _initializeRoom() {
    // Initialize members list
    currentMembers = [
      {'name': 'You', 'status': 'online'},
      {'name': 'Sarah Johnson', 'status': 'online'},
      {'name': 'Alex Chen', 'status': 'listening'},
      {'name': 'Mike Wilson', 'status': 'online'},
    ];
    
    // Add some initial chat messages
    chatMessages = [
      {
        'user': 'Sarah Johnson',
        'message': 'Hey everyone! 👋',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'isMe': false,
      },
      {
        'user': 'Alex Chen',
        'message': 'Great song choice!',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
        'isMe': false,
      },
      {
        'user': 'You',
        'message': 'Thanks! Let\'s sync up 🎵',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
        'isMe': true,
      },
    ];
    
    // Load first song
    _loadSong(MockMusicLibrary.songs[0]);
  }

  void _loadSong(Map<String, dynamic> song) {
    final audioService = AudioService();
    
    // Load audio from URL
    audioService.loadAudio(song['url']).then((_) {
      print('Song loaded: ${song['title']}');
    }).catchError((error) {
      print('Error loading song: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading song: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _startMockChat() {
    // Simulate incoming messages
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _addChatMessage('Sarah Johnson', 'This beat is amazing! 🔥', false);
      }
    });
    
    Future.delayed(const Duration(seconds: 25), () {
      if (mounted) {
        _addChatMessage('Alex Chen', 'Can we add this to our shared playlist?', false);
      }
    });
  }

  void _addChatMessage(String user, String message, bool isMe) {
    setState(() {
      chatMessages.add({
        'user': user,
        'message': message,
        'timestamp': DateTime.now(),
        'isMe': isMe,
      });
    });
    
    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      final message = _chatController.text.trim();
      
      // Send via Socket.io
      SocketService().sendChatMessage(message);
      
      _chatController.clear();
    }
  }

  void _handlePlayerEvent(Map<String, dynamic> event) {
    // In a real app, this would send the event via Socket.io
    print('Broadcasting player event: $event');
    
    // Simulate API call to sync with other users
    _syncWithOtherUsers(event);
  }

  Future<void> _syncWithOtherUsers(Map<String, dynamic> event) async {
    try {
      // Mock API call - in real app this would be WebSocket/Socket.io
      await http.post(
        Uri.parse('http://localhost:3001/api/rooms/${widget.roomId}/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event': event,
          'roomId': widget.roomId,
          'userId': 'current_user_id',
        }),
      );
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [
                    // Main content
                    Column(
                      children: [
                        _buildRoomInfo(),
                        Expanded(child: _buildChatSection()),
                      ],
                    ),
                    
                    // Music Player Overlay
                    if (isPlayerVisible)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: MusicPlayer(
                          roomId: widget.roomId,
                          isHost: widget.isHost,
                          onPlayerEvent: _handlePlayerEvent,
                        ).animate().slideY(begin: 1.0),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            padding: EdgeInsets.zero,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.roomName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideX(begin: -0.3),
                Text(
                  '${currentMembers.length} members listening',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isPlayerVisible = !isPlayerVisible;
              });
            },
            icon: Icon(
              isPlayerVisible ? Icons.keyboard_arrow_down : Icons.music_note,
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 400.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Active Members
            Row(
              children: [
                const Icon(
                  Icons.people,
                  color: AppTheme.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Active Members',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${currentMembers.length} online',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Members List
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: currentMembers.length,
                itemBuilder: (context, index) {
                  final member = currentMembers[index];
                  final isOnline = member['status'] == 'online' || member['status'] == 'listening';
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  member['name']![0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (isOnline)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: member['status'] == 'listening' 
                                        ? AppTheme.accent 
                                        : Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member['name']!.split(' ')[0],
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (600 + index * 100).ms).scale();
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: -0.3);
  }

  Widget _buildChatSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Chat Header
            Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: AppTheme.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Room Chat',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${chatMessages.length} messages',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _chatScrollController,
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final message = chatMessages[index];
                  final isMe = message['isMe'] as bool;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (message['user'] as String)[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isMe 
                                  ? AppTheme.primaryColor.withOpacity(0.2)
                                  : AppTheme.surfaceColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Text(
                                    message['user'] as String,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                Text(
                                  message['message'] as String,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        if (isMe) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'Y',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: isMe ? 0.3 : -0.3);
                },
              ),
            ),
            
            // Chat Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColor.withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendChatMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendChatMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3);
  }
}