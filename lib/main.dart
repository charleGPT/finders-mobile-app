// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:finders_v1_1/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes.dart'; // Import your RouteManager here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB1VfcMZg9QhMu-Xbx8uipRAlPy3qi8Bd8",
      appId: "1:1056042698190:android:2d1a63fba0ba0ae00d979f",
      messagingSenderId: "1056042698190",
      projectId: "findersmvc",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finders App',
      initialRoute: '/splash',
      onGenerateRoute: RouteManager.generateRoute,
      routes: {
        '/splash': (context) => SplashScreen(), // Define splash screen route
        RouteManager.mainPage: (context) => MainPage(), // Your main page
        // Add other routes from RouteManager here
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the main page after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100], // Background color from your image
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icon in the middle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.person, // Placeholder for the image icon
                  size: 100,
                  color: Colors.black,
                ),
              ),
            ),

            Text(
              'FINDERS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // Bottom version text
            Container(
              padding: EdgeInsets.only(bottom: 15.0),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
