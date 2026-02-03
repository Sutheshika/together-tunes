import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<bool> get playingStream => _playingController.stream;

  Duration get currentPosition => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;
  bool get isPlaying => _audioPlayer.playing;

  AudioService._internal() {
    _setupListeners();
  }

  void _setupListeners() {
    // Position updates
    _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
    });

    // Duration updates
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _durationController.add(duration);
      }
    });

    // Playing state updates
    _audioPlayer.playingStream.listen((playing) {
      _playingController.add(playing);
    });

    // Handle state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        print('🎵 Audio playback completed');
      }
    });
  }

  /// Load audio from URL
  Future<void> loadAudio(String url) async {
    try {
      print('🎵 Loading audio from: $url');
      print('🎵 Current audio player state: ${_audioPlayer.playerState}');
      await _audioPlayer.setUrl(url);
      print('🎵 Audio loaded successfully');
      print('🎵 Duration: ${_audioPlayer.duration}');
    } catch (e) {
      print('🎵 Error loading audio: $e');
      print('🎵 Error details: ${e.toString()}');
      rethrow;
    }
  }

  /// Load audio from asset
  Future<void> loadAsset(String assetPath) async {
    try {
      print('🎵 Loading asset: $assetPath');
      await _audioPlayer.setAsset(assetPath);
      print('🎵 Asset loaded successfully');
    } catch (e) {
      print('🎵 Error loading asset: $e');
      rethrow;
    }
  }

  /// Play audio
  Future<void> play() async {
    try {
      print('🎵 About to call _audioPlayer.play()');
      print('🎵 Current playing state before: ${_audioPlayer.playing}');
      await _audioPlayer.play();
      print('🎵 Playing');
      print('🎵 Current playing state after: ${_audioPlayer.playing}');
    } catch (e) {
      print('🎵 Error playing: $e');
      rethrow;
    }
  }

  /// Pause audio
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      print('🎵 Paused');
    } catch (e) {
      print('🎵 Error pausing: $e');
      rethrow;
    }
  }

  /// Resume audio
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
      print('🎵 Resumed');
    } catch (e) {
      print('🎵 Error resuming: $e');
      rethrow;
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      print('🎵 Seeked to $position');
    } catch (e) {
      print('🎵 Error seeking: $e');
      rethrow;
    }
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
      print('🎵 Speed set to $speed');
    } catch (e) {
      print('🎵 Error setting speed: $e');
      rethrow;
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      print('🎵 Volume set to $volume');
    } catch (e) {
      print('🎵 Error setting volume: $e');
      rethrow;
    }
  }

  /// Stop audio and release resources
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      print('🎵 Audio stopped');
    } catch (e) {
      print('🎵 Error stopping: $e');
      rethrow;
    }
  }

  /// Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
    _positionController.close();
    _durationController.close();
    _playingController.close();
    print('🎵 Audio service disposed');
  }
}
