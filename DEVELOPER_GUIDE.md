# 🎨 Developer Guide - Together Tunes

## Architecture Overview

### Three-Layer Architecture

```
┌──────────────────────────────────────┐
│     Presentation Layer (Flutter)     │
│  ┌────────────┐  ┌──────────────┐   │
│  │ Music      │  │ Room Player  │   │
│  │ Player     │  │ Screen       │   │
│  └────────────┘  └──────────────┘   │
│         ▲                ▲            │
└─────────┼────────────────┼────────────┘
          │                │
┌─────────▼────────────────▼────────────┐
│  Services Layer (Managers)             │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ Socket       │  │ Audio        │   │
│  │ Service      │  │ Service      │   │
│  └──────────────┘  └──────────────┘   │
│         ▲                ▲            │
└─────────┼────────────────┼────────────┘
          │                │
┌─────────▼────────────────▼────────────┐
│  Backend Layer (Node.js)              │
│  ┌────────────────────────────────┐   │
│  │ Socket.io Rooms & State Mgmt   │   │
│  │ Authentication & Authorization │   │
│  │ Event Broadcasting             │   │
│  └────────────────────────────────┘   │
└──────────────────────────────────────┘
```

## Key Design Patterns

### 1. Service Singleton Pattern
```dart
// AudioService - Singleton instance
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  // Only one instance created throughout app lifecycle
  // Ensures consistent state across all widgets
}
```

### 2. Stream-based State Management
```dart
// Services emit events via Streams instead of callbacks
final StreamController<Duration> _positionController = 
    StreamController<Duration>.broadcast();

// Widgets listen to these streams
stream.listen((position) {
  setState(() { currentPosition = position; });
});
```

### 3. Host-Guest Permission Model
```dart
// Only host can trigger certain actions
if (widget.isHost) {
  await _audioService.play();
  _socketService.playSong(currentSong);
} else {
  // Guest listens to socket events
  _socketService.musicEventStream.listen(_handleRemotePlay);
}
```

## Adding New Features

### Feature: Add Skip Previous Button

#### 1. Backend (sync_server.js)
```javascript
// Add new socket event
socket.on('previous-song', ({ roomId }) => {
  const room = rooms.get(roomId);
  const userInfo = socketToUser.get(socket.id);
  
  if (room && userInfo && userInfo.userId === room.hostId) {
    // Load previous song
    room.currentSong = getPreviousSong(room.currentSong);
    io.to(roomId).emit('song-changed', { songData: room.currentSong });
  }
});
```

#### 2. Frontend - Update SocketService
```dart
// lib/services/socket_service.dart
void previousSong() {
  if (_currentRoomId == null) return;
  
  _socket?.emit('previous-song', {
    'roomId': _currentRoomId,
  });
}
```

#### 3. Frontend - Update MusicPlayer Widget
```dart
// lib/widgets/music_player.dart
void _skipToPrevious() {
  if (!widget.isHost) return;
  
  // Update audio
  _audioService.previous();
  
  // Sync with room
  _socketService.previousSong();
  
  // Emit legacy event
  widget.onPlayerEvent?.call({
    'type': 'previous',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}
```

#### 4. Frontend - Add UI Button
```dart
// In music_player.dart build method
IconButton(
  onPressed: widget.isHost ? _skipToPrevious : null,
  icon: Icon(Icons.skip_previous, 
    color: widget.isHost ? Colors.white : Colors.grey),
),
```

### Feature: Add Playlist to Room

#### 1. Extend Room Model
```javascript
// backend/sync_server.js
const newRoom = {
  name,
  host: hostName,
  members: [],
  currentSong: null,
  playlist: [],  // ← NEW
  playlistIndex: 0,  // ← NEW
  ...
};
```

#### 2. Create PlaylistService
```dart
// lib/services/playlist_service.dart
class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  List<Map<String, dynamic>> _currentPlaylist = [];
  int _currentIndex = 0;

  Future<void> loadPlaylist(String playlistId) async {
    _currentPlaylist = await _fetchPlaylist(playlistId);
    _currentIndex = 0;
  }

  Map<String, dynamic>? get currentSong => 
      _currentIndex < _currentPlaylist.length 
          ? _currentPlaylist[_currentIndex]
          : null;

  void nextSong() {
    if (_currentIndex < _currentPlaylist.length - 1) {
      _currentIndex++;
    }
  }

  void previousSong() {
    if (_currentIndex > 0) {
      _currentIndex--;
    }
  }
}
```

#### 3. Integrate with MusicPlayer
```dart
final playlistService = PlaylistService();
await playlistService.loadPlaylist(roomId);

// Auto-play next song when current finishes
_audioService.playerStateStream.listen((state) {
  if (state.processingState == ProcessingState.completed) {
    playlistService.nextSong();
    _playCurrentSong();
  }
});
```

### Feature: Add Volume Control

#### 1. Update MusicPlayer UI
```dart
// Add volume slider
Column(
  children: [
    Slider(
      value: _volumeLevel,
      min: 0.0,
      max: 1.0,
      onChanged: _setVolume,
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.volume_mute),
        Text('${(_volumeLevel * 100).toInt()}%'),
        Icon(Icons.volume_up),
      ],
    ),
  ],
),

void _setVolume(double volume) {
  setState(() => _volumeLevel = volume);
  _audioService.setVolume(volume);
  
  // Broadcast volume change to room
  _socketService.emitCustomEvent('volume-changed', {
    'volume': volume,
  });
}
```

## Testing Strategies

### Unit Testing
```dart
// test/services/audio_service_test.dart
void main() {
  group('AudioService', () {
    late AudioService audioService;

    setUp(() {
      audioService = AudioService();
    });

    test('play() starts audio playback', () async {
      await audioService.loadAsset('test_audio.mp3');
      await audioService.play();
      expect(audioService.isPlaying, true);
    });

    test('seek() changes position', () async {
      await audioService.seek(Duration(seconds: 10));
      expect(audioService.currentPosition.inSeconds, 10);
    });
  });
}
```

### Integration Testing
```dart
// test/integration/real_time_sync_test.dart
void main() {
  group('Real-time Music Sync', () {
    test('Host and Guest sync playback', () async {
      // Simulate host playing
      final host = MusicPlayerTestHelper.createHostPlayer();
      await host.play();
      
      // Simulate guest receiving event
      final guest = MusicPlayerTestHelper.createGuestPlayer();
      await guest.receivePlayEvent(host.currentSong);
      
      // Verify both are in sync
      expect(guest.isPlaying, true);
      expect(guest.currentSong, host.currentSong);
    });
  });
}
```

## Performance Optimization

### 1. Minimize Socket Events
```dart
// ❌ Bad: Emit every millisecond
Timer.periodic(Duration(milliseconds: 1), (_) {
  _socketService.syncPosition(_currentPosition);
});

// ✅ Good: Emit every second only
Timer.periodic(Duration(seconds: 1), (_) {
  _socketService.syncPosition(_currentPosition);
});
```

### 2. Reduce Widget Rebuilds
```dart
// ❌ Bad: Entire widget rebuilds
setState(() {
  currentPosition = position;
  currentSong = song;
  isPlaying = playing;
});

// ✅ Good: Only update what changed
if (position != currentPosition) {
  setState(() => currentPosition = position);
}
```

### 3. Use Release Build
```bash
# Development (slower, lots of logging)
flutter run

# Release (optimized, 10x faster)
flutter run --release

# Profile (with performance monitoring)
flutter run --profile
```

## Debugging Tips

### 1. Socket.io Debug Logs
```dart
// In SocketService._setupEventListeners()
_socket?.on('room-state', (data) {
  print('🔍 DEBUG: Room state received:');
  print('  Members: ${data['members']}');
  print('  Current song: ${data['currentSong']}');
});
```

### 2. Audio Service Debug
```dart
// In AudioService._setupListeners()
_audioPlayer.playerStateStream.listen((state) {
  print('🎵 Audio state: ${state.processingState}');
  print('  Playing: ${state.playing}');
  print('  Position: ${_audioPlayer.position}');
});
```

### 3. Network Inspection
```bash
# Use Chrome DevTools for web version
flutter run -d chrome

# Check network tab in DevTools
# Look for Socket.io WebSocket connections
```

## Common Issues & Solutions

### Issue: Audio not syncing between users
**Root Cause**: Position updates not being sent frequently enough
**Solution**: 
```dart
// Increase sync frequency (from 1s to 500ms)
Timer.periodic(Duration(milliseconds: 500), (_) {
  if (widget.isHost) _socketService.syncPosition(_currentPosition);
});
```

### Issue: Lag when playing/pausing
**Root Cause**: UI rebuild blocking audio thread
**Solution**:
```dart
// Use Isolate for heavy computation
compute(_heavyComputation, data).then((result) {
  setState(() => processedData = result);
});
```

### Issue: Memory leak with streams
**Root Cause**: Streams not being disposed
**Solution**:
```dart
@override
void dispose() {
  _positionSubscription?.cancel();
  _durationSubscription?.cancel();
  _musicEventSubscription?.cancel();
  super.dispose();
}
```

## Code Style Guidelines

### Dart/Flutter
```dart
// ✅ Good
const double borderRadius = 12.0;
final audioService = AudioService();
void _handleMusicEvent() { }

// ❌ Bad
double borderRadius = 12.0;
var audioService = AudioService();
void handleMusicEvent() { }
```

### Comments
```dart
// ❌ Bad: Obvious comments
int position = 0; // Initialize position to 0

// ✅ Good: Explain WHY, not WHAT
// Position is 1-indexed per Socket.io spec from backend
int position = 1;
```

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>

Examples:
feat(music-player): add volume control
fix(socket-service): fix position sync lag
docs(quick-start): update setup instructions
refactor(audio-service): extract audio state to separate class
test(room-player): add sync tests
```

---

**Happy coding! 🚀 Report issues in the repo's GitHub Issues section.**