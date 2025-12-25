# 🎵 Together Tunes - Quick Start Guide

## 🚀 5-Minute Setup

### Step 1: Start the Backend Server

```bash
cd backend
node sync_server.js
```

Expected output:
```
🎵 Together Tunes server running on port 3001
🚀 Socket.io ready for real-time music sync
📊 Health check: http://localhost:3001/health
```

### Step 2: Start the Flutter App

```bash
flutter pub get
flutter run
```

### Step 3: Test Real-time Sync

1. **On Device 1 (Host)**:
   - Login/Register
   - Go to Rooms tab
   - Click "Join Room" on "Chill Vibes Hub"

2. **On Device 2 (Guest)**:
   - Login/Register  
   - Go to Rooms tab
   - Click "Join Room" on "Chill Vibes Hub"

3. **Back on Device 1 (Host)**:
   - Click the Play button on the music player
   - The song should start playing

4. **On Device 2 (Guest)**:
   - You'll see the same song playing in real-time!
   - Try seeking, pausing, resuming on Device 1
   - Device 2 updates instantly

## 🎯 Core Features to Try

### Music Playback
- ✅ Click **Play** button (Host only)
- ✅ Seek with the **progress slider** (Host only)
- ✅ Click **Pause** to stop playback
- ✅ See **real-time position updates** on all devices

### Chat
- ✅ Type in the **chat input** at the bottom
- ✅ See messages appear **instantly** for all room members
- ✅ View **member avatars** and **online status**

### Member Management
- ✅ See **active members** with status indicators
- ✅ Watch **member count update** when others join/leave
- ✅ Green indicator = online, Accent color = listening

## 📱 Device Setup Options

### Option 1: Two Emulators
```bash
flutter emulators
flutter run -d <emulator1>
# In another terminal:
flutter run -d <emulator2>
```

### Option 2: Physical Device + Emulator
```bash
flutter devices
flutter run -d <device_id>
```

### Option 3: Web (for testing on same machine)
```bash
flutter run -d chrome
# And in another terminal:
flutter run -d edge
```

## 🔧 Backend API Testing

### Check Server Health
```bash
curl http://localhost:3001/health
```

### Get Available Rooms
```bash
curl http://localhost:3001/api/rooms
```

### Test Authentication
```bash
# Register
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'

# Login
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "login": "testuser",
    "password": "password123"
  }'
```

## 🎧 Available Songs

The mock library includes these songs (all publicly available):

1. **Blinding Lights** - The Weeknd (200s)
2. **Levitating** - Dua Lipa (203s)
3. **Uptown Funk** - Mark Ronson ft. Bruno Mars (269s)
4. **Pump It Up** - Elvis Costello (194s)
5. **Midnight City** - M83 (244s)

## 📊 Real-time Sync Explanation

```
Timeline Example:

Host Device                    Network (Socket.io)              Guest Device
─────────────────────────────────────────────────────────────────────────────

                User joins room
                      ├──────────────────────────────────────>
                                                            Load room state
                                                            Show members

Play button clicked
├─ Start audio playback
├─ Emit 'play-song' event
       │
       ├──────────────────────────────────────>
                                        Receive 'song-started'
                                        ├─ Load same song
                                        ├─ Start playback
                                        └─ Sync position to host's time

Position: 5s  ──┐
Position: 10s  ├──────────────────────────────────────>
Position: 15s  │    (Stream of position updates)
Position: 20s  │
               └─ Receive 'sync-position' events
                  ├─ Update local position to match
                  └─ Keep audio in sync (±500ms accuracy)
```

## 🐛 Troubleshooting

### Server Won't Start
```
Error: Port 3001 already in use
→ Kill the process: netstat -ano | findstr :3001
   taskkill /PID <PID> /F
```

### Emulator Can't Connect to Backend
```
By default, emulators connect to 10.0.2.2:3001 (Android)
Update: const String baseUrl = 'http://10.0.2.2:3001';
```

### No Sound Playing
```
1. Check audio service logs
2. Ensure URL is accessible: https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3
3. Check device volume settings
```

### Real-time Sync Not Working
```
1. Verify backend server is running on port 3001
2. Check device network connectivity
3. Look at console logs for Socket.io connection errors
```

## 📈 Performance Tips

### For Smooth Playback
- ✅ Use WiFi connection (not cellular)
- ✅ Close background apps to free memory
- ✅ Use release build: `flutter run --release`

### For Testing Multiple Users
- ✅ Run emulators on a powerful machine (8GB+ RAM)
- ✅ Or use multiple physical devices
- ✅ Or use web with multiple browser tabs

## 🔐 Security Features (In Place)

- ✅ Password hashing with bcrypt
- ✅ Host-only playback control
- ✅ Socket.io connection validation
- ✅ Per-socket user identification
- ✅ Room-level access control

## 📦 What's Installed

### Backend
- Express 5.1.0 - Web server
- Socket.io 4.8.1 - Real-time communication
- bcryptjs 3.0.3 - Password hashing
- CORS 2.8.5 - Cross-origin requests

### Frontend
- Flutter 3.8.1 - Mobile framework
- just_audio 0.9.40 - Audio playback ⭐
- socket_io_client 2.0.3 - Real-time client
- flutter_animate 4.5.0 - Animations
- http 1.1.2 - HTTP requests

## 🎓 Learning Resources

### Understanding Real-time Sync
1. **Socket.io Basics**: Bidirectional communication between client & server
2. **Event Streaming**: Server broadcasts position updates continuously
3. **Position Sync**: Guest's audio position = Host's position ± network latency
4. **Audio Playback**: just_audio handles all audio rendering

### Code Structure
```
lib/
├── main.dart                 # App entry point
├── screens/                  # All UI screens
│   ├── auth/                # Authentication flows
│   ├── home/                # Dashboard
│   ├── rooms/               # Room browsing & player
│   └── ...
├── services/
│   ├── socket_service.dart  # Socket.io client
│   ├── audio_service.dart   # Audio playback
│   └── mock_music_library.dart # Sample data
└── widgets/
    ├── music_player.dart    # Music player UI + sync logic
    └── custom_widgets.dart  # Reusable components

backend/
├── sync_server.js           # Main server with Socket.io
├── package.json             # Dependencies
└── middleware/              # Auth, error handling
```

## 🚀 Next Level

### Add Real Music Streaming
```dart
// Replace mock URLs with Spotify/YouTube Music API
// Example: spotify:track:xxx or youtube.com/watch?v=xxx
```

### Enable Database
```bash
# Setup PostgreSQL
npm run db:generate
npm run db:push
```

### Deploy to Cloud
```bash
# Node.js: AWS, Heroku, Railway, Render
# Flutter: Google Play, App Store, Web hosting
```

---

**You're all set! 🎉 Enjoy real-time music synchronization with friends!**

For more details, see [IMPLEMENTATION_STATUS.md](./IMPLEMENTATION_STATUS.md)