import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// A placeholder data model for the doctor's profile.
class DoctorProfile {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final String imageUrl;

  DoctorProfile({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.imageUrl,
  });
}

// The screen for the doctor's profile, now with image picking functionality.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- DUMMY DATA (This would come from your backend) ---
  final DoctorProfile _doctorProfile = DoctorProfile(
    id: '23',
    name: 'Dr. Sarah Wilson',
    specialization: 'General Medicine',
    experience: '8 years',
    imageUrl: 'https://placehold.co/120x120/E0F2F1/00796B?text=SW',
  );

  // This will hold the image file picked from the device's gallery.
  File? _imageFile;

  // This function handles the logic for picking an image.
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle any potential errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 24),
              _buildProfileInfoCard(),
              const SizedBox(height: 32),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for the profile picture, now updated to show the selected image.
  Widget _buildProfilePicture() {
    // Determine which image to show: the newly picked one or the original one.
    final ImageProvider imageProvider = _imageFile != null
        ? FileImage(_imageFile!)
        : NetworkImage(_doctorProfile.imageUrl);

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: imageProvider,
          backgroundColor: Colors.grey[200],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Theme.of(context).primaryColor,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _pickImage, // This now triggers the image picker.
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget for displaying the doctor's information (unchanged).
  Widget _buildProfileInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.badge_outlined,
              label: 'Doctor ID',
              value: _doctorProfile.id,
            ),
            const Divider(indent: 16, endIndent: 16),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Name',
              value: _doctorProfile.name,
            ),
            const Divider(indent: 16, endIndent: 16),
            _buildInfoRow(
              icon: Icons.medical_services_outlined,
              label: 'Specialization',
              value: _doctorProfile.specialization,
            ),
            const Divider(indent: 16, endIndent: 16),
            _buildInfoRow(
              icon: Icons.work_history_outlined,
              label: 'Experience',
              value: _doctorProfile.experience,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create a consistent row (unchanged).
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Widget for the logout button (unchanged).
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        onPressed: () {
          // TODO: Implement logout functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

