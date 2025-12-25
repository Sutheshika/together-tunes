/// Mock music library for testing and demo purposes
/// In production, this would be replaced with actual music API

class MockMusicLibrary {
  static const List<Map<String, dynamic>> songs = [
    {
      'id': 'song_1',
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'album': 'After Hours',
      'duration': 200,
      'cover': 'https://via.placeholder.com/300x300/FF1744/FFFFFF?text=Blinding+Lights',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    },
    {
      'id': 'song_2',
      'title': 'Levitating',
      'artist': 'Dua Lipa',
      'album': 'Future Nostalgia',
      'duration': 203,
      'cover': 'https://via.placeholder.com/300x300/2196F3/FFFFFF?text=Levitating',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    },
    {
      'id': 'song_3',
      'title': 'Uptown Funk',
      'artist': 'Mark Ronson ft. Bruno Mars',
      'album': 'Uptown Special',
      'duration': 269,
      'cover': 'https://via.placeholder.com/300x300/FF6F00/FFFFFF?text=Uptown+Funk',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    },
    {
      'id': 'song_4',
      'title': 'Pump It Up',
      'artist': 'Elvis Costello',
      'album': 'Armed Forces',
      'duration': 194,
      'cover': 'https://via.placeholder.com/300x300/9C27B0/FFFFFF?text=Pump+It+Up',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    },
    {
      'id': 'song_5',
      'title': 'Midnight City',
      'artist': 'M83',
      'album': 'Hurry Up, We\'re Dreaming',
      'duration': 244,
      'cover': 'https://via.placeholder.com/300x300/00BCD4/FFFFFF?text=Midnight+City',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    },
  ];

  static const List<Map<String, dynamic>> playlists = [
    {
      'id': 'playlist_1',
      'name': 'Chill Vibes',
      'description': 'Relaxing music for study and work',
      'cover': 'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Chill',
      'songCount': 25,
      'isPublic': true,
    },
    {
      'id': 'playlist_2',
      'name': 'Party Mode',
      'description': 'Upbeat tracks to get the party started',
      'cover': 'https://via.placeholder.com/150x150/FF5722/FFFFFF?text=Party',
      'songCount': 30,
      'isPublic': true,
    },
    {
      'id': 'playlist_3',
      'name': 'Focus Flow',
      'description': 'Deep house and electronica',
      'cover': 'https://via.placeholder.com/150x150/673AB7/FFFFFF?text=Focus',
      'songCount': 15,
      'isPublic': false,
    },
    {
      'id': 'playlist_4',
      'name': 'Throwback Classics',
      'description': 'Songs that defined the decades',
      'cover': 'https://via.placeholder.com/150x150/3F51B5/FFFFFF?text=Classics',
      'songCount': 40,
      'isPublic': true,
    },
  ];

  static const List<Map<String, dynamic>> recommendations = [
    {
      'type': 'song',
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'cover': 'https://via.placeholder.com/100x100/FF1744/FFFFFF?text=Blinding',
      'reason': 'Popular in your room',
    },
    {
      'type': 'playlist',
      'title': 'Chill Vibes',
      'artist': 'Together Tunes',
      'cover': 'https://via.placeholder.com/100x100/4CAF50/FFFFFF?text=Chill',
      'reason': 'Trending now',
    },
    {
      'type': 'artist',
      'title': 'The Weeknd',
      'artist': 'Artist',
      'cover': 'https://via.placeholder.com/100x100/FF1744/FFFFFF?text=Weeknd',
      'reason': 'You might like',
    },
  ];

  static Map<String, dynamic>? getSongById(String id) {
    try {
      return songs.firstWhere((song) => song['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? getPlaylistById(String id) {
    try {
      return playlists.firstWhere((playlist) => playlist['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> searchSongs(String query) {
    final lowerQuery = query.toLowerCase();
    return songs
        .where((song) =>
            song['title'].toLowerCase().contains(lowerQuery) ||
            song['artist'].toLowerCase().contains(lowerQuery) ||
            song['album'].toLowerCase().contains(lowerQuery))
        .toList();
  }

  static List<Map<String, dynamic>> searchPlaylists(String query) {
    final lowerQuery = query.toLowerCase();
    return playlists
        .where((playlist) =>
            playlist['name'].toLowerCase().contains(lowerQuery) ||
            playlist['description'].toLowerCase().contains(lowerQuery))
        .toList();
  }
}