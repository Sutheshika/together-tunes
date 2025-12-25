const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const bcrypt = require('bcryptjs');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: true,
    methods: ["GET", "POST"],
    credentials: true
  }
});

const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors({
  origin: true,
  credentials: true
}));
app.use(express.json());

// In-memory storage (replace with database in production)
const users = [];
const rooms = new Map(); // roomId -> { name, host, members, currentSong, position, isPlaying, lastUpdate }
const roomMembers = new Map(); // roomId -> Set<socketId>
const socketToUser = new Map(); // socketId -> { userId, username, roomId }

// Authentication endpoints
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;
    
    // Check if user already exists
    const existingUser = users.find(u => u.email === email || u.username === username);
    if (existingUser) {
      return res.status(400).json({ 
        error: 'User already exists with this email or username' 
      });
    }
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Create new user
    const newUser = {
      id: Date.now().toString(),
      username,
      email,
      password: hashedPassword,
      createdAt: new Date().toISOString()
    };
    
    users.push(newUser);
    
    // Return user without password
    const { password: _, ...userResponse } = newUser;
    res.status(201).json({
      message: 'User registered successfully',
      user: userResponse
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Find user by email or username
    const user = users.find(u => u.email === email || u.username === email);
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Return user without password
    const { password: _, ...userResponse } = user;
    res.json({
      message: 'Login successful',
      user: userResponse
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Room management endpoints
app.get('/api/rooms', (req, res) => {
  const roomList = Array.from(rooms.entries()).map(([id, room]) => ({
    id,
    name: room.name,
    host: room.host,
    memberCount: room.members.length,
    isLive: room.isPlaying,
    currentSong: room.currentSong || 'No song playing'
  }));
  
  res.json({ rooms: roomList });
});

app.post('/api/rooms', (req, res) => {
  const { name, hostId, hostName } = req.body;
  const roomId = `room_${Date.now()}`;
  
  const newRoom = {
    name,
    host: hostName,
    hostId,
    members: [{ id: hostId, name: hostName }],
    currentSong: null,
    position: 0,
    isPlaying: false,
    lastUpdate: Date.now()
  };
  
  rooms.set(roomId, newRoom);
  
  res.status(201).json({
    message: 'Room created successfully',
    room: { id: roomId, ...newRoom }
  });
});

// Socket.io for real-time communication
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);
  
  // Join room
  socket.on('join-room', ({ roomId, userId, username }) => {
    socket.join(roomId);
    
    // Store user info
    socketToUser.set(socket.id, { userId, username, roomId });
    
    // Add to room members tracking
    if (!roomMembers.has(roomId)) {
      roomMembers.set(roomId, new Set());
    }
    roomMembers.get(roomId).add(socket.id);
    
    // Update room member list
    const room = rooms.get(roomId);
    if (room) {
      const existingMember = room.members.find(m => m.id === userId);
      if (!existingMember) {
        room.members.push({ id: userId, name: username });
      }
    }
    
    console.log(`${username} joined room ${roomId}`);
    
    // Notify others in the room
    socket.to(roomId).emit('user-joined', {
      userId,
      username,
      memberCount: roomMembers.get(roomId).size
    });
    
    // Send current room state to the new user
    if (room) {
      socket.emit('room-state', {
        currentSong: room.currentSong,
        position: room.position,
        isPlaying: room.isPlaying,
        host: room.hostId,
        members: room.members
      });
    }
  });
  
  // Leave room
  socket.on('leave-room', ({ roomId }) => {
    socket.leave(roomId);
    
    const userInfo = socketToUser.get(socket.id);
    if (userInfo) {
      // Remove from room members
      const members = roomMembers.get(roomId);
      if (members) {
        members.delete(socket.id);
      }
      
      // Update room member list
      const room = rooms.get(roomId);
      if (room) {
        room.members = room.members.filter(m => m.id !== userInfo.userId);
      }
      
      console.log(`${userInfo.username} left room ${roomId}`);
      
      // Notify others
      socket.to(roomId).emit('user-left', {
        userId: userInfo.userId,
        username: userInfo.username,
        memberCount: members ? members.size : 0
      });
    }
    
    socketToUser.delete(socket.id);
  });
  
  // Music player events
  socket.on('play-song', ({ roomId, songData, position = 0 }) => {
    const room = rooms.get(roomId);
    const userInfo = socketToUser.get(socket.id);
    
    if (room && userInfo && userInfo.userId === room.hostId) {
      room.currentSong = songData;
      room.position = position;
      room.isPlaying = true;
      room.lastUpdate = Date.now();
      
      console.log(`Host ${userInfo.username} started playing: ${songData.title}`);
      
      // Broadcast to all room members
      io.to(roomId).emit('song-started', {
        songData,
        position,
        timestamp: room.lastUpdate
      });
    }
  });
  
  socket.on('pause-song', ({ roomId }) => {
    const room = rooms.get(roomId);
    const userInfo = socketToUser.get(socket.id);
    
    if (room && userInfo && userInfo.userId === room.hostId) {
      room.isPlaying = false;
      room.lastUpdate = Date.now();
      
      console.log(`Host ${userInfo.username} paused the song`);
      
      io.to(roomId).emit('song-paused', {
        position: room.position,
        timestamp: room.lastUpdate
      });
    }
  });
  
  socket.on('resume-song', ({ roomId }) => {
    const room = rooms.get(roomId);
    const userInfo = socketToUser.get(socket.id);
    
    if (room && userInfo && userInfo.userId === room.hostId) {
      room.isPlaying = true;
      room.lastUpdate = Date.now();
      
      console.log(`Host ${userInfo.username} resumed the song`);
      
      io.to(roomId).emit('song-resumed', {
        position: room.position,
        timestamp: room.lastUpdate
      });
    }
  });
  
  socket.on('seek-song', ({ roomId, position }) => {
    const room = rooms.get(roomId);
    const userInfo = socketToUser.get(socket.id);
    
    if (room && userInfo && userInfo.userId === room.hostId) {
      room.position = position;
      room.lastUpdate = Date.now();
      
      console.log(`Host ${userInfo.username} seeked to position: ${position}`);
      
      io.to(roomId).emit('song-seeked', {
        position,
        timestamp: room.lastUpdate
      });
    }
  });
  
  socket.on('sync-position', ({ roomId, position }) => {
    const room = rooms.get(roomId);
    const userInfo = socketToUser.get(socket.id);
    
    if (room && userInfo && userInfo.userId === room.hostId) {
      room.position = position;
      room.lastUpdate = Date.now();
    }
  });
  
  // Chat messages
  socket.on('chat-message', ({ roomId, message }) => {
    const userInfo = socketToUser.get(socket.id);
    
    if (userInfo) {
      const chatMessage = {
        userId: userInfo.userId,
        username: userInfo.username,
        message,
        timestamp: new Date().toISOString()
      };
      
      console.log(`Chat in ${roomId} from ${userInfo.username}: ${message}`);
      
      // Broadcast to all room members including sender
      io.to(roomId).emit('chat-message', chatMessage);
    }
  });
  
  // Handle disconnect
  socket.on('disconnect', () => {
    const userInfo = socketToUser.get(socket.id);
    
    if (userInfo) {
      const { roomId, username } = userInfo;
      
      // Remove from room members
      const members = roomMembers.get(roomId);
      if (members) {
        members.delete(socket.id);
      }
      
      // Update room member list
      const room = rooms.get(roomId);
      if (room) {
        room.members = room.members.filter(m => m.id !== userInfo.userId);
        
        // If room is empty, delete it
        if (room.members.length === 0) {
          rooms.delete(roomId);
          roomMembers.delete(roomId);
          console.log(`Room ${roomId} deleted - no members left`);
        }
      }
      
      console.log(`${username} disconnected from room ${roomId}`);
      
      // Notify others
      socket.to(roomId).emit('user-left', {
        userId: userInfo.userId,
        username,
        memberCount: members ? members.size : 0
      });
    }
    
    socketToUser.delete(socket.id);
    console.log('User disconnected:', socket.id);
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    rooms: rooms.size,
    connectedUsers: socketToUser.size
  });
});

server.listen(PORT, () => {
  console.log(`🎵 Together Tunes server running on port ${PORT}`);
  console.log(`🚀 Socket.io ready for real-time music sync`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
});

module.exports = { app, server, io };