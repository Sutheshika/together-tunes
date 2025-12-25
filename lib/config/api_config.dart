// API Configuration
// This file manages the backend server connection details

class ApiConfig {
  // Production: Replace with your actual server URL
  // Examples:
  // - Local network: 'http://192.168.1.100:3001' (replace with your PC IP)
  // - Localhost: 'http://localhost:3001' (only works on same device)
  // - Cloud: 'https://together-tunes-api.com'
  
  static const String baseUrl = 'http://10.11.6.130:3001';
  
  // API Endpoints
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String roomsEndpoint = '/api/rooms';
  
  // Full URLs
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get roomsUrl => '$baseUrl$roomsEndpoint';
  
  // Socket.io Connection
  static String get socketUrl => baseUrl;
  
  // Helper: Get full API URL
  static String getEndpoint(String endpoint) => '$baseUrl$endpoint';
}

// Quick fix instructions:
// 1. Find your PC's IP address:
//    - Windows: Open CMD, type "ipconfig", look for "IPv4 Address" (e.g., 192.168.1.100)
//    - The backend server must be running
//
// 2. Update baseUrl in this file:
//    OLD: static const String baseUrl = 'http://localhost:3001';
//    NEW: static const String baseUrl = 'http://192.168.1.100:3001';
//         (replace 192.168.1.100 with YOUR PC's IP address)
//
// 3. Save the file and rebuild the app:
//    flutter clean
//    flutter pub get
//    flutter run
//
// Then auth should work!
