# together_tunes

# 🎵 Together Tunes

A synchronized music listening app that lets friends listen to the same song in perfect sync, no matter how far apart they are.

## 🌟 Features

- **Real-time Music Sync** - Listen together in perfect synchronization
- **Friend System** - Connect with friends via username, QR code, or link invite
- **Shared Listening Rooms** - Create rooms for synchronized listening sessions
- **Real-time Chat** - Chat while listening together
- **Collaborative Playlists** - Create and manage playlists together
- **Cross-platform** - Available on iOS and Android

## 🛠 Tech Stack

### Frontend (Mobile App)
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **socket_io_client** - Real-time communication
- **just_audio** - Music playback control
- **flutter_riverpod** - State management

### Backend (Server)
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **Socket.io** - Real-time communication
- **Prisma ORM** - Database ORM
- **PostgreSQL** - Database

## 📁 Project Structure

```
together_tunes/
├── lib/                    # Flutter frontend
│   ├── main.dart
│   └── ...
├── backend/                # Node.js backend
│   ├── server.js          # Main server file
│   ├── routes/            # API routes
│   ├── socket/            # Socket.IO handlers
│   ├── middleware/        # Authentication middleware
│   └── prisma/            # Database schema
├── android/               # Android platform files
├── ios/                   # iOS platform files
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.8.1 or higher)
- **Node.js** (18 or higher)
- **PostgreSQL** (or use Prisma's local database)
- **Dart** (comes with Flutter)

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

4. **Generate Prisma client:**
   ```bash
   npm run db:generate
   ```

5. **Push database schema:**
   ```bash
   npm run db:push
   ```

6. **Start the server:**
   ```bash
   npm run dev
   ```

The backend will be running on `http://localhost:3000`

### Frontend Setup

1. **Navigate to project root:**
   ```bash
   cd ..
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 🚧 Development Status

This is the initial setup with core infrastructure in place. 

✅ **Completed**
- Backend structure with Express.js and Socket.io
- Prisma database schema for users, rooms, playlists
- JWT authentication system
- Real-time communication setup
- Flutter app structure with dependencies

🔄 **Next Steps**
- Implement Flutter UI screens
- Connect Flutter to backend APIs
- Add music playback functionality
- Build friend system features
- Create room management interface

---

**"Let's listen to this together" → even when you're not together.** 🎵❤️
