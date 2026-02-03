import 'dart:async';
import 'mock_music_library.dart';

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  // Room playlists mapping: roomId -> list of songs
  Map<String, List<Map<String, dynamic>>> _roomPlaylists = {};
  
  // Current queue index per room
  Map<String, int> _currentIndex = {};

  // Stream controllers
  final StreamController<List<Map<String, dynamic>>> _queueController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  
  final StreamController<Map<String, dynamic>?> _currentSongController =
      StreamController<Map<String, dynamic>?>.broadcast();

  // Getters
  Stream<List<Map<String, dynamic>>> get queueStream => _queueController.stream;
  Stream<Map<String, dynamic>?> get currentSongStream => _currentSongController.stream;

  /// Get all available songs
  List<Map<String, dynamic>> getAllSongs() {
    return List.from(MockMusicLibrary.songs);
  }

  /// Initialize playlist for a room
  void initializeRoomPlaylist(String roomId) {
    if (!_roomPlaylists.containsKey(roomId)) {
      _roomPlaylists[roomId] = [];
      _currentIndex[roomId] = 0;
      print('🎵 Playlist initialized for room: $roomId');
    }
  }

  /// Add song to room playlist
  void addSongToPlaylist(String roomId, Map<String, dynamic> song) {
    initializeRoomPlaylist(roomId);
    _roomPlaylists[roomId]!.add(song);
    print('🎵 Added song: ${song['title']} to room $roomId');
    _broadcastQueue(roomId);
  }

  /// Add multiple songs to playlist
  void addSongsToPlaylist(String roomId, List<Map<String, dynamic>> songs) {
    initializeRoomPlaylist(roomId);
    _roomPlaylists[roomId]!.addAll(songs);
    print('🎵 Added ${songs.length} songs to room $roomId');
    _broadcastQueue(roomId);
  }

  /// Remove song from playlist by index
  void removeSongFromPlaylist(String roomId, int index) {
    initializeRoomPlaylist(roomId);
    if (index >= 0 && index < _roomPlaylists[roomId]!.length) {
      _roomPlaylists[roomId]!.removeAt(index);
      print('🎵 Removed song at index $index from room $roomId');
      _broadcastQueue(roomId);
    }
  }

  /// Move to next song
  void nextSong(String roomId) {
    initializeRoomPlaylist(roomId);
    final playlist = _roomPlaylists[roomId]!;
    if (playlist.isNotEmpty) {
      _currentIndex[roomId] = (_currentIndex[roomId]! + 1) % playlist.length;
      print('🎵 Next song in room $roomId');
      _broadcastCurrentSong(roomId);
    }
  }

  /// Move to previous song
  void previousSong(String roomId) {
    initializeRoomPlaylist(roomId);
    final playlist = _roomPlaylists[roomId]!;
    if (playlist.isNotEmpty) {
      _currentIndex[roomId] = (_currentIndex[roomId]! - 1 + playlist.length) % playlist.length;
      print('🎵 Previous song in room $roomId');
      _broadcastCurrentSong(roomId);
    }
  }

  /// Play song at specific index
  void playAtIndex(String roomId, int index) {
    initializeRoomPlaylist(roomId);
    final playlist = _roomPlaylists[roomId]!;
    if (index >= 0 && index < playlist.length) {
      _currentIndex[roomId] = index;
      print('🎵 Playing song at index $index in room $roomId');
      _broadcastCurrentSong(roomId);
    }
  }

  /// Get current playing song
  Map<String, dynamic>? getCurrentSong(String roomId) {
    initializeRoomPlaylist(roomId);
    final playlist = _roomPlaylists[roomId]!;
    if (playlist.isEmpty) return null;
    return playlist[_currentIndex[roomId]!];
  }

  /// Get full queue for room
  List<Map<String, dynamic>> getQueue(String roomId) {
    initializeRoomPlaylist(roomId);
    return List.from(_roomPlaylists[roomId]!);
  }

  /// Clear playlist for room
  void clearPlaylist(String roomId) {
    _roomPlaylists[roomId] = [];
    _currentIndex[roomId] = 0;
    print('🎵 Cleared playlist for room: $roomId');
    _broadcastQueue(roomId);
    _broadcastCurrentSong(roomId);
  }

  /// Search songs in library
  List<Map<String, dynamic>> searchSongs(String query) {
    return MockMusicLibrary.searchSongs(query);
  }

  /// Get songs by genre/artist/album
  List<Map<String, dynamic>> getSongsByArtist(String artist) {
    return MockMusicLibrary.songs
        .where((song) => song['artist'].toString().toLowerCase().contains(artist.toLowerCase()))
        .toList();
  }

  /// Broadcast queue changes
  void _broadcastQueue(String roomId) {
    _queueController.add(getQueue(roomId));
  }

  /// Broadcast current song
  void _broadcastCurrentSong(String roomId) {
    _currentSongController.add(getCurrentSong(roomId));
  }

  /// Dispose
  void dispose() {
    _queueController.close();
    _currentSongController.close();
  }
}
