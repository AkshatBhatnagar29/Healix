
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:healix/auth_service.dart';
import 'package:healix/webrtc_circuit.dart'; // Ensure this path is correct
// Import the profile screen you will create
// import 'caretaker_profile_screen.dart';
import 'dart:async';

class CaretakerDashboardScreen extends StatefulWidget {
  final String caretakerId; // This is the Caretaker's username (from JWT)
  const CaretakerDashboardScreen({super.key, required this.caretakerId});

  @override
  State<CaretakerDashboardScreen> createState() =>
      _CaretakerDashboardScreenState();
}

class _CaretakerDashboardScreenState extends State<CaretakerDashboardScreen> {
  // --- Profile State ---
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _profileData;
  bool _isProfileLoading = true;

  // --- Call State ---
  late final WebRTCService _webRTCService;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String _callState = "idle"; // idle, incoming, connected
  String _incomingCallerId = "";
  Map<String, dynamic>? _latestOfferData; // This will store the offer data

  // --- Alert State ---
  WebSocketChannel? _alertChannel; // This is for Django (Port 8000)
  String _lastAlertLocation = "No active alerts";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. Init video renderers
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // 2. Fetch profile
    await _fetchProfile();

    // --- THIS IS THE FIX ---
    // 3. Get the auth token FIRST
    final token = await _authService.getAccessToken();
    if (token == null) {
      print("Caretaker WS: No token found, cannot initialize.");
      // You could pop the route or show a persistent error here
      return;
    }
    // --- END FIX ---

    // 4. Connect to WebRTC Signaling Server (Port 8000 /ws/call/)
    _webRTCService = WebRTCService(
      currentUserId: widget.caretakerId,
      localRenderer: _localRenderer,
      remoteRenderer: _remoteRenderer,
      token: token, // <-- Pass the valid token
    );
    await _webRTCService.initialize();

    // 5. Set callback to LISTEN for "offer"
    // _webRTCService.onOfferReceived = (offerData) {
    //   final String fromId = offerData['from'];
    //   setState(() {
    //     _callState = "incoming";
    //     _incomingCallerId = fromId;
    //     _latestOfferData = offerData; // <-- Correctly save the incoming data
    //   });
    // };
    _webRTCService.onOfferReceived = (offerData) {
      final String fromId = offerData['from'];
      print("Caretaker: onOfferReceived callback fired from $fromId, data keys: ${offerData.keys}");
      setState(() {
        _callState = "incoming";
        _incomingCallerId = fromId;
        _latestOfferData = offerData;
      });
    };


    // 6. Connect to Django Alert Server (Port 8000 /ws/caretaker_alerts/)
    await _connectToAlerts(token); // <-- Pass the valid token
  }

  Future<void> _fetchProfile() async {
    setState(() => _isProfileLoading = true);
    // Use the new getCaretakerProfile function
    final result = await _authService.getCaretakerProfile();
    if (result['success']) {
      setState(() {
        _profileData = result['data'];
        _isProfileLoading = false;
      });
    } else {
      setState(() {
        _isProfileLoading = false;
        _profileData = {
          'full_name': 'Error',
          'hostel_assigned': 'Could not load profile'
        };
      });
    }
  }
  //===============================================================================
  // --- THIS IS THE FIX ---
  // This function now receives the token as a parameter
  StreamSubscription? _alertSub;

  Future<void> _connectToAlerts(String token) async {
    final wsUrl =
        'wss://healix-backend-1.onrender.com/ws/caretaker_alerts/?token=$token';
    try {
      _alertChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _alertSub = _alertChannel!.stream.listen((message) {
        final data = jsonDecode(message);

        if (data['type'] == 'sos_notification') {
          final msg = data['message'];
          final location = msg['location_info'] ?? 'Unknown location';

          // 🔒 Safe UI update — only if still mounted
          if (!mounted) return;
          setState(() {
            _lastAlertLocation = location;
          });

          // 🔒 Use context only if still active
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '🚨 SOS from ${msg['student_name']} at $location',
                ),
                duration: const Duration(seconds: 10),
              ),
            );
          }
        }
      }, onDone: () {
        print('Caretaker Alert WebSocket closed');
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) _connectToAlerts(token); // try reconnect
        });
      }
          , onError: (error) {
        print('Caretaker Alert WebSocket Error: $error');
      });
    } catch (e) {
      print('Caretaker Alert WebSocket connection error: $e');
    }
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    _alertChannel?.sink.close();
    super.dispose();
  }


  // In _connectToAlerts(String token) inside CaretakerDashboardScreen
  // Future<void> _connectToAlerts(String token) async {
  //   final uri = Uri(
  //     scheme: 'wss',
  //     host: 'healix-backend-1.onrender.com',
  //     path: '/ws/caretaker_alerts/',
  //     queryParameters: {'token': token},
  //   );
  //
  //   try {
  //     _alertChannel = IOWebSocketChannel.connect(
  //       uri,
  //       headers: {'Origin': 'https://healix-backend-1.onrender.com'},
  //     );
  //
  //     _alertChannel!.stream.listen((message) {
  //       final data = jsonDecode(message);
  //       if (data['type'] == 'sos_notification') {
  //         final msg = data['message'];
  //         setState(() {
  //           _lastAlertLocation = msg['location_info'] ?? 'Unknown location';
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text('SOS from ${msg['student_name']} at ${msg['location_info']}'),
  //           duration: const Duration(seconds: 10),
  //         ));
  //       }
  //     }, onDone: () {
  //       print('Caretaker Alert WebSocket closed');
  //     }, onError: (error) {
  //       print('Caretaker Alert WebSocket Error: $error');
  //     });
  //
  //     print("Alerts: Connecting to $uri");
  //   } catch (e) {
  //     print('Caretaker Alert WebSocket connection error: $e');
  //   }
  // }

  // @override
  // void dispose() {
  //   _alertSub?.cancel();
  //   _alertChannel?.sink.close();
  //   super.dispose();
  // }
  // void _acceptCall() async {
  //   final offer = _latestOfferData;
  //   if (offer != null) {
  //     await _webRTCService.acceptCall(offer);
  //     setState(() {
  //       _callState = "connected";
  //     });
  //   } else {
  //     print("⚠️ Error: No offer data to accept!");
  //   }
  // }

  void _acceptCall() async {
    final offer = _latestOfferData;
    if (offer != null) {
      print("Caretaker: Accepting call from ${offer['from']}");
      try {
        await _webRTCService.acceptCall(offer);
        setState(() {
          _callState = "connected";
        });
      } catch (e) {
        print("Caretaker: Error while accepting call: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to accept call: $e")),
        );
      }
    } else {
      print("⚠️ Error: No offer data to accept!");
    }
  }


  void _hangUp() {
    _webRTCService.hangUp();
    setState(() {
      _callState = "idle";
      _incomingCallerId = "";
      _latestOfferData = null; // Clear the offer
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text('Caretaker Dashboard (${widget.caretakerId})'),
        backgroundColor: Colors.teal,
      ),
      body: isWideScreen
          ? Row(
        children: [
          Expanded(flex: 2, child: _buildProfileSection()), // Profile on left
          const VerticalDivider(width: 1),
          Expanded(flex: 3, child: _buildCallSection()), // Call on right
        ],
      )
          : _buildCallSection(), // On mobile, just show the call screen
    );
  }

  Widget _buildProfileSection() {
    if (_isProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Caretaker Profile",
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(_profileData?['full_name'] ?? 'Loading...'),
            subtitle: Text(_profileData?['username'] ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text("Employee ID"),
            subtitle: Text(_profileData?['employee_id'] ?? 'N/A'),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Hostel Assigned"),
            subtitle: Text(_profileData?['hostel_assigned'] ?? 'N/A'),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text("Phone"),
            subtitle: Text(_profileData?['phone_number'] ?? 'N/A'),
          ),
          // TODO: Add an "Edit Profile" button here
          // ElevatedButton.icon(
          //   icon: Icon(Icons.edit),
          //   label: Text("Edit Profile"),
          //   onPressed: () {
          //     Navigator.push(context, MaterialPageRoute(
          //       builder: (context) => CaretakerProfileScreen() // You need to create this screen
          //     ));
          //   },
          // ),
          const Divider(height: 30),
          Text("Live Alerts", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.warning,
                color: _lastAlertLocation == "No active alerts"
                    ? Colors.grey
                    : Colors.red),
            title: const Text("Last SOS Location"),
            subtitle: Text(_lastAlertLocation),
          ),
        ],
      ),
    );
  }

  Widget _buildCallSection() {
    return Stack(
      children: [
        // --- Video Feeds ---
        Positioned.fill(
          child: Container(
            color: Colors.black87,
            child: RTCVideoView(_remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: true),
          ),
        ),
        Positioned(
          right: 20,
          top: 20,
          width: 120,
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              color: Colors.black,
              child: RTCVideoView(_localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
            ),
          ),
        ),

        // --- Call State UI ---
        if (_callState == "idle")
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10)),
              child: const Text(
                "Waiting for incoming SOS calls...",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),

        if (_callState == "incoming")
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Incoming SOS Call from:",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_incomingCallerId,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(
                            heroTag: 'reject',
                            onPressed: _hangUp,
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.call_end, color: Colors.white),
                          ),
                          const SizedBox(width: 40),

                          // --- THIS IS THE FINAL, CORRECTED BUTTON ---
                          FloatingActionButton(
                            heroTag: 'accept',
                            onPressed: _acceptCall, // <-- This is now safe
                            backgroundColor: Colors.green,
                            child: const Icon(Icons.call, color: Colors.white),
                          ),
                          // --- END FIX ---
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

        // --- Hangup Button (visible when connected) ---
        if (_callState == "connected")
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: FloatingActionButton(
              heroTag: 'hangup',
              onPressed: _hangUp,
              backgroundColor: Colors.red,
              child: const Icon(Icons.call_end, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

