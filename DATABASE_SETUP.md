# 🗄️ Database Setup Guide for Together Tunes

## Overview

This guide shows you how to set up PostgreSQL database for Together Tunes to persist user data, rooms, and chat history.

---

## Prerequisites

### 1. PostgreSQL Installation

**Windows:**
- Download: https://www.postgresql.org/download/windows/
- Run installer and follow prompts
- Remember the postgres password you set
- Default port: 5432

**macOS:**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### 2. Node.js Dependencies

```bash
cd backend
npm install
```

---

## Quick Setup (5 minutes)

### Step 1: Configure Database Connection

Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` with your PostgreSQL credentials:
```
DATABASE_URL="postgresql://postgres:your_password@localhost:5432/together_tunes"
PORT=3001
NODE_ENV=development
JWT_SECRET=your_super_secret_jwt_key_here
```

**Replace with your actual PostgreSQL password** (the one you set during installation).

### Step 2: Create Database and Run Migrations

**Windows (Recommended - Use batch file):**
```bash
cd backend
.\setup-database.bat
```

**macOS/Linux (Use shell script):**
```bash
cd backend
chmod +x setup-database.sh
./setup-database.sh
```

**Manual Step-by-step:**
```bash
# Run Prisma migrations to create tables
npx prisma migrate dev --name init

# Generate Prisma client
npx prisma generate

# (Optional) View database in GUI
npx prisma studio
```

### Step 3: Start Server with Database

```bash
npm run start:db
```

You should see:
```
✅ Database connected
🚀 Server running on http://localhost:3001
```

---

## Verification

### 1. Check Database Connection

Visit in browser: `http://localhost:3001/health`

Should return:
```json
{
  "status": "Server running",
  "database": "Connected via Prisma",
  "timestamp": "2025-12-27T..."
}
```

### 2. View Database in Prisma Studio

```bash
npx prisma studio
```

This opens a GUI at `http://localhost:5555` where you can:
- Browse all tables
- Add/edit/delete records
- See database schema

### 3. Test User Registration

```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

Should return:
```json
{
  "message": "User registered successfully",
  "user": {...}
}
```

---

## Database Schema

### Users Table
```
✓ id (unique ID)
✓ username (unique)
✓ email (unique)
✓ password (hashed)
✓ avatar (profile picture)
✓ status (ONLINE/OFFLINE/LISTENING)
✓ createdAt, updatedAt
```

### Rooms Table
```
✓ id (unique ID)
✓ name (room name)
✓ creatorId (host user)
✓ isActive (true if room exists)
✓ currentSong (JSON - song metadata)
✓ playbackPosition (current time in song)
✓ isPlaying (true if playing)
✓ syncTimestamp (for sync calculation)
✓ createdAt, updatedAt
```

### Messages Table
```
✓ id (unique ID)
✓ roomId (which room)
✓ senderId (who sent it)
✓ content (message text)
✓ type (TEXT/VOICE/PHOTO)
✓ createdAt
```

### RoomParticipants Table
```
✓ id (unique ID)
✓ roomId (which room)
✓ userId (which user)
✓ joinedAt
```

### Playlists & PlaylistSongs
```
✓ For future playlist feature
✓ Store user playlists
✓ Track songs in playlists
```

---

## Troubleshooting

### Error: "ECONNREFUSED 127.0.0.1:5432"

**Problem:** PostgreSQL is not running

**Solution:**
- **Windows:** Start PostgreSQL service in Services.msc or use pgAdmin
- **macOS:** `brew services start postgresql@15`
- **Linux:** `sudo systemctl start postgresql`

### Error: "password authentication failed"

**Problem:** Wrong PostgreSQL password in .env

**Solution:**
1. Verify your PostgreSQL password
2. Update DATABASE_URL in .env
3. Make sure it's url-encoded if it contains special characters

### Error: "database 'together_tunes' does not exist"

**Solution:**
```bash
npx prisma migrate dev --name init
```

This automatically creates the database and tables.

### Error: "relation 'users' does not exist"

**Solution:**
```bash
npx prisma db push
```

This pushes the schema to database.

### Can't log in to PostgreSQL

```bash
# Try logging in as postgres user
psql -U postgres

# Then check if db exists
\l

# Create database manually if needed
CREATE DATABASE together_tunes;
```

---

## Common Commands

```bash
# Start server with database
npm run start:db

# Development mode with auto-reload
npm run dev:db

# View database GUI
npx prisma studio

# Create new migration
npx prisma migrate dev --name add_feature

# Reset database (⚠️ DELETES ALL DATA)
npx prisma migrate reset

# Generate Prisma client
npx prisma generate

# Check schema
npx prisma validate
```

---

## Data Persistence Now Working

✅ User accounts persist across app restarts  
✅ Room history is saved  
✅ Chat messages stored in database  
✅ User login history tracked  
✅ Ready for production deployment  

---

## Next: Real Music API

After database is working, add real music:
- Spotify API integration
- YouTube Music API
- Real song search and selection

See `DATABASE_SETUP.md` for integration guide.

---

## Support

If you encounter issues:
1. Check PostgreSQL is running
2. Verify DATABASE_URL in .env
3. Check logs in terminal
4. Try: `npx prisma migrate dev --name init`
5. Try: `npx prisma db push`

For more help, see DEVELOPER_GUIDE.md
