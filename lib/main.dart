import 'package:flutter/material.dart';
import 'package:healix/login_page.dart';
import 'package:healix/doctor_dashboard.dart';
import 'package:healix/student_page.dart';
import 'package:healix/caretaker_dashboard.dart';
import 'package:healix/auth_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'api_service.dart'; // For the Doctor dashboard

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApiService(),
      child: const HealixApp(),
    ),
  );
}

class HealixApp extends StatelessWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healix',
      theme: ThemeData(
        primaryColor: const Color(0xFF00796B), // Example teal color
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthCheck(),
    );
  }
}

// A placeholder for non-caretaker staff
class StaffHomepage extends StatelessWidget {
  final String staffId;
  const StaffHomepage({super.key, required this.staffId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Staff Portal (ID: $staffId)')),
      body: const Center(child: Text("Pharmacy, Lab, or Admin Portal")),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final apiService = Provider.of<ApiService>(context, listen: false);

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

          // Pass the token to the ApiService *if* it's a doctor
          if (role == 'doctor') {
            apiService.updateToken(token);
          }

          return _getScreenForRole(role, username);
        }

        return const LoginPage();
      },
    );
  }
}

// Helper function with all 4 roles
Widget _getScreenForRole(String role, String username) {
  switch (role) {
    case 'doctor':
      return const DoctorDashboardScreen();
    case 'student':
      return StudentHomepage(studentId: username);
    case 'caretaker':
      return CaretakerDashboardScreen(caretakerId: username);
    case 'staff':
      return StaffHomepage(staffId: username);
    default:
      return Scaffold(body: Center(child: Text("Unknown role: $role")));
  }
}

