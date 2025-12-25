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
  
  const MusicPlayer({
    super.key,
    this.roomId,
    this.isHost = false,
    this.onPlayerEvent,
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

  void _togglePlayPause() {
    if (!widget.isHost) return; // Only host can control playback
    
    if (isPlaying) {
      // Pause
      _audioService.pause().then((_) {
        _rotationController.stop();
        _pulseController.stop();
        _socketService.pauseSong();
      });
    } else {
      // Play
      _audioService.play().then((_) {
        _rotationController.repeat();
        _pulseController.repeat(reverse: true);
        _socketService.playSong(currentSong, position: currentPosition / 1000);
      });
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.radio,
                                size: 14,
                                color: AppTheme.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.isHost ? 'Broadcasting' : 'Synced',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
                            gradient: widget.isHost ? AppTheme.primaryGradient : null,
                            color: widget.isHost ? null : AppTheme.textSecondary.withOpacity(0.3),
                            shape: BoxShape.circle,
                            boxShadow: widget.isHost ? AppTheme.buttonShadow : null,
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