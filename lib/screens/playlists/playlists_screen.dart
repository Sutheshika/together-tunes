import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                    _buildMyPlaylists(),
                    _buildSharedPlaylists(),
                    _buildDiscoverPlaylists(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePlaylistDialog,
        backgroundColor: AppTheme.primaryColor,
        label: const Text('New Playlist'),
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
                  'Playlists',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideX(begin: -0.3),
                Text(
                  'Your music collections',
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
                Icons.library_music,
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
          hintText: 'Search playlists...',
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
            Tab(text: 'My Playlists'),
            Tab(text: 'Shared'),
            Tab(text: 'Discover'),
          ],
        ),
      ).animate().fadeIn(delay: 800.ms).slideY(begin: -0.3),
    );
  }

  Widget _buildMyPlaylists() {
    final playlists = [
      {
        'name': 'Chill Vibes',
        'songs': 24,
        'duration': '1h 32m',
        'cover': Icons.water_drop,
        'isPublic': true,
      },
      {
        'name': 'Workout Mix',
        'songs': 18,
        'duration': '58m',
        'cover': Icons.fitness_center,
        'isPublic': false,
      },
      {
        'name': 'Study Focus',
        'songs': 32,
        'duration': '2h 15m',
        'cover': Icons.school,
        'isPublic': true,
      },
      {
        'name': 'Road Trip',
        'songs': 45,
        'duration': '3h 8m',
        'cover': Icons.directions_car,
        'isPublic': true,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            onTap: () => _openPlaylist(playlist['name'] as String),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    playlist['cover'] as IconData,
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
                              playlist['name'] as String,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            (playlist['isPublic'] as bool) 
                                ? Icons.public 
                                : Icons.lock,
                            color: AppTheme.textSecondary,
                            size: 16,
                          ),
                        ],
                      ),
                      Text(
                        '${playlist['songs']} songs • ${playlist['duration']}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showPlaylistOptions(playlist['name'] as String),
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (1000 + index * 100).ms).slideX(begin: 0.3);
      },
    );
  }

  Widget _buildSharedPlaylists() {
    final sharedPlaylists = [
      {
        'name': 'Party Mix 2024',
        'owner': 'Sarah Johnson',
        'songs': 35,
        'duration': '2h 28m',
        'cover': Icons.celebration,
        'collaborators': 5,
      },
      {
        'name': 'Indie Discoveries',
        'owner': 'Alex Chen',
        'songs': 22,
        'duration': '1h 45m',
        'cover': Icons.explore,
        'collaborators': 3,
      },
      {
        'name': 'Throwback Thursday',
        'owner': 'Mike Wilson',
        'songs': 40,
        'duration': '2h 52m',
        'cover': Icons.history,
        'collaborators': 8,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sharedPlaylists.length,
      itemBuilder: (context, index) {
        final playlist = sharedPlaylists[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            onTap: () => _openPlaylist(playlist['name'] as String),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accent,
                        AppTheme.primaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    playlist['cover'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist['name'] as String,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'By ${playlist['owner']}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${playlist['songs']} songs • ${playlist['collaborators']} collaborators',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.group,
                  color: AppTheme.accent,
                  size: 20,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (1000 + index * 100).ms).slideX(begin: 0.3);
      },
    );
  }

  Widget _buildDiscoverPlaylists() {
    final categories = [
      {'name': 'Trending Now', 'icon': Icons.trending_up, 'count': 12},
      {'name': 'New Releases', 'icon': Icons.new_releases, 'count': 8},
      {'name': 'Mood & Genre', 'icon': Icons.mood, 'count': 25},
      {'name': 'Charts', 'icon': Icons.bar_chart, 'count': 15},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn().slideX(begin: -0.3),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              
              return GlassCard(
                onTap: () {},
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${category['count']} playlists',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (1000 + index * 100).ms).scale();
            },
          ),
        ],
      ),
    );
  }

  void _openPlaylist(String playlistName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $playlistName...'),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  void _showPlaylistOptions(String playlistName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: AppTheme.textPrimary),
              title: const Text('Play', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.textPrimary),
              title: const Text('Edit', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppTheme.textPrimary),
              title: const Text('Share', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.error),
              title: const Text('Delete', style: TextStyle(color: AppTheme.error)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            'Create Playlist',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Playlist Name',
                  hintText: 'Enter playlist name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Describe your playlist',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Expanded(
                    child: Text(
                      'Make playlist public',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                ],
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
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Playlist created successfully!'),
                    backgroundColor: AppTheme.accent,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}