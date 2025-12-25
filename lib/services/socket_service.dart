import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  String? _currentRoomId;
  String? _currentUserId;
  String? _currentUsername;
  
  // Stream controllers for real-time events
  final StreamController<Map<String, dynamic>> _roomStateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _musicEventController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _chatMessageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _memberUpdateController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get roomStateStream => _roomStateController.stream;
  Stream<Map<String, dynamic>> get musicEventStream => _musicEventController.stream;
  Stream<Map<String, dynamic>> get chatMessageStream => _chatMessageController.stream;
  Stream<Map<String, dynamic>> get memberUpdateStream => _memberUpdateController.stream;

  bool get isConnected => _socket?.connected ?? false;
  String? get currentRoomId => _currentRoomId;

  void connect() {
    if (_socket?.connected == true) return;

    _socket = io.io(
      'http://localhost:3001',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    _setupEventListeners();
    _socket?.connect();
  }

  void _setupEventListeners() {
    _socket?.onConnect((_) {
      print('Socket.io: Connected to server');
    });

    _socket?.onDisconnect((_) {
      print('Socket.io: Disconnected from server');
    });

    _socket?.onConnectError((error) {
      print('Socket.io: Connection error: $error');
    });

    _socket?.onError((error) {
      print('Socket.io: Error: $error');
    });

    // Room state events
    _socket?.on('room-state', (data) {
      print('Socket.io: Room state received: $data');
      _roomStateController.add(Map<String, dynamic>.from(data));
    });

    // Music player events
    _socket?.on('song-started', (data) {
      print('Socket.io: Song started: ${data['songData']['title']}');
      _musicEventController.add({
        'type': 'play',
        'songData': data['songData'],
        'position': data['position'],
        'timestamp': data['timestamp'],
      });
    });

    _socket?.on('song-paused', (data) {
      print('Socket.io: Song paused at position: ${data['position']}');
      _musicEventController.add({
        'type': 'pause',
        'position': data['position'],
        'timestamp': data['timestamp'],
      });
    });

    _socket?.on('song-resumed', (data) {
      print('Socket.io: Song resumed at position: ${data['position']}');
      _musicEventController.add({
        'type': 'resume',
        'position': data['position'],
        'timestamp': data['timestamp'],
      });
    });

    _socket?.on('song-seeked', (data) {
      print('Socket.io: Song seeked to position: ${data['position']}');
      _musicEventController.add({
        'type': 'seek',
        'position': data['position'],
        'timestamp': data['timestamp'],
      });
    });

    // Chat events
    _socket?.on('chat-message', (data) {
      print('Socket.io: Chat message from ${data['username']}: ${data['message']}');
      _chatMessageController.add(Map<String, dynamic>.from(data));
    });

    // Member update events
    _socket?.on('user-joined', (data) {
      print('Socket.io: User joined: ${data['username']}');
      _memberUpdateController.add({
        'type': 'joined',
        'userId': data['userId'],
        'username': data['username'],
        'memberCount': data['memberCount'],
      });
    });

    _socket?.on('user-left', (data) {
      print('Socket.io: User left: ${data['username']}');
      _memberUpdateController.add({
        'type': 'left',
        'userId': data['userId'],
        'username': data['username'],
        'memberCount': data['memberCount'],
      });
    });
  }

  Future<void> joinRoom(String roomId, String userId, String username) async {
    if (_socket?.connected != true) {
      connect();
      // Wait for connection
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    _currentRoomId = roomId;
    _currentUserId = userId;
    _currentUsername = username;

    _socket?.emit('join-room', {
      'roomId': roomId,
      'userId': userId,
      'username': username,
    });

    print('Socket.io: Joining room $roomId as $username');
  }

  void leaveRoom() {
    if (_currentRoomId != null) {
      _socket?.emit('leave-room', {
        'roomId': _currentRoomId,
      });
      
      print('Socket.io: Left room $_currentRoomId');
      
      _currentRoomId = null;
      _currentUserId = null;
      _currentUsername = null;
    }
  }

  // Music player control methods
  void playSong(Map<String, dynamic> songData, {double position = 0.0}) {
    if (_currentRoomId == null) return;
    
    _socket?.emit('play-song', {
      'roomId': _currentRoomId,
      'songData': songData,
      'position': position,
    });
    
    print('Socket.io: Playing song: ${songData['title']}');
  }

  void pauseSong() {
    if (_currentRoomId == null) return;
    
    _socket?.emit('pause-song', {
      'roomId': _currentRoomId,
    });
    
    print('Socket.io: Pausing song');
  }

  void resumeSong() {
    if (_currentRoomId == null) return;
    
    _socket?.emit('resume-song', {
      'roomId': _currentRoomId,
    });
    
    print('Socket.io: Resuming song');
  }

  void seekSong(double position) {
    if (_currentRoomId == null) return;
    
    _socket?.emit('seek-song', {
      'roomId': _currentRoomId,
      'position': position,
    });
    
    print('Socket.io: Seeking to position: $position');
  }

  void syncPosition(double position) {
    if (_currentRoomId == null) return;
    
    _socket?.emit('sync-position', {
      'roomId': _currentRoomId,
      'position': position,
    });
  }

  // Chat methods
  void sendChatMessage(String message) {
    if (_currentRoomId == null || message.trim().isEmpty) return;
    
    _socket?.emit('chat-message', {
      'roomId': _currentRoomId,
      'message': message.trim(),
    });
    
    print('Socket.io: Sending chat message: $message');
  }

  void disconnect() {
    leaveRoom();
    _socket?.disconnect();
    _socket = null;
    print('Socket.io: Disconnected and cleaned up');
  }

  void dispose() {
    disconnect();
    _roomStateController.close();
    _musicEventController.close();
    _chatMessageController.close();
    _memberUpdateController.close();
  }
}