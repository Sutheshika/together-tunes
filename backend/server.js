const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
require('dotenv').config();

// Import Prisma Client
const { PrismaClient } = require('@prisma/client');

// Initialize Prisma Client
const prisma = new PrismaClient();

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const roomRoutes = require('./routes/rooms');
const playlistRoutes = require('./routes/playlists');

// Import socket handlers
const socketHandlers = require('./socket/socketHandlers');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*", // Configure this properly for production
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/playlists', playlistRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'Together Tunes Backend is running!',
    timestamp: new Date().toISOString(),
    database: 'Connected'
  });
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);
  
  // Initialize socket handlers
  socketHandlers(io, socket, prisma);
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down server...');
  await prisma.$disconnect();
  server.close(() => {
    process.exit(0);
  });
});

server.listen(PORT, async () => {
  console.log(`🎵 Together Tunes Backend running on port ${PORT}`);
  console.log(`🔗 Socket.IO server ready for real-time music sync!`);
  
  // Test database connection
  try {
    await prisma.$connect();
    console.log('✅ Database connected successfully!');
  } catch (error) {
    console.log('⚠️  Database connection failed:', error.message);
  }
});