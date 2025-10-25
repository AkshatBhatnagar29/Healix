// // lib/main.dart
//
// import 'package:flutter/material.dart';
// import 'package:healix/login_page.dart';
// import 'package:healix/doctor_dashboard.dart'; // Or a central home page
// import 'package:healix/auth_service.dart'; // Make sure you have this service
//
// void main() {
//   runApp(const HealixApp());
// }
//
// // The root widget should be stateless. It just defines the app's theme and entry point.
// class HealixApp extends StatelessWidget {
//   const HealixApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Healix',
//       theme: ThemeData( // Your consistent app theme
//         primaryColor: const Color(0xFF00796B),
//         scaffoldBackgroundColor: Colors.grey[50],
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF00796B),
//           brightness: Brightness.light,
//           primary: const Color(0xFF00796B),
//           secondary: const Color(0xFF004D40),
//         ),
//         fontFamily: 'Inter',
//         // ... add other theme properties like cardTheme, appBarTheme etc.
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: const AuthCheck(), // Start with the stateful AuthCheck widget
//     );
//   }
// }
//
// // This stateful widget handles the logic of checking if a user is logged in
// class AuthCheck extends StatefulWidget {
//   const AuthCheck({super.key});
//
//   @override
//   State<AuthCheck> createState() => _AuthCheckState();
// }
//
// class _AuthCheckState extends State<AuthCheck> {
//   final AuthService _authService = AuthService();
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _authService.getRefreshToken(), // Check for a stored token
//       builder: (context, snapshot) {
//         // Show a loading screen while checking
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(body: Center(child: CircularProgressIndicator()));
//         }
//
//         // If a token exists, the user is logged in
//         if (snapshot.hasData && snapshot.data != null) {
//           return const DoctorDashboardScreen(); // Navigate to the main dashboard
//         }
//
//         // Otherwise, show the login page
//         return LoginPage();
//       },
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:healix/login_page.dart'; // Make sure login_page.dart exists
import 'package:healix/doctor_dashboard.dart';
import 'package:healix/student_page.dart';
import 'package:healix/caretaker_dashboard.dart';
import 'package:healix/auth_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

void main() {
  runApp(const HealixApp());
}

class HealixApp extends StatelessWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healix',
      theme: ThemeData(
        primaryColor: const Color(0xFF00796B),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  // This widget decides which page to show based on the stored token
  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return FutureBuilder<String?>(
      future: authService.getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final token = snapshot.data;
        if (token != null && !JwtDecoder.isExpired(token)) {
          final decodedToken = JwtDecoder.decode(token);
          final role = decodedToken['role'];
          final username = decodedToken['username'];

          // Route based on role found in the token
          return _getScreenForRole(role, username);
        }

        // No valid token, show login page
        return LoginPage(); // Ensure you have a LoginPage widget
      },
    );
  }
}

// Helper function to get the correct screen for a given role
Widget _getScreenForRole(String role, String username) {
  switch (role) {
    case 'doctor':
      return const DoctorDashboardScreen();
    case 'student':
      return StudentHomepage(studentId: username);
    case 'staff':
      return const CaretakerDashboardScreen();
    default:
    // Fallback to a generic error screen or login page
      return Scaffold(body: Center(child: Text("Unknown role: $role")));
  }
}