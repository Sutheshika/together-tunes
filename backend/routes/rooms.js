const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

// Create a listening room
router.post('/create', authenticateToken, async (req, res) => {
  try {
    const { name } = req.body;

    const room = await prisma.room.create({
      data: {
        name: name || `${req.user.username}'s Room`,
        creatorId: req.user.id,
        isActive: true
      },
      include: {
        creator: {
          select: { id: true, username: true, avatar: true }
        },
        participants: {
          include: {
            user: {
              select: { id: true, username: true, avatar: true, status: true }
            }
          }
        }
      }
    });

    // Add creator as participant
    await prisma.roomParticipant.create({
      data: {
        roomId: room.id,
        userId: req.user.id
      }
    });

    res.status(201).json({
      message: 'Room created successfully',
      room
    });

  } catch (error) {
    console.error('Create room error:', error);
    res.status(500).json({ error: 'Failed to create room' });
  }
});

// Get user's active rooms
router.get('/my-rooms', authenticateToken, async (req, res) => {
  try {
    const rooms = await prisma.room.findMany({
      where: {
        isActive: true,
        OR: [
          { creatorId: req.user.id },
          {
            participants: {
              some: { userId: req.user.id }
            }
          }
        ]
      },
      include: {
        creator: {
          select: { id: true, username: true, avatar: true }
        },
        participants: {
          include: {
            user: {
              select: { id: true, username: true, avatar: true, status: true }
            }
          }
        }
      },
      orderBy: { updatedAt: 'desc' }
    });

    res.json({ rooms });
  } catch (error) {
    console.error('Get rooms error:', error);
    res.status(500).json({ error: 'Failed to get rooms' });
  }
});

// Join a room
router.post('/:roomId/join', authenticateToken, async (req, res) => {
  try {
    const { roomId } = req.params;

    // Check if room exists and is active
    const room = await prisma.room.findUnique({
      where: { id: roomId },
      include: { participants: true }
    });

    if (!room || !room.isActive) {
      return res.status(404).json({ error: 'Room not found or inactive' });
    }

    // Check if user is already in the room
    const existingParticipant = room.participants.find(p => p.userId === req.user.id);
    if (existingParticipant) {
      return res.status(409).json({ error: 'Already in this room' });
    }

    // Add user to room
    await prisma.roomParticipant.create({
      data: {
        roomId,
        userId: req.user.id
      }
    });

    // Get updated room info
    const updatedRoom = await prisma.room.findUnique({
      where: { id: roomId },
      include: {
        creator: {
          select: { id: true, username: true, avatar: true }
        },
        participants: {
          include: {
            user: {
              select: { id: true, username: true, avatar: true, status: true }
            }
          }
        }
      }
    });

    res.json({
      message: 'Joined room successfully',
      room: updatedRoom
    });

  } catch (error) {
    console.error('Join room error:', error);
    res.status(500).json({ error: 'Failed to join room' });
  }
});

module.exports = router;