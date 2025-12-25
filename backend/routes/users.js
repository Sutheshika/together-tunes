const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

// Get user profile
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true,
        username: true,
        email: true,
        avatar: true,
        status: true,
        createdAt: true
      }
    });

    res.json({ user });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Failed to get profile' });
  }
});

// Get user's friends
router.get('/friends', authenticateToken, async (req, res) => {
  try {
    const friendships = await prisma.friendship.findMany({
      where: {
        OR: [
          { user1Id: req.user.id },
          { user2Id: req.user.id }
        ],
        status: 'ACCEPTED'
      },
      include: {
        user1: {
          select: { id: true, username: true, avatar: true, status: true }
        },
        user2: {
          select: { id: true, username: true, avatar: true, status: true }
        }
      }
    });

    const friends = friendships.map(friendship => {
      return friendship.user1Id === req.user.id ? friendship.user2 : friendship.user1;
    });

    res.json({ friends });
  } catch (error) {
    console.error('Get friends error:', error);
    res.status(500).json({ error: 'Failed to get friends' });
  }
});

// Send friend request
router.post('/friends/request', authenticateToken, async (req, res) => {
  try {
    const { username } = req.body;

    if (!username) {
      return res.status(400).json({ error: 'Username is required' });
    }

    // Find target user
    const targetUser = await prisma.user.findUnique({
      where: { username }
    });

    if (!targetUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (targetUser.id === req.user.id) {
      return res.status(400).json({ error: 'Cannot send friend request to yourself' });
    }

    // Check if friendship already exists
    const existingFriendship = await prisma.friendship.findFirst({
      where: {
        OR: [
          { user1Id: req.user.id, user2Id: targetUser.id },
          { user1Id: targetUser.id, user2Id: req.user.id }
        ]
      }
    });

    if (existingFriendship) {
      return res.status(409).json({ error: 'Friend request already exists or you are already friends' });
    }

    // Create friendship
    const friendship = await prisma.friendship.create({
      data: {
        user1Id: req.user.id,
        user2Id: targetUser.id,
        status: 'PENDING'
      }
    });

    res.json({
      message: 'Friend request sent',
      friendship: {
        id: friendship.id,
        targetUser: {
          id: targetUser.id,
          username: targetUser.username
        }
      }
    });

  } catch (error) {
    console.error('Send friend request error:', error);
    res.status(500).json({ error: 'Failed to send friend request' });
  }
});

module.exports = router;