import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:healix/webrtc_circuit.dart';

class StudentCallScreen extends StatelessWidget {
  final WebRTCService webRTCService;
  const StudentCallScreen({super.key, required this.webRTCService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call in Progress"),
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false, // Don't show back button
      ),
      body: Stack(
        children: [
          // Remote Video (Caretaker)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: RTCVideoView(webRTCService.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
            ),
          ),
          // Local Video (Student)
          Positioned(
            right: 20,
            top: 20,
            width: 120,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                color: Colors.black45,
                child: RTCVideoView(webRTCService.localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          webRTCService.hangUp();
          Navigator.of(context).pop(); // Go back to student homepage
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.call_end, color: Colors.white),
      ),
    );
  }
}
