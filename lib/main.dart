// lib/main.dart

import 'package:flutter/material.dart';
import 'package:healix/login_page.dart';
import 'package:healix/doctor_dashboard.dart'; // Or a central home page
import 'package:healix/auth_service.dart'; // Make sure you have this service

void main() {
  runApp(const HealixApp());
}

// The root widget should be stateless. It just defines the app's theme and entry point.
class HealixApp extends StatelessWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healix',
      theme: ThemeData( // Your consistent app theme
        primaryColor: const Color(0xFF00796B),
        scaffoldBackgroundColor: Colors.grey[50],
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          brightness: Brightness.light,
          primary: const Color(0xFF00796B),
          secondary: const Color(0xFF004D40),
        ),
        fontFamily: 'Inter',
        // ... add other theme properties like cardTheme, appBarTheme etc.
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthCheck(), // Start with the stateful AuthCheck widget
    );
  }
}

// This stateful widget handles the logic of checking if a user is logged in
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authService.getRefreshToken(), // Check for a stored token
      builder: (context, snapshot) {
        // Show a loading screen while checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If a token exists, the user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const DoctorDashboardScreen(); // Navigate to the main dashboard
        }

        // Otherwise, show the login page
        return LoginPage();
      },
    );
  }
}