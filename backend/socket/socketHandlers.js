module.exports = (io, socket, prisma) => {
  console.log('🎵 Socket connected:', socket.id);

  // Store user info in socket
  socket.userId = null;
  socket.currentRoom = null;

  // User authentication for socket
  socket.on('authenticate', async (data) => {
    try {
      const { userId } = data;
      
      // Update user status and store in socket
      await prisma.user.update({
        where: { id: userId },
        data: { status: 'ONLINE' }
      });

      socket.userId = userId;
      console.log(`User ${userId} authenticated on socket ${socket.id}`);
      
      socket.emit('authenticated', { success: true });
    } catch (error) {
      console.error('Socket auth error:', error);
      socket.emit('authenticated', { success: false, error: 'Authentication failed' });
    }
  });

  // Join a listening room
  socket.on('join_room', async (data) => {
    try {
      const { roomId } = data;
      
      if (!socket.userId) {
        return socket.emit('error', { message: 'Not authenticated' });
      }

      // Leave previous room if any
      if (socket.currentRoom) {
        socket.leave(socket.currentRoom);
        socket.to(socket.currentRoom).emit('user_left', {
          userId: socket.userId,
          roomId: socket.currentRoom
        });
      }

      // Join new room
      socket.join(roomId);
      socket.currentRoom = roomId;

      // Get room info with current state
      const room = await prisma.room.findUnique({
        where: { id: roomId },
        include: {
          participants: {
            include: {
              user: {
                select: { id: true, username: true, avatar: true, status: true }
              }
            }
          }
        }
      });

      if (!room) {
        return socket.emit('error', { message: 'Room not found' });
      }

      // Send current room state to the joining user
      socket.emit('room_state', {
        roomId,
        currentSong: room.currentSong,
        playbackPosition: room.playbackPosition,
        isPlaying: room.isPlaying,
        syncTimestamp: room.syncTimestamp,
        participants: room.participants
      });

      // Notify others in the room
      socket.to(roomId).emit('user_joined', {
        userId: socket.userId,
        roomId
      });

      console.log(`User ${socket.userId} joined room ${roomId}`);

    } catch (error) {
      console.error('Join room error:', error);
      socket.emit('error', { message: 'Failed to join room' });
    }
  });

  // Handle music playback events
  socket.on('play_song', async (data) => {
    try {
      const { roomId, song, position = 0 } = data;
      
      if (!socket.userId || socket.currentRoom !== roomId) {
        return socket.emit('error', { message: 'Not in this room' });
      }

      const syncTimestamp = new Date();

      // Update room state in database
      await prisma.room.update({
        where: { id: roomId },
        data: {
          currentSong: song,
          playbackPosition: position,
          isPlaying: true,
          syncTimestamp
        }
      });

      // Broadcast to all users in the room
      io.to(roomId).emit('song_started', {
        song,
        position,
        syncTimestamp,
        startedBy: socket.userId
      });

      console.log(`Song started in room ${roomId} by user ${socket.userId}`);

    } catch (error) {
      console.error('Play song error:', error);
      socket.emit('error', { message: 'Failed to start song' });
    }
  });

  socket.on('pause_song', async (data) => {
    try {
      const { roomId, position } = data;
      
      if (!socket.userId || socket.currentRoom !== roomId) {
        return socket.emit('error', { message: 'Not in this room' });
      }

      const syncTimestamp = new Date();

      // Update room state
      await prisma.room.update({
        where: { id: roomId },
        data: {
          playbackPosition: position,
          isPlaying: false,
          syncTimestamp
        }
      });

      // Broadcast to all users in the room
      io.to(roomId).emit('song_paused', {
        position,
        syncTimestamp,
        pausedBy: socket.userId
      });

      console.log(`Song paused in room ${roomId} by user ${socket.userId}`);

    } catch (error) {
      console.error('Pause song error:', error);
      socket.emit('error', { message: 'Failed to pause song' });
    }
  });

  socket.on('resume_song', async (data) => {
    try {
      const { roomId, position } = data;
      
      if (!socket.userId || socket.currentRoom !== roomId) {
        return socket.emit('error', { message: 'Not in this room' });
      }

      const syncTimestamp = new Date();

      // Update room state
      await prisma.room.update({
        where: { id: roomId },
        data: {
          playbackPosition: position,
          isPlaying: true,
          syncTimestamp
        }
      });

      // Broadcast to all users in the room
      io.to(roomId).emit('song_resumed', {
        position,
        syncTimestamp,
        resumedBy: socket.userId
      });

      console.log(`Song resumed in room ${roomId} by user ${socket.userId}`);

    } catch (error) {
      console.error('Resume song error:', error);
      socket.emit('error', { message: 'Failed to resume song' });
    }
  });

  socket.on('seek_song', async (data) => {
    try {
      const { roomId, position } = data;
      
      if (!socket.userId || socket.currentRoom !== roomId) {
        return socket.emit('error', { message: 'Not in this room' });
      }

      const syncTimestamp = new Date();

      // Update room state
      await prisma.room.update({
        where: { id: roomId },
        data: {
          playbackPosition: position,
          syncTimestamp
        }
      });

      // Broadcast to all users in the room
      io.to(roomId).emit('song_seeked', {
        position,
        syncTimestamp,
        seekedBy: socket.userId
      });

      console.log(`Song seeked to ${position}s in room ${roomId} by user ${socket.userId}`);

    } catch (error) {
      console.error('Seek song error:', error);
      socket.emit('error', { message: 'Failed to seek song' });
    }
  });

  // Chat messages
  socket.on('send_message', async (data) => {
    try {
      const { roomId, content, type = 'TEXT' } = data;
      
      if (!socket.userId || socket.currentRoom !== roomId) {
        return socket.emit('error', { message: 'Not in this room' });
      }

      // Save message to database
      const message = await prisma.message.create({
        data: {
          roomId,
          senderId: socket.userId,
          content,
          type
        },
        include: {
          sender: {
            select: { id: true, username: true, avatar: true }
          }
        }
      });

      // Broadcast message to room
      io.to(roomId).emit('new_message', message);

    } catch (error) {
      console.error('Send message error:', error);
      socket.emit('error', { message: 'Failed to send message' });
    }
  });

  // Handle disconnection
  socket.on('disconnect', async () => {
    console.log('User disconnected:', socket.id);
    
    if (socket.userId) {
      try {
        // Update user status
        await prisma.user.update({
          where: { id: socket.userId },
          data: { status: 'OFFLINE' }
        });

        // Notify room if user was in one
        if (socket.currentRoom) {
          socket.to(socket.currentRoom).emit('user_left', {
            userId: socket.userId,
            roomId: socket.currentRoom
          });
        }
      } catch (error) {
        console.error('Disconnect cleanup error:', error);
      }
    }
  });
};