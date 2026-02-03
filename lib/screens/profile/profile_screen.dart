import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserService _userService;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    final userData = _userService.getUserData();
    _usernameController = TextEditingController(text: userData['username'] ?? '');
    _bioController = TextEditingController(text: userData['bio'] ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    
    try {
      final userId = _userService.userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final response = await http.put(
        Uri.parse('http://localhost:3001/api/users/$userId/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userService.updateProfile(
          username: data['user']['username'],
          bio: data['user']['bio'],
        );
        
        setState(() => _isEditing = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.accent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
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
          child: StreamBuilder<Map<String, dynamic>>(
            stream: _userService.userDataStream,
            initialData: _userService.getUserData(),
            builder: (context, snapshot) {
              final userData = snapshot.data ?? {};
              final username = userData['username'] as String? ?? 'User';
              final email = userData['email'] as String? ?? '';
              final bio = userData['bio'] as String? ?? '';
              
              // Update controllers if not editing
              if (!_isEditing) {
                _usernameController.text = username;
                _bioController.text = bio;
              }
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context, username, bio),
                    _buildUserStats(context),
                    _buildQuickActions(context),
                    _buildRecentActivity(context),
                    _buildSettings(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String username, String bio) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Back Button
          Row(
            children: [
              AppBackButton(),
              const Spacer(),
            ],
          ),
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ).animate().scale(delay: 200.ms),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isEditing ? null : () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ).animate().scale(delay: 600.ms),
            ],
          ),
          const SizedBox(height: 20),
          
          // Edit Button / Save Cancel Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isEditing)
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
                  label: Text(_isSaving ? 'Saving...' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _usernameController.text = username;
                    _bioController.text = bio;
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          
          // User Info (Editable or Display)
          if (_isEditing)
            Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description),
                    hintText: 'Tell us about yourself',
                  ),
                  maxLines: 3,
                ),
              ],
            )
          else
            Column(
              children: [
                Text(
                  username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 12),
                
                if (bio.isNotEmpty)
                  Text(
                    bio,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 500.ms),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUserStats(BuildContext context) {
    final stats = [
      {'label': 'Playlists', 'value': '0'},
      {'label': 'Following', 'value': '0'},
      {'label': 'Followers', 'value': '0'},
      {'label': 'Hours', 'value': '120'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            
            return Column(
              children: [
                Text(
                  stat['value']!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stat['label']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: (1000 + index * 100).ms).scale();
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.history, 'title': 'Listening History', 'subtitle': 'See what you\'ve played'},
      {'icon': Icons.favorite, 'title': 'Liked Songs', 'subtitle': '45 songs'},
      {'icon': Icons.download, 'title': 'Downloaded', 'subtitle': '12 playlists offline'},
      {'icon': Icons.group, 'title': 'Friends', 'subtitle': 'Manage connections'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn().slideX(begin: -0.3),
          const SizedBox(height: 16),
          ...actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                onTap: () {},
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action['title'] as String,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            action['subtitle'] as String,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (1200 + index * 100).ms).slideX(begin: 0.3);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
      {'action': 'Created playlist "Summer Vibes"', 'time': '2 hours ago'},
      {'action': 'Followed Alex Chen', 'time': '5 hours ago'},
      {'action': 'Liked "Blinding Lights"', 'time': '1 day ago'},
      {'action': 'Joined room "Chill Lounge"', 'time': '2 days ago'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.3),
          const SizedBox(height: 16),
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['action'] as String,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            activity['time'] as String,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (1600 + index * 100).ms).slideX(begin: -0.3);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    final settings = [
      {'icon': Icons.notifications, 'title': 'Notifications'},
      {'icon': Icons.privacy_tip, 'title': 'Privacy'},
      {'icon': Icons.help, 'title': 'Help & Support'},
      {'icon': Icons.info, 'title': 'About'},
      {'icon': Icons.logout, 'title': 'Sign Out', 'isDestructive': true},
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn().slideX(begin: -0.3),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: settings.asMap().entries.map((entry) {
                final index = entry.key;
                final setting = entry.value;
                final isDestructive = setting['isDestructive'] as bool? ?? false;
                
                return ListTile(
                  leading: Icon(
                    setting['icon'] as IconData,
                    color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
                  ),
                  title: Text(
                    setting['title'] as String,
                    style: TextStyle(
                      color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                  onTap: () {
                    if (isDestructive) {
                      _showSignOutDialog(context);
                    }
                  },
                ).animate().fadeIn(delay: (2000 + index * 100).ms).slideX(begin: 0.3);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            'Sign Out',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement sign out logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed out successfully'),
                    backgroundColor: AppTheme.accent,
                  ),
                );
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}