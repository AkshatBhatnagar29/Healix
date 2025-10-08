import 'package:flutter/material.dart';
// Assuming a profile.dart file exists for the student profile
// import 'profile.dart';

// Placeholder for Student Profile Screen
class StudentProfileScreen extends StatelessWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Profile: $studentId')));
  }
}

class StudentHomepage extends StatefulWidget {
  final String studentId;
  const StudentHomepage({super.key, required this.studentId});

  @override
  State<StudentHomepage> createState() => _StudentHomepageState();
}

class _StudentHomepageState extends State<StudentHomepage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 4) { // Profile tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StudentProfileScreen(studentId: widget.studentId)),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Healix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Student Portal', style: TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildSOSButton(),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.medical_services_outlined,
              title: 'Upcoming Appointment',
              tag: 'Today',
              child: const ListTile(
                title: Text('Dr. Sarah Wilson', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('General Medicine'),
                trailing: Text('2:30 PM'),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.science_outlined,
              title: 'Lab Report Status',
              tag: 'In Progress',
              child: const ListTile(
                title: Text('Blood Test - Complete Panel', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Expected: Tomorrow'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), label: 'Prescriptions'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_copy_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome back!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Student ID: ${widget.studentId}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('SOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Emergency', style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String tag,
    required Widget child,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tag, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}
