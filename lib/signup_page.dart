// import 'package:flutter/material.dart';
//
// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});
//
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _selectedRole = 'Student';
//   final _nameController = TextEditingController();
//   final _idController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;
//
//   Future<void> _handleSignup() async {
//     // Validate the form fields
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
//
//       // --- BACKEND INTEGRATION POINT ---
//       // Here, you would make an API call to your Django backend's registration endpoint.
//       // Send data like: _nameController.text, _idController.text, _passwordController.text, _selectedRole
//       print('Signing up user: ${_nameController.text} with ID: ${_idController.text} as a $_selectedRole');
//
//       // Simulate a network call
//       await Future.delayed(const Duration(seconds: 2));
//
//       setState(() => _isLoading = false);
//
//       // On successful registration, show a success message and navigate back to the login page.
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Registration successful! Please log in.'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.of(context).pop();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Account'),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('Welcome to Healix', style: Theme.of(context).textTheme.headlineSmall),
//                     const SizedBox(height: 8),
//                     const Text('Create an account to get started.', style: TextStyle(color: Colors.grey)),
//                     const SizedBox(height: 24),
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
//                       validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _idController,
//                       decoration: const InputDecoration(labelText: 'Student / Staff ID', border: OutlineInputBorder()),
//                       validator: (value) => value!.isEmpty ? 'Please enter your ID' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     DropdownButtonFormField<String>(
//                       value: _selectedRole,
//                       decoration: const InputDecoration(labelText: 'Select Your Role', border: OutlineInputBorder()),
//                       items: ['Student', 'Doctor', 'Staff'].map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (newValue) {
//                         setState(() {
//                           _selectedRole = newValue!;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
//                       validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _confirmPasswordController,
//                       obscureText: true,
//                       decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
//                       validator: (value) {
//                         if (value != _passwordController.text) {
//                           return 'Passwords do not match';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _handleSignup,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           backgroundColor: Theme.of(context).primaryColor,
//                           foregroundColor: Colors.white,
//                         ),
//                         child: _isLoading
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : const Text('Sign Up', style: TextStyle(fontSize: 16)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:healix/auth_service.dart'; // Import your authentication service
import 'package:healix/otp_page.dart'; // Import the OTP verification page

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'Student';
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController(); // Added for OTP
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Use the AuthService for backend communication
  final AuthService _authService = AuthService();
// In lib/signup_page.dart

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
print("signup happening");
    try {
      final result = await _authService.signup(
        _idController.text,
        _emailController.text,
        _passwordController.text,
        _selectedRole.toLowerCase(),
        _nameController.text,
      );
print(_idController.text);
      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Check your email for an OTP.'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => OtpVerificationPage(username: _idController.text),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup Failed: ${result['message'] ?? 'Unknown error'}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      // This will catch any network errors and show a helpful message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection Error: Could not reach the server. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // This ensures the spinner always stops, even if there's an error
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Welcome to Healix', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text('Create an account to get started.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(labelText: 'Student / Staff ID', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Please enter your ID' : null,
                    ),
                    const SizedBox(height: 16),
                    // Added Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter your email';
                        if (!value.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Select Your Role', border: OutlineInputBorder()),
                      items: ['Student', 'Doctor', 'Staff','Caretaker'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedRole = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                      validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign Up', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

