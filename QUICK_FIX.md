# 🚀 QUICK FIX - Network Error (2 minutes)

## Your Problem
Sign up/login gives "Network error"

## The Fix (3 Steps)

### 1️⃣ Get Your IP
Open Command Prompt:
```
ipconfig
```
Find the line that says **IPv4 Address**: `192.168.1.100` (example)

### 2️⃣ Update Config File
Edit: `lib/config/api_config.dart`

Find:
```dart
static const String baseUrl = 'http://localhost:3001';
```

Replace with (use YOUR IP from step 1):
```dart
static const String baseUrl = 'http://192.168.1.100:3001';
```

### 3️⃣ Rebuild App
```bash
flutter clean
flutter pub get
flutter run
```

## Done! ✅
Try signing up/logging in - should work now!

---

## Common Issues

| Issue | Fix |
|-------|-----|
| Still get network error | Backend not running: `cd backend && node sync_server.js` |
| "Connection refused" | Wrong IP address or backend not running |
| Can't find IPv4 | Run `ipconfig` again, look for your WiFi adapter |
| App crashes on rebuild | Delete `/build` folder, then `flutter clean` |

## Need More Help?
Read: `NETWORK_ERROR_FIX.md` (detailed guide)

---

**Backend must be running on port 3001 for this to work!**

Check: http://192.168.1.100:3001/health in your browser (replace IP)
