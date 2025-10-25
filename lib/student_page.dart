//
// import 'package:flutter/material.dart';
// import 'package:healix/auth_service.dart';
// import 'package:healix/student_profile_screen.dart';
// import 'package:healix/login_page.dart';
// import 'dart:async'; // Import for TimeoutException
//
// class StudentHomepage extends StatefulWidget {
//   final String studentId;
//   const StudentHomepage({super.key, required this.studentId});
//
//   @override
//   State<StudentHomepage> createState() => _StudentHomepageState();
// }
//
// class _StudentHomepageState extends State<StudentHomepage> {
//   final AuthService _authService = AuthService();
//   Future<List<dynamic>>? _activeAlertFuture;
//   int _selectedIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadActiveAlert();
//   }
//
//   // --- DATA & AUTHENTICATION HANDLING ---
//
//   void _handleLogout() {
//     if (mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => LoginPage()),
//             (Route<dynamic> route) => false,
//       );
//     }
//   }
//
//   void _loadActiveAlert() {
//     setState(() {
//       _activeAlertFuture = _authService.getActiveAlerts();
//     });
//   }
//
//   // --- UPDATED with Timeout Handling ---
//   void _triggerSOS() async {
//     print("[DEBUG] SOS button tapped. Calling authService.triggerSOS...");
//
//     try {
//       final result = await _authService.triggerSOS("Student Location (via App)");
//
//       if (!mounted) return;
//
//       if (result['success']) {
//         _loadActiveAlert();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("SOS Alert sent successfully!"), backgroundColor: Colors.green),
//         );
//       } else {
//         if (result['logout'] == true) {
//           _handleLogout();
//           return;
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to send SOS: ${result['message']}"), backgroundColor: Colors.red),
//         );
//       }
//     } on TimeoutException catch (_) {
//       // This will catch the timeout error specifically and give a helpful message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Connection timed out. The server might be waking up. Please try again in 30 seconds."),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       // Catch any other unexpected errors
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("An unexpected error occurred: $e"), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _resolveSOS(int alertId) async {
//     // ... (This function should also have similar try-catch error handling)
//     final success = await _authService.resolveAlert(alertId);
//     if (mounted) {
//       if (success) {
//         _loadActiveAlert(); // Refresh the state
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Alert has been marked as resolved."), backgroundColor: Colors.blue),
//         );
//       } else {
//         if (await _authService.getAccessToken() == null) {
//           _handleLogout();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Failed to resolve alert."), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }
//
//   void _onItemTapped(int index) {
//     if (index == 4) { // Profile tab
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const StudentProfileScreen()),
//       );
//
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }
//
//   // --- UI and Widget Builder Methods are unchanged ---
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Healix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             Text('Student Portal', style: TextStyle(color: Colors.black54, fontSize: 14)),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadActiveAlert,
//           ),
//           IconButton(
//             icon: const Icon(Icons.notifications_none, color: Colors.black87),
//             onPressed: () {},
//           ),
//         ],
//         backgroundColor: Colors.white,
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildWelcomeCard(),
//             const SizedBox(height: 20),
//             _buildSOSSection(),
//             const SizedBox(height: 20),
//             _buildInfoCard(
//               icon: Icons.medical_services_outlined,
//               title: 'Upcoming Appointment',
//               tag: 'Today',
//               child: const ListTile(
//                 title: Text('Dr. Sarah Wilson', style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text('General Medicine'),
//                 trailing: Text('2:30 PM'),
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildInfoCard(
//               icon: Icons.science_outlined,
//               title: 'Lab Report Status',
//               tag: 'In Progress',
//               child: const ListTile(
//                 title: Text('Blood Test - Complete Panel', style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text('Expected: Tomorrow'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Appointments'),
//           BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), label: 'Prescriptions'),
//           BottomNavigationBarItem(icon: Icon(Icons.folder_copy_outlined), label: 'Reports'),
//           BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Theme.of(context).primaryColor,
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
//
//   // --- WIDGET BUILDER METHODS ---
//
//   Widget _buildSOSSection() {
//     return FutureBuilder<List<dynamic>>(
//       future: _activeAlertFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()));
//         }
//         if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
//           return _buildSOSButton();
//         }
//
//         final alert = snapshot.data![0];
//         return _buildSOSStatusCard(alert);
//       },
//     );
//   }
//
//   Widget _buildSOSStatusCard(Map<String, dynamic> alert) {
//     bool isAcknowledged = alert['status'] == 'Acknowledged';
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: isAcknowledged ? Colors.orange[50] : Colors.red[50],
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//                 "SOS ALERT ${alert['status'].toUpperCase()}",
//                 style: TextStyle(fontWeight: FontWeight.bold, color: isAcknowledged ? Colors.orange[800] : Colors.red[800], fontSize: 16)
//             ),
//             const SizedBox(height: 8),
//             Text(
//               isAcknowledged
//                   ? "Help is on the way. Your alert was acknowledged by ${alert['acknowledged_by_name']}."
//                   : "Your alert has been sent. Medical staff have been notified.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey[800]),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.check_circle_outline),
//               onPressed: () => _resolveSOS(alert['id']),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               label: const Text("Mark as Resolved"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSOSButton() {
//     return Column(
//       children: [
//         SizedBox(
//           width: 90,
//           height: 90,
//           child: ElevatedButton(
//             onPressed: _triggerSOS,
//             style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//                 backgroundColor: Colors.red.shade600,
//                 foregroundColor: Colors.white,
//                 elevation: 4
//             ),
//             child: const Text('SOS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           ),
//         ),
//         const SizedBox(height: 8),
//         const Text('Emergency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
//       ],
//     );
//   }
//
//   Widget _buildWelcomeCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)) ]
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Welcome back!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
//           const SizedBox(height: 8),
//           Text('Student ID: ${widget.studentId}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoCard({ required IconData icon, required String title, required String tag, required Widget child, }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Row(
//               children: [
//                 Icon(icon, color: Theme.of(context).primaryColor),
//                 const SizedBox(width: 12),
//                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(tag, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1, indent: 16, endIndent: 16),
//           child,
//         ],
//       ),
//     );
//   }
// }
//
//
//



import 'package:flutter/material.dart';
import 'package:healix/auth_service.dart';
import 'package:healix/student_profile_screen.dart'; // Ensure this is the correct import name
import 'package:healix/login_page.dart';
import 'package:healix/call_screen.dart'; // Import the call screen
import 'package:healix/webrtc_circuit.dart'; // Import the WebRTC service
import 'package:flutter_webrtc/flutter_webrtc.dart'; // Import WebRTC package
import 'dart:async'; // Import for TimeoutException

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

  // --- NEW: WebRTC State Variables ---
  late final WebRTCService _webRTCService;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isWebRTCInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadActiveAlert();
    _initializeWebRTC(); // Initialize WebRTC
  }

  // --- NEW: Dispose WebRTC resources ---
  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _webRTCService.dispose();
    super.dispose();
  }

  // --- DATA & AUTHENTICATION HANDLING ---

  void _handleLogout() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  void _loadActiveAlert() {
    setState(() {
      _activeAlertFuture = _authService.getActiveAlerts();
    });
  }

  // --- NEW: WebRTC Initialization ---
  Future<void> _initializeWebRTC() async {
    // Initialize the WebRTC service with the student's own ID
    _webRTCService = WebRTCService(
      currentUserId: widget.studentId, // Use studentId as the identifier
      localRenderer: _localRenderer,
      remoteRenderer: _remoteRenderer,
    );
    try {
      await _webRTCService.initialize();
      setState(() {
        _isWebRTCInitialized = true;
      });
      print("[DEBUG] WebRTC Initialized Successfully.");
    } catch (e) {
      print("[ERROR] Failed to initialize WebRTC: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize calling service: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- UPDATED: Now triggers SOS and initiates call ---
  void _triggerSOSAndCall() async {
    if (!_isWebRTCInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calling service not ready. Please wait.'), backgroundColor: Colors.orange),
      );
      return;
    }
    print("[DEBUG] SOS button tapped. Calling authService.triggerSOS...");

    try {
      // Step 1: Trigger the SOS alert via the standard API
      final result = await _authService.triggerSOS("Student Location (via App)");

      if (!mounted) return;

      if (result['success']) {
        _loadActiveAlert(); // Refresh the SOS status on the UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SOS Alert sent successfully! Initiating call..."), backgroundColor: Colors.green),
        );

        // Step 2: Extract Caretaker ID (Ensure your backend serializer provides this!)
        final sosData = result['data'];
        final caretakerId = sosData['caretaker_id']?.toString(); // Get ID as string

        if (caretakerId != null && caretakerId.isNotEmpty) {
          print("[DEBUG] Caretaker ID found: $caretakerId. Making call...");

          // Step 3: Initiate the WebRTC call
          await _webRTCService.makeCall(caretakerId);

          // Step 4: Navigate to the Call Screen
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CallScreen(
              targetId: caretakerId,
              localRenderer: _localRenderer,
              remoteRenderer: _remoteRenderer,
              onHangUp: () {
                _webRTCService.hangUp();
                Navigator.of(context).pop(); // Close the call screen
              },
            ),
          ));

        } else {
          print("[WARN] SOS sent, but no caretaker_id found in response: ${sosData}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("SOS Alert sent, but could not initiate call (no caretaker assigned?)."), backgroundColor: Colors.orange),
          );
        }

      } else { // Handle SOS trigger failure
        if (result['logout'] == true) {
          _handleLogout();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send SOS: ${result['message']}"), backgroundColor: Colors.red),
        );
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection timed out. Server might be waking up. Please try again."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("[ERROR] Unexpected error during SOS/Call: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An unexpected error occurred: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _resolveSOS(int alertId) async {
    // ... (This function remains largely the same, but add try-catch)
    try {
      final success = await _authService.resolveAlert(alertId);
      if (mounted) {
        if (success) {
          _loadActiveAlert();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Alert marked as resolved."), backgroundColor: Colors.blue),
          );
        } else {
          if (await _authService.getAccessToken() == null) {
            _handleLogout();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to resolve alert."), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error resolving alert: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 4) { // Profile tab
      Navigator.push(
        context,
        // Ensure StudentProfileScreen takes studentId if needed
        MaterialPageRoute(builder: (context) => StudentProfileScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // --- UI BUILD METHOD ---
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
            _buildSOSSection(), // This now handles WebRTC logic via its button
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.medical_services_outlined,
              title: 'Upcoming Appointment',
              tag: 'Today',
              child: const ListTile( /* ... appointment details ... */ ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.science_outlined,
              title: 'Lab Report Status',
              tag: 'In Progress',
              child: const ListTile( /* ... lab report details ... */ ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // ... your BottomNavigationBarItems ...
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

  // --- WIDGET BUILDER METHODS ---

  Widget _buildSOSSection() {
    return FutureBuilder<List<dynamic>>(
      future: _activeAlertFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()));
        }
        // If there's an active alert, show the status card
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final alert = snapshot.data![0];
          return _buildSOSStatusCard(alert);
        }
        // Otherwise, show the SOS button (ensure WebRTC is ready)
        return _buildSOSButton();
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
                style: TextStyle(fontWeight: FontWeight.bold, color: isAcknowledged ? Colors.orange[800] : Colors.red[800], fontSize: 16)
            ),
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
            // **CRITICAL CHANGE**: The button now calls _triggerSOSAndCall
            onPressed: _isWebRTCInitialized ? _triggerSOSAndCall : null, // Disable if WebRTC not ready
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: _isWebRTCInitialized ? Colors.red.shade600 : Colors.grey, // Indicate readiness
                foregroundColor: Colors.white,
                elevation: 4
            ),
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
          boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)) ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome back!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Student ID: ${widget.studentId}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
  Widget _buildInfoCard({ required IconData icon, required String title, required String tag, required Widget child, }) {
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
          const Divider(height: 1, indent: 16, endIndent: 16),
          child,
        ],
      ),
    );
  }
}