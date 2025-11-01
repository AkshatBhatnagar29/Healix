import 'package:flutter/material.dart';
import 'package:healix/appointments_list_screen.dart';
import 'package:healix/patient_records_screen.dart'; // Import the new screen
import 'package:healix/prescriptions_screen.dart';
import 'package:healix/profile_screen.dart'; // <-- This file should contain your DoctorProfileScreen class

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({super.key});

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  // This state helps to highlight the currently selected item in the drawer
  int _selectedIndex = 0;

  void _onSelectItem(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // Close the drawer

    // Use a switch statement for cleaner navigation logic
    switch (index) {
      case 0: // Dashboard
      // Do nothing, we are already on the dashboard
        break;
      case 1: // Appointments
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const AppointmentsListScreen(title: 'All Appointments'),
        ));
        break;
      case 2: // Patient Records
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const PatientRecordsScreen(),
        ));
        break;
      case 3: // Prescriptions
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const CreatePrescriptionScreen(),
        ));
        break;
      case 5: // Profile
      // --- MODIFIED ---
        Navigator.of(context).push(MaterialPageRoute(
          // 1. Use the correct class name
          // 2. Remove 'const'
          builder: (context) => DoctorProfileScreen(),
        ));
        // --- END MODIFICATION ---
        break;
    // You can add cases for other items like Lab Requests here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            text: 'Dashboard',
            onTap: () => _onSelectItem(0),
            isSelected: _selectedIndex == 0,
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today_outlined,
            text: 'Appointments',
            onTap: () => _onSelectItem(1),
            isSelected: _selectedIndex == 1,
          ),
          _buildDrawerItem(
            icon: Icons.folder_shared_outlined,
            text: 'Patient Records',
            onTap: () => _onSelectItem(2),
            isSelected: _selectedIndex == 2,
          ),
          _buildDrawerItem(
            icon: Icons.description_outlined,
            text: 'Prescriptions',
            onTap: () => _onSelectItem(3),
            isSelected: _selectedIndex == 3,
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.science_outlined,
            text: 'Lab Requests',
            onTap: () {
              // TODO: Navigate to Lab Requests screen
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            text: 'Profile',
            onTap: () => _onSelectItem(5),
            isSelected: _selectedIndex == 5,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_hospital_rounded, color: Theme.of(context).primaryColor, size: 40),
          const SizedBox(height: 8),
          const Text('Healix', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Doctor Portal', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final color = isSelected ? Theme.of(context).primaryColor : Colors.black87;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: onTap,
      tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}