import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  
import 'screens/map_screen.dart';
import 'screens/report_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/news_screen.dart';
import 'screens/about_screen.dart';
import 'screens/login_screen.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb){  
    await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAX_BaEI7TKVMIx943XyydYXLVtXELcWZQ",
      authDomain: "groupproject-4fcda.firebaseapp.com",
      projectId: "groupproject-4fcda",
      storageBucket: "groupproject-4fcda.firebasestorage.app",
      messagingSenderId: "1005750077146",
      appId: "1:1005750077146:web:d022226455f174285b07e3"
    ));
  }
  else{
    await Firebase.initializeApp();
  }
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hazard Reporting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MapScreen(),
      routes: {
        '/report': (context) => const ReportScreen(),
        '/admin': (context) => AdminScreen(),
        '/news': (context) => const NewsScreen(),
        '/about': (context) => const AboutScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}