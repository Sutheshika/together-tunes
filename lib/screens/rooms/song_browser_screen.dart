import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../../services/playlist_service.dart';
import '../../services/mock_music_library.dart';

class SongBrowserScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const SongBrowserScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<SongBrowserScreen> createState() => _SongBrowserScreenState();
}

class _SongBrowserScreenState extends State<SongBrowserScreen> {
  late PlaylistService _playlistService;
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _allSongs = [];
  List<Map<String, dynamic>> _filteredSongs = [];
  Set<String> _addedSongs = {};

  @override
  void initState() {
    super.initState();
    _playlistService = PlaylistService();
    _searchController = TextEditingController();
    _allSongs = _playlistService.getAllSongs();
    _filteredSongs = _allSongs;
    
    // Initialize playlist for this room
    _playlistService.initializeRoomPlaylist(widget.roomId);
    
    // Get already added songs
    final queue = _playlistService.getQueue(widget.roomId);
    _addedSongs = Set.from(queue.map((s) => s['id']));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSongs(String query) {
    if (query.isEmpty) {
      setState(() => _filteredSongs = _allSongs);
    } else {
      final results = _playlistService.searchSongs(query);
      setState(() => _filteredSongs = results);
    }
  }

  void _addSongToPlaylist(Map<String, dynamic> song) {
    _playlistService.addSongToPlaylist(widget.roomId, song);
    setState(() => _addedSongs.add(song['id']));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${song['title']}" to queue'),
        backgroundColor: AppTheme.accent,
        duration: const Duration(seconds: 2),
      ),
    );
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
              // Header with back button
              Padding(
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
                            'Add Songs',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'to ${widget.roomName}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSongs,
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _filterSongs('');
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),
              ),

              const SizedBox(height: 16),

              // Song list
              Expanded(
                child: _filteredSongs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_note_outlined,
                              size: 64,
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No songs found',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = _filteredSongs[index];
                          final isAdded = _addedSongs.contains(song['id']);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(isAdded ? 0.5 : 0.2),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(song['cover']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                song['title'],
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${song['artist']} • ${_formatDuration(song['duration'])}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isAdded
                                      ? AppTheme.primaryColor
                                      : AppTheme.surfaceColor,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: isAdded ? null : () => _addSongToPlaylist(song),
                                  icon: Icon(
                                    isAdded ? Icons.check : Icons.add,
                                    color: isAdded ? Colors.white : AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ).animate().fadeIn().slideX();
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
