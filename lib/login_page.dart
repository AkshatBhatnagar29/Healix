// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:healix/signup_page.dart';
// import 'package:healix/student_page.dart';
// import 'package:healix/doctor_dashboard.dart';
// import 'package:healix/caretaker_dashboard.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:healix/auth_service.dart';
// import 'package:provider/provider.dart';
// import 'package:healix/api_service.dart';
//
// // Placeholder for Staff Homepage (for non-caretaker staff)
// // This is duplicated from main.dart but is fine
// class StaffHomepage extends StatelessWidget {
//   final String staffId;
//   const StaffHomepage({super.key, required this.staffId});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: const Text('Staff Portal (e.g. Pharmacy)')));
//   }
// }
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   String selectedRole = 'Student (Patient)';
//   final TextEditingController idController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _isLoading = false;
//   final LocalAuthentication auth = LocalAuthentication();
//
//   Future<void> _authenticateWithBiometrics() async {
//     // Implement biometric logic here
//   }
//
//   final AuthService _authService = AuthService();
//
//   void _signIn() async {
//     if (idController.text.isEmpty || passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter your username and password.')),
//       );
//       return;
//     }
//     setState(() => _isLoading = true);
//
//     final username = idController.text.trim();
//     final password = passwordController.text.trim();
//
//     try {
//       final result = await _authService.login(username, password);
//
//       if (result['success'] == true) {
//         final role = result['role'] ?? 'unknown';
//         final accessToken = await _authService.getAccessToken();
//
//         if (accessToken == null) {
//           setState(() => _isLoading = false);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Login OK but failed to read token.')),
//           );
//           return;
//         }
//
//         // Navigate based on the role from the token
//         switch (role) {
//           case 'student':
//             Navigator.pushReplacement(context,
//                 MaterialPageRoute(builder: (context) => StudentHomepage(studentId: username)));
//             break;
//           case 'doctor':
//             Provider.of<ApiService>(context, listen: false).updateToken(accessToken);
//             Navigator.pushReplacement(context,
//                 MaterialPageRoute(builder: (context) =>  const DoctorDashboardScreen()));
//             break;
//           case 'caretaker':
//             Navigator.pushReplacement(context,
//                 MaterialPageRoute(builder: (context) => CaretakerDashboardScreen(caretakerId: username)));
//             break;
//           case 'staff':
//             Navigator.pushReplacement(context,
//                 MaterialPageRoute(builder: (context) => StaffHomepage(staffId: username)));
//             break;
//           default:
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Unknown role: $role')),
//             );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login failed: ${result['message']}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   String get idFieldLabel {
//     switch (selectedRole) {
//       case 'Doctor': return 'Enter Doctor ID';
//       case 'Caretaker': return 'Enter Caretaker ID';
//       case 'Staff': return 'Enter Staff ID';
//       default: return 'Enter Student ID / Roll Number';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//           child: Container(
//             width: 380,
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4))],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
//                   child: Icon(Icons.local_hospital_rounded, color: Theme.of(context).primaryColor, size: 36),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text('Healix', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 const Text('Secure access to campus healthcare', style: TextStyle(fontSize: 14, color: Colors.black54)),
//                 const SizedBox(height: 24),
//
//                 // --- 4 Role Tiles ---
//                 _buildRoleTile(title: 'Student (Patient)', subtitle: 'Access medical services, book appointments', icon: Icons.person_outline),
//                 _buildRoleTile(title: 'Doctor', subtitle: 'Manage appointments, create prescriptions', icon: Icons.medical_services_outlined),
//                 _buildRoleTile(title: 'Caretaker', subtitle: 'Hostel alerts and emergency calls', icon: Icons.admin_panel_settings_outlined),
//                 _buildRoleTile(title: 'Staff', subtitle: 'Pharmacy, Lab, or Administrative access', icon: Icons.badge_outlined),
//
//                 const SizedBox(height: 24),
//                 TextField(
//                   controller: idController,
//                   decoration: InputDecoration(labelText: idFieldLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _signIn,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
//                         : const Text('Sign In', style: TextStyle(fontSize: 16)),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text("OR", style: TextStyle(color: Colors.grey)),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     icon: const Icon(Icons.fingerprint),
//                     onPressed: _authenticateWithBiometrics,
//                     label: const Text('Biometric Login'),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Don't have an account?"),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignupPage()));
//                       },
//                       child: const Text('Sign Up'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRoleTile({required String title, required String subtitle, required IconData icon}) {
//     bool isSelected = selectedRole == title;
//     return GestureDetector(
//       onTap: () => setState(() => selectedRole = title),
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(10),
//           color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.white,
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: Theme.of(context).primaryColor),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Theme.of(context).primaryColor : Colors.black87),
//                   ),
//                   Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
//                 ],
//               ),
//             ),
//             Radio<String>(
//               value: title,
//               groupValue: selectedRole,
//               activeColor: Theme.of(context).primaryColor,
//               onChanged: (value) => setState(() => selectedRole = value!),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healix/signup_page.dart' ;
import 'package:healix/student_page.dart' ;
import 'package:healix/doctor_dashboard.dart' ;
import 'package:healix/caretaker_dashboard.dart'; // Make sure this is the right path
import 'package:local_auth/local_auth.dart';
import 'package:healix/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:healix/api_service.dart'; // Make sure this path is correct

// Placeholder for Staff Homepage (for non-caretaker staff)
class StaffHomepage extends StatelessWidget {
  final String staffId;
  const StaffHomepage({super.key, required this.staffId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Staff Portal (e.g. Pharmacy)')));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedRole = 'Student (Patient)';
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _authenticateWithBiometrics() async {
    // ...
  }

  final AuthService _authService = AuthService();

  void _signIn() async {
    if (idController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your username and password.')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final username = idController.text.trim();
    final password = passwordController.text.trim();

    try {
      final result = await _authService.login(username, password);

      if (result['success'] == true) {
        final role = result['role'] ?? 'unknown';
        final accessToken = await _authService.getAccessToken();

        if (accessToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login OK but failed to read token.')),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Navigate based on role
        switch (role) {
          case 'student':
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => StudentHomepage(studentId: username)));
            break;
          case 'doctor':
          // --- THIS IS THE FIX ---
          // You MUST update the ApiService with the token
            Provider.of<ApiService>(context, listen: false)
                .updateToken(accessToken);
            // --- END FIX ---
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DoctorDashboardScreen()));
            break;
          case 'caretaker':
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CaretakerDashboardScreen(caretakerId: username)));
            break;
          case 'staff':
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => StaffHomepage(staffId: username)));
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unknown role: $role')),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${result['message']}')),
        );
      }
    } catch (e) {
      print("[ERROR] Login exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Could not connect to the server. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get idFieldLabel {
    switch (selectedRole) {
      case 'Doctor':
        return 'Enter Doctor ID';
      case 'Caretaker':
        return 'Enter Caretaker ID';
      case 'Staff':
        return 'Enter Staff ID';
      default:
        return 'Enter Student ID / Roll Number';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(Icons.local_hospital_rounded,
                      color: Theme.of(context).primaryColor, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('Healix',
                    style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Secure access to campus healthcare',
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 24),
                _buildRoleTile(
                    title: 'Student (Patient)',
                    subtitle: 'Access medical services, book appointments',
                    icon: Icons.person_outline),
                _buildRoleTile(
                    title: 'Doctor',
                    subtitle: 'Manage appointments, create prescriptions',
                    icon: Icons.medical_services_outlined),
                _buildRoleTile(
                    title: 'Caretaker',
                    subtitle: 'Hostel alerts and emergency calls',
                    icon: Icons.admin_panel_settings_outlined),
                _buildRoleTile(
                    title: 'Staff',
                    subtitle: 'Pharmacy, Lab, or Administrative access',
                    icon: Icons.badge_outlined),
                const SizedBox(height: 24),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                      labelText: idFieldLabel,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white))
                        : const Text('Sign In', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("OR", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    onPressed: _authenticateWithBiometrics,
                    label: const Text('Biometric Login'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SignupPage()));
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTile(
      {required String title,
        required String subtitle,
        required IconData icon}) {
    bool isSelected = selectedRole == title;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = title),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black87),
                  ),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            Radio<String>(
              value: title,
              groupValue: selectedRole,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
          ],
        ),
      ),
    );
  }
}

