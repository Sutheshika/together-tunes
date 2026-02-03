import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoomsService {
  static final RoomsService _instance = RoomsService._internal();
  factory RoomsService() => _instance;
  RoomsService._internal() {
    _loadRoomsFromStorage();
  }

  // User's rooms list
  List<Map<String, dynamic>> _userRooms = [];
  
  // Stream controller for room updates
  final StreamController<List<Map<String, dynamic>>> _roomsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  // Storage key
  static const String _storageKey = 'user_rooms';

  // Getters
  List<Map<String, dynamic>> get userRooms => _userRooms;
  Stream<List<Map<String, dynamic>>> get roomsStream => _roomsController.stream;

  /// Load rooms from SharedPreferences
  Future<void> _loadRoomsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = prefs.getString(_storageKey);
      
      if (roomsJson != null && roomsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(roomsJson);
        _userRooms = List<Map<String, dynamic>>.from(
          decoded.map((room) => Map<String, dynamic>.from(room))
        );
        print('🎸 Loaded ${_userRooms.length} rooms from storage');
        _broadcastRooms();
      }
    } catch (e) {
      print('Error loading rooms from storage: $e');
    }
  }

  /// Save rooms to SharedPreferences
  Future<void> _saveRoomsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = jsonEncode(_userRooms);
      await prefs.setString(_storageKey, roomsJson);
      print('🎸 Saved ${_userRooms.length} rooms to storage');
    } catch (e) {
      print('Error saving rooms to storage: $e');
    }
  }

  /// Add a new room created by user
  void addRoom({
    required String roomId,
    required String roomName,
    required String hostId,
    required String hostName,
  }) {
    final newRoom = {
      'id': roomId,
      'name': roomName,
      'hostId': hostId,
      'host': hostName,
      'members': [{'id': hostId, 'name': hostName}],
      'currentSong': null,
      'position': 0,
      'isPlaying': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _userRooms.add(newRoom);
    print('🎸 Room added: $roomName (ID: $roomId)');
    _broadcastRooms();
    _saveRoomsToStorage(); // Persist to storage
  }

  /// Remove a room
  void removeRoom(String roomId) {
    _userRooms.removeWhere((room) => room['id'] == roomId);
    print('🎸 Room removed: $roomId');
    _broadcastRooms();
    _saveRoomsToStorage(); // Persist to storage
  }

  /// Update room (e.g., current song, position)
  void updateRoom(String roomId, Map<String, dynamic> updates) {
    final roomIndex = _userRooms.indexWhere((room) => room['id'] == roomId);
    if (roomIndex != -1) {
      _userRooms[roomIndex].addAll(updates);
      _broadcastRooms();
    }
  }

  /// Clear all rooms
  void clearRooms() {
    _userRooms.clear();
    print('🎸 All rooms cleared');
    _broadcastRooms();
    _saveRoomsToStorage(); // Persist to storage
  }

  /// Get room by ID
  Map<String, dynamic>? getRoom(String roomId) {
    try {
      return _userRooms.firstWhere((room) => room['id'] == roomId);
    } catch (e) {
      return null;
    }
  }

  /// Broadcast rooms changes
  void _broadcastRooms() {
    _roomsController.add(List.from(_userRooms));
  }

  /// Dispose the service
  void dispose() {
    _roomsController.close();
  }
}
