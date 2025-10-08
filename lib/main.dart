import 'package:flutter/material.dart';
import 'package:healix/login_page.dart'; // The app now starts with the login page

void main() {
  runApp(const HealixApp());
}

class HealixApp extends StatefulWidget {
  const HealixApp({super.key});

  @override
  State<HealixApp> createState() => _HealixAppState();
}

class _HealixAppState extends State<HealixApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healix',
      // This ThemeData is now the single source of truth for your app's styling.
      theme: ThemeData(
        primaryColor: const Color(0xFF00796B),
        scaffoldBackgroundColor: const Color(0xFFF6FAF9), // Light green-white for a clean look
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          brightness: Brightness.light,
          primary: const Color(0xFF00796B),
          secondary: const Color(0xFF004D40),
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // The app's starting point is now the unified login screen.
      home: const LoginPage(),
    );
  }
}

