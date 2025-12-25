const io = require('socket.io-client');

// Test client to verify Socket.io functionality
const client1 = io('http://localhost:3001');
const client2 = io('http://localhost:3001');

const roomId = 'test-room';
const mockSong = {
  title: 'Blinding Lights',
  artist: 'The Weeknd',
  album: 'After Hours',
  cover: 'https://via.placeholder.com/300x300'
};

client1.on('connect', () => {
  console.log('Client 1 connected');
  
  // Join room as host
  client1.emit('join-room', {
    roomId: roomId,
    userId: 'user1',
    username: 'Alice (Host)'
  });
});

client2.on('connect', () => {
  console.log('Client 2 connected');
  
  // Join room as guest
  client2.emit('join-room', {
    roomId: roomId,
    userId: 'user2',
    username: 'Bob (Guest)'
  });
});

// Listen for music events
client2.on('song-started', (data) => {
  console.log('Client 2 received song-started:', data.songData.title);
});

client2.on('song-paused', (data) => {
  console.log('Client 2 received song-paused at position:', data.position);
});

client2.on('song-resumed', (data) => {
  console.log('Client 2 received song-resumed at position:', data.position);
});

client2.on('user-joined', (data) => {
  console.log(`User joined: ${data.username}`);
});

// Test sequence
setTimeout(() => {
  console.log('Starting song...');
  client1.emit('play-song', {
    roomId: roomId,
    songData: mockSong,
    position: 0
  });
}, 2000);

setTimeout(() => {
  console.log('Pausing song...');
  client1.emit('pause-song', {
    roomId: roomId
  });
}, 4000);

setTimeout(() => {
  console.log('Resuming song...');
  client1.emit('resume-song', {
    roomId: roomId
  });
}, 6000);

setTimeout(() => {
  console.log('Test completed, disconnecting...');
  client1.disconnect();
  client2.disconnect();
  process.exit(0);
}, 8000);