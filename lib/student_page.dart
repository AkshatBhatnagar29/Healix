import 'package:flutter/material.dart';
import 'package:healix/auth_service.dart';
import 'package:healix/student_profile_screen.dart'; // Make sure this file exists
import 'package:healix/login_page.dart';
import 'dart:async';

// Imports for WebRTC
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:healix/webrtc_circuit.dart'; // Your WebRTC service
import 'package:healix/call_screen.dart'; // The screen to show the call

class StudentHomepage extends StatefulWidget {
  final String studentId;
  const StudentHomepage({super.key, required this.studentId});

  @override
  State<StudentHomepage> createState() => _StudentHomepageState();
}

class _StudentHomepageState extends State<StudentHomepage> {
  final AuthService _authService = AuthService();
  Future<List<dynamic>>? _activeAlertFuture;
  int _selectedIndex = 0;

  late final WebRTCService _webRTCService;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  Map<String, dynamic>? _profileData;
  String? _caretakerId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _webRTCService.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    await _fetchProfile(); // Fetch profile data

    // Connect to WebRTC Signaling Server (Port 8765)
    _webRTCService = WebRTCService(
      currentUserId: widget.studentId,
      localRenderer: _localRenderer,
      remoteRenderer: _remoteRenderer,
    );
    await _webRTCService.initialize();

    // Set callback for incoming calls (e.g., caretaker calls back)
    _webRTCService.onOfferReceived = (offerData) {
      _showIncomingCallDialog(offerData);
    };

    _loadActiveAlert(); // Load initial alert status
    setState(() => _isLoading = false);
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await _authService.getStudentProfile();
      if (!mounted) return;
      if (result['success']) {
        setState(() {
          _profileData = result['data'];
          _caretakerId = _profileData?['caretaker_id'];
          print("Student Profile Loaded. Caretaker ID: $_caretakerId");
        });
      } else {
        _showError(result['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _handleLogout() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  void _loadActiveAlert() {
    setState(() {
      _activeAlertFuture = _authService.getActiveAlerts();
    });
  }

  void _showIncomingCallDialog(Map<String, dynamic> offerData) {
    final String fromId = offerData['from'];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Incoming Call"),
        content: Text("Caretaker ($fromId) is calling."),
        actions: [
          TextButton(
              child: const Text("REJECT"),
              onPressed: () => Navigator.of(context).pop()),
          TextButton(
            child: const Text("ACCEPT"),
            onPressed: () async {
              Navigator.of(context).pop();
              await _webRTCService.acceptCall(offerData);
              _goToCallScreen();
            },
          ),
        ],
      ),
    );
  }

  void _triggerSOSAndCall() async {
    if (_profileData == null) {
      _showError("Profile data not loaded. Cannot trigger SOS.");
      return;
    }

    // 1. Send the Django alert (for doctors/caretakers)
    await _authService.triggerSOS(
      location: _profileData!['hostel_name'] ?? "Unknown Hostel",
      profileData: _profileData!,
    );
    _loadActiveAlert(); // Refresh UI to show "Alert Active"

    // 2. Check if we can make the video call
    if (_caretakerId == null || _caretakerId!.isEmpty) {
      _showError("You have no caretaker assigned. Alerting doctors only.");
      return;
    }

    // 3. Make the WebRTC call
    print("[DEBUG] Making call to Caretaker ID: $_caretakerId");
    _webRTCService.makeCall(_caretakerId!);

    // 4. Go to the call screen
    _goToCallScreen();
  }

  void _goToCallScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentCallScreen(
          webRTCService: _webRTCService,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _resolveSOS(int alertId) async {
    try {
      final success = await _authService.resolveAlert(alertId);
      if (!mounted) return;
      if (success) {
        _loadActiveAlert();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Alert marked as resolved."),
              backgroundColor: Colors.blue),
        );
      } else {
        final token = await _authService.getAccessToken();
        if (token == null) {
          _handleLogout();
        } else {
          _showError("Failed to resolve alert.");
        }
      }
    } catch (e) {
      _showError("Error resolving alert: $e");
    }
  }

  void _onItemTapped(int index) async {
    if (index == 4) { // Profile tab
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudentProfileScreen()),
      );
      // When we come back, refresh the profile data
      setState(() => _isLoading = true);
      await _fetchProfile();
      setState(() => _isLoading = false);
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveAlert,
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
            _buildSOSSection(),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.medical_services_outlined,
              title: 'Upcoming Appointment',
              tag: 'Today',
              child: const ListTile(title: Text("Dr. Patel"), subtitle: Text("10:30 AM - Dental Checkup")),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.science_outlined,
              title: 'Lab Report Status',
              tag: 'In Progress',
              child: const ListTile(title: Text("Blood Test"), subtitle: Text("Results expected by tomorrow")),
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

  Widget _buildSOSSection() {
    return FutureBuilder<List<dynamic>>(
      future: _activeAlertFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
          return const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final alert = snapshot.data![0];
          return _buildSOSStatusCard(alert);
        }
        return _isLoading
            ? const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()))
            : _buildSOSButton();
      },
    );
  }

  Widget _buildSOSStatusCard(Map<String, dynamic> alert) {
    bool isAcknowledged = alert['status'] == 'Acknowledged';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isAcknowledged ? Colors.orange[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                "SOS ALERT ${alert['status'].toUpperCase()}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAcknowledged ? Colors.orange[800] : Colors.red[800],
                    fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              isAcknowledged
                  ? "Help is on the way. Your alert was acknowledged by ${alert['acknowledged_by_name']}."
                  : "Your alert has been sent. Medical staff have been notified.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () => _resolveSOS(alert['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              label: const Text("Mark as Resolved"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton() {
    return Column(
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: ElevatedButton(
            onPressed: !_isLoading ? _triggerSOSAndCall : null,
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: !_isLoading ? Colors.red.shade600 : Colors.grey,
                foregroundColor: Colors.white,
                elevation: 4),
            child: const Text('SOS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Emergency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Welcome, ${(_profileData?['name'] ?? 'Student').split(' ')[0]}!',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text('Student ID: ${widget.studentId}',
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String tag,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tag,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          child,
        ],
      ),
    );
  }
}
