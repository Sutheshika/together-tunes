const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const { PrismaClient } = require('@prisma/client');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: true,
    methods: ["GET", "POST"],
    credentials: true
  }
});

const prisma = new PrismaClient();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors({
  origin: true,
  credentials: true
}));
app.use(express.json());

// Runtime data (for real-time features that don't need persistence)
const roomMembers = new Map(); // roomId -> Set<socketId>
const socketToUser = new Map(); // socketId -> { userId, username, roomId }

// ========================
// Authentication Endpoints
// ========================

app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Validation
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    // Check if user already exists
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          { email },
          { username }
        ]
      }
    });

    if (existingUser) {
      return res.status(400).json({ 
        error: 'User already exists with this email or username' 
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create new user
    const newUser = await prisma.user.create({
      data: {
        username,
        email,
        password: hashedPassword,
        status: 'OFFLINE'
      }
    });

    console.log(`✅ User registered: ${username}`);

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: newUser.id,
        username: newUser.username,
        email: newUser.email
      }
    });

  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user by email or username
    const user = await prisma.user.findFirst({
      where: {
        OR: [
          { email },
          { username: email }
        ]
      }
    });

    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Update user status to online
    await prisma.user.update({
      where: { id: user.id },
      data: { status: 'ONLINE' }
    });

    console.log(`✅ User logged in: ${user.username}`);

    res.status(200).json({
      message: 'Login successful',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        status: 'ONLINE'
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

// ========================
// Room Endpoints
// ========================

app.get('/api/rooms', async (req, res) => {
  try {
    const rooms = await prisma.room.findMany({
      where: { isActive: true },
      include: {
        creator: {
          select: { id: true, username: true }
        },
        participants: {
          include: {
            user: {
              select: { id: true, username: true }
            }
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({
      rooms: rooms.map(room => ({
        id: room.id,
        name: room.name,
        host: room.creator.username,
        members: room.participants.map(p => p.user.username),
        memberCount: room.participants.length,
        isPlaying: room.isPlaying,
        currentSong: room.currentSong,
        createdAt: room.createdAt
      }))
    });

  } catch (error) {
    console.error('Get rooms error:', error);
    res.status(500).json({ error: 'Failed to fetch rooms' });
  }
});

app.post('/api/rooms', async (req, res) => {
  try {
    const { name, creatorId } = req.body;

    if (!name || !creatorId) {
      return res.status(400).json({ error: 'Room name and creator ID are required' });
    }

    // Verify creator exists
    const creator = await prisma.user.findUnique({
      where: { id: creatorId }
    });

    if (!creator) {
      return res.status(404).json({ error: 'Creator not found' });
    }

    // Create room
    const newRoom = await prisma.room.create({
      data: {
        name,
        creatorId,
        isActive: true,
        isPlaying: false,
        playbackPosition: 0
      },
      include: {
        creator: {
          select: { id: true, username: true }
        }
      }
    });

    // Add creator as first participant
    await prisma.roomParticipant.create({
      data: {
        roomId: newRoom.id,
        userId: creatorId
      }
    });

    console.log(`✅ Room created: ${name} (${newRoom.id})`);

    res.status(201).json({
      message: 'Room created successfully',
      room: {
        id: newRoom.id,
        name: newRoom.name,
        host: newRoom.creator.username,
        members: [newRoom.creator.username]
      }
    });

  } catch (error) {
    console.error('Create room error:', error);
    res.status(500).json({ error: 'Failed to create room' });
  }
});

// ========================
// Health Check
// ========================

app.get('/health', (req, res) => {
  res.json({
    status: 'Server running',
    timestamp: new Date().toISOString(),
    database: 'Connected via Prisma'
  });
});

// ========================
// Socket.io Events
// ========================

io.on('connection', (socket) => {
  console.log(`🔌 New connection: ${socket.id}`);

  // User joins room
  socket.on('join-room', async (data) => {
    try {
      const { roomId, userId, username } = data;
      console.log(`✅ ${username} joining room ${roomId}`);

      // Store socket-to-user mapping
      socketToUser.set(socket.id, { userId, username, roomId });

      // Add to room members tracking
      if (!roomMembers.has(roomId)) {
        roomMembers.set(roomId, new Set());
      }
      roomMembers.get(roomId).add(socket.id);

      // Join socket.io room
      socket.join(roomId);

      // Get room participants from database
      const participants = await prisma.roomParticipant.findMany({
        where: { roomId },
        include: {
          user: {
            select: { id: true, username: true }
          }
        }
      });

      // Notify all users in room
      io.to(roomId).emit('user-joined', {
        username,
        members: participants.map(p => p.user.username),
        totalMembers: participants.length
      });

    } catch (error) {
      console.error('Join room error:', error);
      socket.emit('error', { message: 'Failed to join room' });
    }
  });

  // User leaves room
  socket.on('leave-room', async (data) => {
    try {
      const userData = socketToUser.get(socket.id);
      if (!userData) return;

      const { roomId, username } = data;
      console.log(`❌ ${username} leaving room ${roomId}`);

      socket.leave(roomId);

      if (roomMembers.has(roomId)) {
        roomMembers.get(roomId).delete(socket.id);
        if (roomMembers.get(roomId).size === 0) {
          roomMembers.delete(roomId);

          // Mark room as inactive if empty
          await prisma.room.update({
            where: { id: roomId },
            data: { isActive: false }
          });
        }
      }

      // Notify remaining users
      io.to(roomId).emit('user-left', { username });

    } catch (error) {
      console.error('Leave room error:', error);
    }
  });

  // Play song
  socket.on('play-song', async (data) => {
    try {
      const { roomId, song } = data;
      
      // Update room state
      await prisma.room.update({
        where: { id: roomId },
        data: {
          isPlaying: true,
          currentSong: song,
          playbackPosition: 0,
          syncTimestamp: new Date()
        }
      });

      io.to(roomId).emit('song-started', { song, position: 0 });
      console.log(`▶️  Playing: ${song.title}`);

    } catch (error) {
      console.error('Play song error:', error);
    }
  });

  // Pause song
  socket.on('pause-song', async (data) => {
    try {
      const { roomId, position } = data;

      await prisma.room.update({
        where: { id: roomId },
        data: { isPlaying: false, playbackPosition: position }
      });

      io.to(roomId).emit('song-paused', { position });
      console.log(`⏸️  Paused at ${position}s`);

    } catch (error) {
      console.error('Pause song error:', error);
    }
  });

  // Resume song
  socket.on('resume-song', async (data) => {
    try {
      const { roomId } = data;

      await prisma.room.update({
        where: { id: roomId },
        data: { isPlaying: true }
      });

      io.to(roomId).emit('song-resumed');
      console.log(`▶️  Resumed`);

    } catch (error) {
      console.error('Resume song error:', error);
    }
  });

  // Seek to position
  socket.on('seek-song', async (data) => {
    try {
      const { roomId, position } = data;

      await prisma.room.update({
        where: { id: roomId },
        data: { playbackPosition: position, syncTimestamp: new Date() }
      });

      io.to(roomId).emit('song-seeked', { position });
      console.log(`⏩ Seeked to ${position}s`);

    } catch (error) {
      console.error('Seek song error:', error);
    }
  });

  // Sync position (periodic updates)
  socket.on('sync-position', (data) => {
    const { roomId, position } = data;
    io.to(roomId).emit('sync-position', { position });
  });

  // Chat message
  socket.on('chat-message', async (data) => {
    try {
      const { roomId, message, username } = data;

      // Store message in database
      await prisma.message.create({
        data: {
          roomId,
          senderId: socketToUser.get(socket.id)?.userId || 'unknown',
          content: message,
          type: 'TEXT'
        }
      });

      // Broadcast to room
      io.to(roomId).emit('chat-message', { username, message, timestamp: new Date() });
      console.log(`💬 ${username}: ${message}`);

    } catch (error) {
      console.error('Chat message error:', error);
    }
  });

  // Disconnect
  socket.on('disconnect', () => {
    const userData = socketToUser.get(socket.id);
    if (userData) {
      const { roomId, username } = userData;
      
      socket.leave(roomId);
      if (roomMembers.has(roomId)) {
        roomMembers.get(roomId).delete(socket.id);
      }
      
      io.to(roomId).emit('user-left', { username });
      console.log(`🔌 Disconnected: ${username}`);
    }

    socketToUser.delete(socket.id);
  });
});

// ========================
// Server Startup
// ========================

async function startServer() {
  try {
    // Test database connection
    await prisma.$connect();
    console.log('✅ Database connected');

    // Start server
    server.listen(PORT, () => {
      console.log(`\n🎵 Together Tunes Server`);
      console.log(`========================`);
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`📊 Database: Connected via Prisma`);
      console.log(`🔌 WebSocket: Socket.io active`);
      console.log(`\n💾 API Endpoints:`);
      console.log(`   POST   /api/auth/register - Register new user`);
      console.log(`   POST   /api/auth/login    - Login user`);
      console.log(`   GET    /api/rooms         - Get all rooms`);
      console.log(`   POST   /api/rooms         - Create room`);
      console.log(`   GET    /health            - Health check`);
      console.log(`\n`);
    });

  } catch (error) {
    console.error('❌ Failed to start server:', error.message);
    console.error('\n⚠️  Troubleshooting:');
    console.error('   1. Make sure PostgreSQL is running');
    console.error('   2. Check DATABASE_URL in .env file');
    console.error('   3. Run: npx prisma migrate dev --name init');
    console.error('   4. Run: npx prisma db push');
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n\n🛑 Shutting down gracefully...');
  await prisma.$disconnect();
  process.exit(0);
});

startServer();
