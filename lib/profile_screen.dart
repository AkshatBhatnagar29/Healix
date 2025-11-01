import 'package:flutter/material.dart';
import 'package:healix/auth_service.dart';
import 'package:healix/login_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
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
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

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

    // *** Changed to getDoctorProfile() ***
    final result = await _authService.getDoctorProfile();

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      _name = data['full_name'] ?? ''; // Assuming 'full_name' for name
      _username = data['username'] ?? '';
      _email = data['email'] ?? '';
      _specializationController.text = data['specialization'] ?? '';
      _experienceController.text = data['experience']?.toString() ?? '';
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

    // *** Changed to updateDoctorProfile() ***
    final result = await _authService.updateDoctorProfile({
      'specialization': _specializationController.text,
      'experience': _experienceController.text,
    });

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
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
      ),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Profile Picture Section ---
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage('assets/download.png') as ImageProvider,
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 30, color: Colors.teal.shade800)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Read-Only Info Card ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('General Information ℹ️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                    const Divider(),
                    _buildInfoRow('Name', _name),
                    _buildInfoRow('Username', _username),
                    _buildInfoRow('Email', _email),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Editable Fields Section ---
            Text(
              'Update Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _specializationController,
              decoration: const InputDecoration(
                labelText: 'Specialization',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter your specialization' : null,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _experienceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Experience (in years)', // *** Corrected Label ***
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter your experience' : null,
            ),

            const SizedBox(height: 30),

            // --- Save Button ---
            ElevatedButton.icon(
              onPressed: _saveProfileData,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}