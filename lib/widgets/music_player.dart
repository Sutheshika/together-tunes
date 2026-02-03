import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/socket_service.dart';
import '../services/audio_service.dart';
import 'dart:async';

class MusicPlayer extends StatefulWidget {
  final String? roomId;
  final bool isHost;
  final Function(Map<String, dynamic>)? onPlayerEvent;
  final Map<String, dynamic>? currentSongData;
  
  const MusicPlayer({
    super.key,
    this.roomId,
    this.isHost = false,
    this.onPlayerEvent,
    this.currentSongData,
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> with TickerProviderStateMixin {
  late AudioService _audioService;
  late SocketService _socketService;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  
  bool isPlaying = false;
  bool isLoading = false;
  double currentPosition = 0.0;
  double totalDuration = 0.0;
  bool isBroadcasting = false;
  bool isSynced = false;
  
  // Current song data
  Map<String, dynamic> currentSong = {
    'title': 'Blinding Lights',
    'artist': 'The Weeknd',
    'album': 'After Hours',
    'cover': 'https://via.placeholder.com/300x300/6B46C1/FFFFFF?text=🎵',
    'duration': 200, // 3+ minutes
  };

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playingSubscription;
  StreamSubscription? _musicEventSubscription;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _socketService = SocketService();
    
    // Use passed song data or default
    if (widget.currentSongData != null) {
      currentSong = widget.currentSongData!;
    }
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _initializeSocket();
    _setupAudioListeners();
    _preloadAudio(); // Preload the song audio
  }

  void _setupAudioListeners() {
    // Listen to audio position updates
    _positionSubscription = _audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          currentPosition = position.inMilliseconds.toDouble();
        });
        
        // Sync position with other users if host
        if (widget.isHost && _socketService.isConnected) {
          _socketService.syncPosition(position.inSeconds.toDouble());
        }
      }
    });

    // Listen to duration updates
    _durationSubscription = _audioService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          totalDuration = duration.inMilliseconds.toDouble();
        });
      }
    });

    // Listen to playing state changes
    _playingSubscription = _audioService.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          isPlaying = playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playingSubscription?.cancel();
    _musicEventSubscription?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _socketService.leaveRoom();
    super.dispose();
  }

  void _initializeSocket() {
    if (widget.roomId == null) return;
    
    // Connect to Socket.io service
    _socketService.connect();
    
    // Join room with mock user data
    _socketService.joinRoom(
      widget.roomId ?? 'unknown_room',
      'user_${DateTime.now().millisecondsSinceEpoch}',
      'You',
    );

    // Listen to music events from other users
    _musicEventSubscription = _socketService.musicEventStream.listen(
      _handleSocketMusicEvent
    );
  }

  void _handleSocketMusicEvent(Map<String, dynamic> event) {
    if (mounted && !widget.isHost) {
      final eventType = event['type'];
      
      switch (eventType) {
        case 'play':
          _audioService.play().then((_) {
            setState(() {
              currentSong = event['songData'] ?? currentSong;
              isPlaying = true;
              isSynced = true;
            });
            _rotationController.repeat();
            _pulseController.repeat(reverse: true);
          });
          break;
          
        case 'pause':
          _audioService.pause().then((_) {
            setState(() {
              isPlaying = false;
              isSynced = true;
            });
            _rotationController.stop();
            _pulseController.stop();
          });
          break;
          
        case 'resume':
          _audioService.resume().then((_) {
            setState(() {
              isPlaying = true;
              isSynced = true;
            });
            _rotationController.repeat();
            _pulseController.repeat(reverse: true);
          });
          break;
          
        case 'seek':
          final position = Duration(seconds: (event['position'] as num).toInt());
          _audioService.seek(position).then((_) {
            setState(() {
              isSynced = true;
            });
          });
          break;
      }
    }
  }

  Future<void> _preloadAudio() async {
    try {
      final url = currentSong['url'] ?? 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      print('🎵 Preloading audio: $url');
      await _audioService.loadAudio(url);
      print('🎵 Audio preloaded successfully');
    } catch (e) {
      print('🎵 Error preloading audio: $e');
    }
  }

  void _togglePlayPause() async {
    if (!widget.isHost) return; // Only host can control playback
    
    print('🎵 _togglePlayPause called, isPlaying=$isPlaying');
    
    if (isPlaying) {
      // Pause
      try {
        print('🎵 Pausing audio...');
        await _audioService.pause();
        setState(() => isPlaying = false);
        _rotationController.stop();
        _pulseController.stop();
        _socketService.pauseSong();
        print('🎵 Pause completed');
      } catch (e) {
        print('Error pausing: $e');
      }
    } else {
      // Play - audio should be preloaded already
      try {
        print('🎵 Starting play sequence...');
        setState(() => isLoading = true);
        
        // Ensure audio is loaded
        final url = currentSong['url'] ?? 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
        print('🎵 Loading audio from: $url');
        await _audioService.loadAudio(url);
        print('🎵 Audio loaded, now playing...');
        
        // Play the audio
        await _audioService.play();
        print('🎵 Play command completed');
        
        setState(() {
          isPlaying = true;
          isLoading = false;
        });
        
        _rotationController.repeat();
        _pulseController.repeat(reverse: true);
        _socketService.playSong(currentSong, position: currentPosition / 1000);
        print('🎵 Socket event emitted');
      } catch (e) {
        print('Error playing song: $e');
        print('🎵 Full error: ${e.toString()}');
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing song: $e')),
          );
        }
      }
    }

    // Send sync event to room (backward compatibility)
    if (widget.onPlayerEvent != null) {
      widget.onPlayerEvent!({
        'type': isPlaying ? 'pause' : 'play',
        'position': currentPosition / 1000,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'song': currentSong,
      });
    }
  }

  void _seekToPosition(double position) {
    if (!widget.isHost) return; // Only host can seek
    
    final Duration seekPosition = Duration(milliseconds: position.toInt());
    _audioService.seek(seekPosition).then((_) {
      _socketService.seekSong(seekPosition.inSeconds.toDouble());
    });

    // Send seek event to room (backward compatibility)
    if (widget.onPlayerEvent != null) {
      widget.onPlayerEvent!({
        'type': 'seek',
        'position': seekPosition.inSeconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'song': currentSong,
      });
    }
  }

  String _formatDuration(double milliseconds) {
    final totalSeconds = (milliseconds / 1000).toInt();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.cardColor.withOpacity(0.95),
            AppTheme.surfaceColor.withOpacity(0.95),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Album Art
                  Expanded(
                    flex: 3,
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * 3.14159,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseController.value * 0.05),
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.4),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ).animate().scale(delay: 200.ms),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Song Info
                  Column(
                    children: [
                      Text(
                        currentSong['title']!,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        currentSong['artist']!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 500.ms),
                      
                      if (widget.roomId != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.cyanAccent.withOpacity(0.15),
                            border: Border.all(
                              color: AppTheme.cyanAccent.withOpacity(0.5),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.cyanAccent.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.cyanAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.cyanAccent.withOpacity(0.8),
                                      blurRadius: 4,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.isHost ? '🔴 Broadcasting' : '✓ Synced',
                                style: TextStyle(
                                  color: AppTheme.cyanAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Progress Bar
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: AppTheme.primaryColor,
                          inactiveTrackColor: AppTheme.textSecondary.withOpacity(0.3),
                          thumbColor: AppTheme.primaryColor,
                          overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: currentPosition,
                          max: totalDuration,
                          onChanged: widget.isHost ? _seekToPosition : null,
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(currentPosition),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(totalDuration),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous
                      IconButton(
                        onPressed: widget.isHost ? () {} : null,
                        icon: Icon(
                          Icons.skip_previous,
                          color: widget.isHost ? AppTheme.textPrimary : AppTheme.textSecondary,
                          size: 32,
                        ),
                      ).animate().scale(delay: 800.ms),
                      
                      // Play/Pause
                      GestureDetector(
                        onTap: widget.isHost ? _togglePlayPause : null,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: widget.isHost 
                              ? (isPlaying ? AppTheme.glowingGradient : AppTheme.cyanGradient)
                              : null,
                            color: widget.isHost ? null : AppTheme.textSecondary.withOpacity(0.3),
                            shape: BoxShape.circle,
                            boxShadow: widget.isHost 
                              ? (isPlaying ? AppTheme.glowingShadow : AppTheme.buttonShadow)
                              : null,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ).animate().scale(delay: 900.ms),
                      
                      // Next
                      IconButton(
                        onPressed: widget.isHost ? () {} : null,
                        icon: Icon(
                          Icons.skip_next,
                          color: widget.isHost ? AppTheme.textPrimary : AppTheme.textSecondary,
                          size: 32,
                        ),
                      ).animate().scale(delay: 1000.ms),
                    ],
                  ),
                  
                  // Host/Guest indicator
                  if (widget.roomId != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.isHost 
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : AppTheme.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.isHost 
                            ? '👑 You control the music'
                            : '🎧 Following host\'s playlist',
                        style: TextStyle(
                          color: widget.isHost ? AppTheme.primaryColor : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn(delay: 1100.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to handle incoming sync events from other users
  void handleSyncEvent(Map<String, dynamic> event) {
    if (!widget.isHost && mounted) {
      switch (event['type']) {
        case 'play':
          setState(() {
            isPlaying = true;
            currentPosition = event['position']?.toDouble() ?? currentPosition;
          });
          _rotationController.repeat();
          _pulseController.repeat(reverse: true);
          break;
        case 'pause':
          setState(() {
            isPlaying = false;
            currentPosition = event['position']?.toDouble() ?? currentPosition;
          });
          _rotationController.stop();
          _pulseController.stop();
          break;
        case 'seek':
          setState(() {
            currentPosition = event['position']?.toDouble() ?? currentPosition;
          });
          break;
      }
    }
  }
}