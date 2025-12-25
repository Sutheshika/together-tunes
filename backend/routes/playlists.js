const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

// Create playlist
router.post('/create', authenticateToken, async (req, res) => {
  try {
    const { name, description, isCollaborative, isPrivate } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'Playlist name is required' });
    }

    const playlist = await prisma.playlist.create({
      data: {
        name,
        description,
        creatorId: req.user.id,
        isCollaborative: isCollaborative || false,
        isPrivate: isPrivate !== undefined ? isPrivate : true
      },
      include: {
        creator: {
          select: { id: true, username: true, avatar: true }
        },
        songs: true
      }
    });

    // Add creator as owner member
    await prisma.playlistMember.create({
      data: {
        playlistId: playlist.id,
        userId: req.user.id,
        role: 'OWNER'
      }
    });

    res.status(201).json({
      message: 'Playlist created successfully',
      playlist
    });

  } catch (error) {
    console.error('Create playlist error:', error);
    res.status(500).json({ error: 'Failed to create playlist' });
  }
});

// Get user's playlists
router.get('/my-playlists', authenticateToken, async (req, res) => {
  try {
    const playlists = await prisma.playlist.findMany({
      where: {
        OR: [
          { creatorId: req.user.id },
          {
            members: {
              some: { userId: req.user.id }
            }
          }
        ]
      },
      include: {
        creator: {
          select: { id: true, username: true, avatar: true }
        },
        songs: {
          orderBy: { position: 'asc' }
        },
        _count: {
          select: { songs: true }
        }
      },
      orderBy: { updatedAt: 'desc' }
    });

    res.json({ playlists });
  } catch (error) {
    console.error('Get playlists error:', error);
    res.status(500).json({ error: 'Failed to get playlists' });
  }
});

// Add song to playlist
router.post('/:playlistId/songs', authenticateToken, async (req, res) => {
  try {
    const { playlistId } = req.params;
    const { title, artist, album, duration, spotifyId, youtubeId } = req.body;

    if (!title || !artist) {
      return res.status(400).json({ error: 'Title and artist are required' });
    }

    // Check if user has permission to add songs
    const playlist = await prisma.playlist.findUnique({
      where: { id: playlistId },
      include: {
        members: {
          where: { userId: req.user.id }
        }
      }
    });

    if (!playlist) {
      return res.status(404).json({ error: 'Playlist not found' });
    }

    const userMembership = playlist.members[0];
    if (!userMembership && playlist.creatorId !== req.user.id) {
      return res.status(403).json({ error: 'No permission to add songs to this playlist' });
    }

    // Get next position
    const lastSong = await prisma.playlistSong.findFirst({
      where: { playlistId },
      orderBy: { position: 'desc' }
    });

    const nextPosition = lastSong ? lastSong.position + 1 : 0;

    // Add song
    const song = await prisma.playlistSong.create({
      data: {
        playlistId,
        title,
        artist,
        album,
        duration,
        spotifyId,
        youtubeId,
        addedBy: req.user.id,
        position: nextPosition
      }
    });

    res.status(201).json({
      message: 'Song added to playlist',
      song
    });

  } catch (error) {
    console.error('Add song error:', error);
    res.status(500).json({ error: 'Failed to add song to playlist' });
  }
});

module.exports = router;