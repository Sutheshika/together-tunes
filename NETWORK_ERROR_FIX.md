# 🔧 Network Error Fix Guide

**Problem**: Getting "Network error. Please try again." when trying to sign up or login

**Root Cause**: The app is trying to connect to `http://localhost:3001`, but localhost only works on the same device. On a different device or emulator, you need to use your PC's actual IP address.

---

## ✅ Quick Fix (5 minutes)

### Step 1: Find Your PC's IP Address

**Windows:**
1. Open Command Prompt (`cmd`)
2. Type: `ipconfig`
3. Look for **"IPv4 Address"** under your network adapter
4. Copy this address (e.g., `192.168.1.100`)

**macOS/Linux:**
1. Open Terminal
2. Type: `ifconfig` or `ip addr`
3. Look for inet address on your main network adapter

### Step 2: Update the API Configuration

1. Open file: `lib/config/api_config.dart`
2. Find this line:
   ```dart
   static const String baseUrl = 'http://localhost:3001';
   ```
3. Replace with your IP (example):
   ```dart
   static const String baseUrl = 'http://192.168.1.100:3001';
   ```

### Step 3: Rebuild the App

1. In terminal, run:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. When the app restarts, try signing up/logging in again

---

## 🔍 Verify the Backend Server is Running

Before fixing the app, make sure the backend server is running:

**Windows:**
```bash
cd backend
node sync_server.js
```

You should see:
```
🎵 Together Tunes server running on port 3001
🚀 Socket.io ready for real-time music sync
📊 Health check: http://localhost:3001/health
```

**Test in browser:**
- Go to: `http://192.168.1.100:3001/health` (replace IP)
- Should see: `{"status":"ok"}`

---

## 🎯 Different Scenarios

### Scenario 1: Testing on Same PC
- **Use**: `http://localhost:3001`
- **Where**: Both Flutter app and backend on same computer

### Scenario 2: Testing on Physical Device
- **Use**: `http://192.168.1.100:3001` (your PC's IP)
- **Where**: Backend on PC, Flutter app on phone

### Scenario 3: Testing on Android Emulator
- **Use**: `http://10.0.2.2:3001` (special Android emulator IP)
- **Where**: Backend on PC, Flutter app on Android emulator

### Scenario 4: Testing on iOS Simulator
- **Use**: `http://localhost:3001`
- **Where**: Backend on Mac, Flutter app on iOS simulator

### Scenario 5: Cloud Deployment
- **Use**: `https://your-domain.com` (your cloud server URL)
- **Where**: Both on internet

---

## ❓ Troubleshooting

### "Connection refused"
- Backend server is not running
- **Fix**: Start backend: `cd backend && node sync_server.js`

### "Cannot find host"
- IP address is incorrect
- **Fix**: Double-check IP with `ipconfig` command

### "Connection timeout"
- Firewall is blocking port 3001
- **Fix**: Add firewall exception for port 3001 or disable temporarily

### "Server works in browser but not in app"
- Using localhost instead of IP
- **Fix**: Use actual IP address in api_config.dart

### Still getting network error?
1. Verify server is running: `curl http://192.168.1.100:3001/health`
2. Verify Flutter app has internet permission (check AndroidManifest.xml)
3. Check firewall settings
4. Try restarting both server and app

---

## 📝 Notes

- Every time you change `api_config.dart`, you must rebuild with `flutter clean && flutter run`
- The IP address shouldn't change often, but can change if you restart your PC or network
- If testing on multiple devices, they all need to be on the same WiFi network
- On Android emulator, the special IP `10.0.2.2` refers to your host machine's localhost

---

## ✨ Success Checklist

- ✅ Backend server running on port 3001
- ✅ PC IP address identified with `ipconfig`
- ✅ `lib/config/api_config.dart` updated with correct IP
- ✅ App rebuilt with `flutter clean && flutter run`
- ✅ Test device on same WiFi as PC
- ✅ Firewall not blocking port 3001
- ✅ Can access http://[YOUR_IP]:3001/health in browser
- ✅ Sign up/login now works! 🎉
