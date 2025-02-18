# 🚨 CROWDSOURCING HAZARD INFORMATION SYSTEM
===========================================

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

# 📱 About Our Project
A powerful Flutter mobile application for real-time hazard reporting and community safety monitoring. This system enables citizens to actively participate in maintaining community safety through crowdsourced hazard reporting.

# 🎯 Key Features
- 📍 Real-time hazard reporting
- 🗺️ Interactive hazard mapping
- 🔐 Secure user authentication
- 📊 Comprehensive admin dashboard
- 📰 Community news feed
- 📱 Cross-platform support
- 🌍 Location-based services

# ⚡ Before Starting
Ensure you have the following installed:
- 📱 Flutter → Flutter SDK installed
- 🔥 Database → Firebase
  
## 🚀 Getting Started
Flutter App Setup

### Step 1: Create a Flutter Project
```bash
flutter create hazard_reporting_app
```

### Step 2: Add Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^3.11.0
  cloud_firestore: ^5.6.2
  firebase_auth: ^5.4.1
  fluttertoast: ^8.2.10
  flutter_map: ^5.0.0
  latlong2: ^0.9.0
  geolocator: ^10.1.0
  url_launcher: ^6.3.1
  intl: ^0.18.1
  shared_preferences: ^2.5.2
  geocoding: ^3.0.0
```

### Step 3: Set Up Firebase 🔥
1. Go to Firebase Console
2. Add Firebase to Your Flutter App
3. Enable Firestore Database & Authentication

### Step 4: Project Structure 📁
```
lib\
├── main.dart               # Entry point
├── models\
│   └── hazard.dart        # Hazard model
└── screens\
    ├── about_screen.dart   # About app
    ├── admin_screen.dart   # Admin dashboard
    ├── login_screen.dart   # User login
    ├── map_screen.dart     # Hazard map
    ├── news_screen.dart    # News feed
    └── report_screen.dart  # Hazard reporting
```

### Step 5: Run the Application 🚀
```bash
flutter run
```

## 📋 Technical Requirements
- Flutter SDK (latest version)
- Firebase account
- Android Studio or VS Code
- Git

## 📱 Supported Platforms
- 🤖 Android
- 🍎 iOS

---
Made with ❤️ by [Our Team]
