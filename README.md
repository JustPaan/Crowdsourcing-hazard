
# CROWDSOURCING HAZARD INFORMATION SYSTEM
=======
# groupproject

crowdsourcing is a flutter mobile application

# Before starting
Ensure you have the following installed:
- Flutter → Flutter SDK installed
- Database → Firebase
  
## Getting Started

Flutter App Setup

Step 1: Create a Flutter Project

flutter create hazard_reporting_app

Step 2: Add Dependencies (pubspec.yaml)

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

Step 3: Set Up Firebase

Go to Firebase Console
Add Firebase to Your Flutter App
Enable Firestore Database & Authentication

Step 4: Build the User Interface

lib\
|--> main.dart
|--> models\
|    |--> hazard.dart        # Hazard model
|--> screens\
|    |--> about_screen.dart   # About app
|    |--> admin_screen.dart   # Admin dashboard
|    |--> login_screen.dart   # User login
|    |--> map_screen.dart     # Displays hazard map
|    |--> news_screen.dart    # Displays news
|    |--> report_screen.dart  # Users report hazards

Step 5: Run the Application
