import 'package:flutter/material.dart';
import 'package:healix/auth_service.dart';
import 'package:healix/login_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String _errorMessage = '';
  File? _profileImage;

  // Read-only fields
  String _name = '';
  String _username = '';
  String _email = '';

  // Editable fields
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _hostelController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _waterIntakeController = TextEditingController();
  final TextEditingController _sleepHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _handleLogout() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _authService.getStudentProfile();

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      _name = data['name'] ?? '';
      _username = data['username'] ?? '';
      _email = data['email'] ?? '';
      _dobController.text = data['date_of_birth'] ?? '';
      _allergiesController.text = data['allergies'] ?? '';
      _hostelController.text = data['hostel_name']?.toString() ?? '';
      _bmiController.text = data['bmi']?.toString() ?? '';
      _waterIntakeController.text = data['water_intake']?.toString() ?? '';
      _sleepHoursController.text = data['sleep_hours']?.toString() ?? '';
    } else {
      if (result['logout'] == true) {
        _handleLogout();
        return;
      }
      _errorMessage = result['message'] ?? 'An unknown error occurred.';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.updateStudentProfile({
      'date_of_birth': _dobController.text,
      'allergies': _allergiesController.text,
      'hostel_name': _hostelController.text ,
      'bmi': double.tryParse(_bmiController.text) ?? 0,
      'water_intake': double.tryParse(_waterIntakeController.text) ?? 0,
      'sleep_hours': double.tryParse(_sleepHoursController.text) ?? 0,
    });
    print('====================');
    print('Sending student profile update...');
    print('Date of Birth: ${_dobController.text}');
    print('Allergies: ${_allergiesController.text}');
    print('Hostel: ${_hostelController.text}');
    print('BMI: ${_bmiController.text}');
    print('Water Intake: ${_waterIntakeController.text}');
    print('Sleep Hours: ${_sleepHoursController.text}');
    // print('Final Data Sent: $updatedData');
    print('====================');
    // final result = await _authService.updateStudentProfile(updatedData);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else if (result['logout'] == true) {
      _handleLogout();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${result['message']}')),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
          : _buildProfileForm(),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/download.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),

            // Read-only info
            Text('Name: $_name', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Username: $_username'),
            Text('Email: $_email'),
            const SizedBox(height: 20),

            // Editable fields
            TextFormField(
              controller: _dobController,
              decoration: const InputDecoration(labelText: 'Date of Birth'),
            ),
            TextFormField(
              controller: _allergiesController,
              decoration: const InputDecoration(labelText: 'Allergies'),
            ),
            TextFormField(
              controller: _hostelController,
              decoration: const InputDecoration(labelText: 'Hostel Name'),
              keyboardType: TextInputType.text,
            ),
            TextFormField(
              controller: _bmiController,
              decoration: const InputDecoration(labelText: 'BMI'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _waterIntakeController,
              decoration: const InputDecoration(labelText: 'Water Intake (L)'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _sleepHoursController,
              decoration: const InputDecoration(labelText: 'Sleep Hours'),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfileData,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}



//
// import 'package:flutter/material.dart';
// import 'package:healix/auth_service.dart';
// import 'package:healix/login_page.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
//
// class StudentProfileScreen extends StatefulWidget {
//   const StudentProfileScreen({super.key});
//
//   @override
//   State<StudentProfileScreen> createState() => _StudentProfileScreenState();
// }
//
// class _StudentProfileScreenState extends State<StudentProfileScreen> {
//   final AuthService _authService = AuthService();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = true;
//   String _errorMessage = '';
//   File? _profileImage;
//
//   // Read-only fields
//   String _name = '';
//   String _username = '';
//   String _email = '';
//
//   // Editable fields
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _allergiesController = TextEditingController();
//   final TextEditingController _hostelController = TextEditingController();
//   final TextEditingController _bmiController = TextEditingController();
//   final TextEditingController _waterIntakeController = TextEditingController();
//   final TextEditingController _sleepHoursController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileData();
//   }
//
//   void _handleLogout() {
//     if (mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//             (Route<dynamic> route) => false,
//       );
//     }
//   }
//
//   Future<void> _fetchProfileData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//
//     final result = await _authService.getStudentProfile();
//
//     if (!mounted) return;
//
//     if (result['success']) {
//       final data = result['data'];
//       _name = data['name'] ?? '';
//       _username = data['username'] ?? '';
//       _email = data['email'] ?? '';
//       _dobController.text = data['date_of_birth'] ?? '';
//       _allergiesController.text = data['allergies'] ?? '';
//       _hostelController.text = data['hostel_name'] ;
//       _bmiController.text = data['bmi']?.toString() ?? '';
//       _waterIntakeController.text = data['water_intake']?.toString() ?? '';
//       _sleepHoursController.text = data['sleep_hours']?.toString() ?? '';
//     } else {
//       if (result['logout'] == true) {
//         _handleLogout();
//         return;
//       }
//       _errorMessage = result['message'] ?? 'An unknown error occurred.';
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _saveProfileData() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     // --- THIS IS THE FIX ---
//     // We just send the text. If it's empty, it sends an empty string,
//     // which your backend serializer correctly handles as 'None'.
//     final result = await _authService.updateStudentProfile({
//       'date_of_birth': _dobController.text,
//       'allergies': _allergiesController.text,
//       'hostel_name' : _hostelController.text , // <-- BUG WAS HERE
//       'bmi': double.tryParse(_bmiController.text) ?? 0,
//       'water_intake': double.tryParse(_waterIntakeController.text) ?? 0,
//       'sleep_hours': double.tryParse(_sleepHoursController.text) ?? 0,
//     });
//     // --- END FIX ---
//
//     if (result['success']) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully!')),
//       );
//     } else if (result['logout'] == true) {
//       _handleLogout();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('Failed to update profile: ${result['message']}')),
//       );
//     }
//
//     setState(() => _isLoading = false);
//   }
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _profileImage = File(pickedFile.path));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Profile')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage.isNotEmpty
//           ? Center(
//           child: Text(_errorMessage,
//               style: const TextStyle(color: Colors.red)))
//           : _buildProfileForm(),
//     );
//   }
//
//   Widget _buildProfileForm() {
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: _pickImage,
//               child: CircleAvatar(
//                 radius: 60,
//                 backgroundImage: _profileImage != null
//                     ? FileImage(_profileImage!)
//                     : const AssetImage('assets/download.png') as ImageProvider,
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Read-only info
//             Text('Name: $_name',
//                 style: const TextStyle(fontWeight: FontWeight.bold)),
//             Text('Username: $_username'),
//             Text('Email: $_email'),
//             const SizedBox(height: 20),
//
//             // Editable fields
//             TextFormField(
//               controller: _dobController,
//               decoration: const InputDecoration(labelText: 'Date of Birth'),
//             ),
//             TextFormField(
//               controller: _allergiesController,
//               decoration: const InputDecoration(labelText: 'Allergies'),
//             ),
//             TextFormField(
//               controller: _hostelController,
//               decoration: const InputDecoration(labelText: 'Hostel Name'),
//               keyboardType: TextInputType.text,
//             ),
//             TextFormField(
//               controller: _bmiController,
//               decoration: const InputDecoration(labelText: 'BMI'),
//               keyboardType: TextInputType.number,
//             ),
//             TextFormField(
//               controller: _waterIntakeController,
//               decoration: const InputDecoration(labelText: 'Water Intake (L)'),
//               keyboardType: TextInputType.number,
//             ),
//             TextFormField(
//               controller: _sleepHoursController,
//               decoration: const InputDecoration(labelText: 'Sleep Hours'),
//               keyboardType: TextInputType.number,
//             ),
//
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _saveProfileData,
//               child: const Text('Save Changes'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
