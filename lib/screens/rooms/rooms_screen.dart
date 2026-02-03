import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../../services/user_service.dart';
import '../../services/rooms_service.dart';
import 'room_player_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late UserService _userService;
  late RoomsService _roomsService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Changed from 3 to 2
    _userService = UserService();
    _roomsService = RoomsService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
              _buildSearchBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyRooms(),
                    _buildBrowseRooms(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRoomDialog,
        backgroundColor: AppTheme.primaryColor,
        label: const Text('Create Room'),
        icon: const Icon(Icons.add),
      ).animate().scale(delay: 1000.ms).fadeIn(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Music Rooms',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideX(begin: -0.3),
                Text(
                  'Listen together with friends',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.2),
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.qr_code_scanner,
                color: AppTheme.textPrimary,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search rooms...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
          ),
        ),
      ).animate().fadeIn(delay: 600.ms).slideY(begin: -0.3),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'My Rooms'),
            Tab(text: 'Browse'),
          ],
        ),
      ).animate().fadeIn(delay: 800.ms).slideY(begin: -0.3),
    );
  }

  Widget _buildBrowseRooms_old() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 10,
      itemBuilder: (context, index) {
        final rooms = [
          {
            'name': 'Chill Lounge',
            'host': 'Sarah Johnson',
            'listeners': 12,
            'genre': 'Lo-Fi Hip Hop',
            'isLive': true,
            'song': 'Moonlight Sonata'
          },
          {
            'name': 'Pop Hits Central',
            'host': 'Alex Chen',
            'listeners': 25,
            'genre': 'Pop',
            'isLive': true,
            'song': 'Blinding Lights'
          },
          {
            'name': 'Rock Legends',
            'host': 'Mike Wilson',
            'listeners': 8,
            'genre': 'Classic Rock',
            'isLive': false,
            'song': 'Bohemian Rhapsody'
          },
          {
            'name': 'Jazz Corner',
            'host': 'Emma Davis',
            'listeners': 6,
            'genre': 'Jazz',
            'isLive': true,
            'song': 'Take Five'
          },
          {
            'name': 'EDM Party Zone',
            'host': 'DJ Storm',
            'listeners': 30,
            'genre': 'Electronic',
            'isLive': true,
            'song': 'Titanium'
          },
        ];

        final room = rooms[index % rooms.length];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            onTap: () => _joinRoom(room['name'] as String),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  room['name'] as String,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: room['isLive'] as bool
                                      ? AppTheme.accent
                                      : AppTheme.textSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  room['isLive'] as bool ? 'LIVE' : 'OFFLINE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Hosted by ${room['host']}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${room['listeners']} listeners • ${room['genre']}',
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Now playing: ${room['song']}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    GradientButton(
                      text: 'Join',
                      onPressed: () => _joinRoom(room['name'] as String),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (1000 + index * 100).ms).slideX(begin: 0.3);
      },
    );
  }

  Widget _buildMyRooms() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _roomsService.roomsStream,
      initialData: _roomsService.userRooms,
      builder: (context, snapshot) {
        final rooms = snapshot.data ?? [];
        
        if (rooms.isEmpty) {
          // Empty state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 60,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No rooms yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first room to start listening with friends',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Create Room',
                  onPressed: _showCreateRoomDialog,
                  icon: Icons.add,
                ),
              ],
            ).animate().fadeIn().scale(),
          );
        }
        
        // Show list of user's rooms
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _buildRoomCard(room);
          },
        );
      },
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
          ),
        ),
        title: Text(
          room['name'] ?? 'Unnamed Room',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${room['members']?.length ?? 1} member${(room['members']?.length ?? 1) != 1 ? 's' : ''}',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoomPlayerScreen(
                roomId: room['id'],
                roomName: room['name'],
                isHost: true, // User is the creator of their own rooms
                members: List<String>.from(
                  (room['members'] as List?)?.map((m) => m['name'] ?? 'Unknown') ?? ['You'] ?? []
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildBrowseRooms() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore,
              size: 60,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Browse Coming Soon',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse public rooms from other users',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_outline,
              size: 60,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No favorites yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Heart rooms you love to find them here later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  void _joinRoom(String roomName) {
    // Generate mock room data
    final roomId = 'room_${roomName.hashCode}';
    final mockMembers = ['You', 'Sarah Johnson', 'Alex Chen', 'Mike Wilson'];
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RoomPlayerScreen(
          roomName: roomName,
          roomId: roomId,
          isHost: roomName == 'Chill Vibes Hub', // Make user host of first room
          members: mockMembers,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showCreateRoomDialog() {
    final TextEditingController roomNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            'Create Room',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  hintText: 'Enter room name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Describe your room',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            GradientButton(
              text: 'Create',
              onPressed: () async {
                if (roomNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room name cannot be empty')),
                  );
                  return;
                }
                
                try {
                  final response = await http.post(
                    Uri.parse('http://localhost:3001/api/rooms'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'name': roomNameController.text,
                      'hostId': 'user_${DateTime.now().millisecondsSinceEpoch}',
                      'hostName': 'You',
                    }),
                  );
                  
                  if (response.statusCode == 201) {
                    final roomData = jsonDecode(response.body)['room'];
                    
                    // Add room to RoomsService
                    final user = _userService.getUserData();
                    _roomsService.addRoom(
                      roomId: roomData['id'] ?? 'room_${DateTime.now().millisecondsSinceEpoch}',
                      roomName: roomData['name'],
                      hostId: user?['userId'] ?? 'user_unknown',
                      hostName: user?['username'] ?? 'You',
                    );
                    
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoomPlayerScreen(
                          roomId: roomData['id'],
                          roomName: roomData['name'],
                          isHost: true,
                          members: [user?['username'] ?? 'You'],
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Room created successfully!'),
                        backgroundColor: AppTheme.accent,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating room: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}