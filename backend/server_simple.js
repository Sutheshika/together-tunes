const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
require('dotenv').config();

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

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: '🎵 Together Tunes Backend is running!',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    features: [
      'Real-time music sync',
      'Friend system',
      'Shared playlists',
      'Chat messaging'
    ]
  });
});

// Test endpoint for API
app.get('/api/test', (req, res) => {
  res.json({
    message: '🎶 Together Tunes API is working!',
    endpoints: [
      'GET /health - Health check',
      'GET /api/test - This endpoint',
      'WebSocket /socket.io - Real-time features'
    ]
  });
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('🎵 User connected:', socket.id);
  
  // Send welcome message
  socket.emit('welcome', {
    message: 'Connected to Together Tunes!',
    socketId: socket.id
  });

  // Test event handlers
  socket.on('test_sync', (data) => {
    console.log('Test sync received:', data);
    socket.broadcast.emit('test_sync_response', {
      originalData: data,
      timestamp: new Date().toISOString(),
      from: socket.id
    });
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

server.listen(PORT, () => {
  console.log(`🎵 Together Tunes Backend running on port ${PORT}`);
  console.log(`🔗 Socket.IO server ready for real-time music sync!`);
  console.log(`🌐 Health check: http://localhost:${PORT}/health`);
  console.log(`🛠️  API test: http://localhost:${PORT}/api/test`);
});