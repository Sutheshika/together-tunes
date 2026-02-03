import 'dart:async';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Current logged-in user data
  String? _userId;
  String? _username;
  String? _email;
  String? _avatar;
  String? _bio;

  // Stream controllers for user updates
  final StreamController<Map<String, dynamic>> _userDataController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  String? get avatar => _avatar;
  String? get bio => _bio;
  Stream<Map<String, dynamic>> get userDataStream => _userDataController.stream;

  bool get isLoggedIn => _userId != null && _username != null;

  /// Set user data after successful login
  void setUserData({
    required String userId,
    required String username,
    required String email,
    String? avatar,
    String? bio,
  }) {
    _userId = userId;
    _username = username;
    _email = email;
    _avatar = avatar;
    _bio = bio;

    print('👤 User data set: $_username (ID: $_userId)');
    _broadcastUserData();
  }

  /// Update user profile
  void updateProfile({
    String? username,
    String? avatar,
    String? bio,
  }) {
    if (username != null) _username = username;
    if (avatar != null) _avatar = avatar;
    if (bio != null) _bio = bio;

    print('👤 User profile updated: $_username');
    _broadcastUserData();
  }

  /// Clear user data on logout
  void logout() {
    _userId = null;
    _username = null;
    _email = null;
    _avatar = null;
    _bio = null;

    print('👤 User logged out');
    _broadcastUserData();
  }

  /// Get all user data as map
  Map<String, dynamic> getUserData() {
    return {
      'userId': _userId,
      'username': _username,
      'email': _email,
      'avatar': _avatar,
      'bio': _bio,
    };
  }

  /// Broadcast user data changes
  void _broadcastUserData() {
    _userDataController.add(getUserData());
  }

  /// Dispose the service
  void dispose() {
    _userDataController.close();
  }
}
