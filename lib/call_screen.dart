import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final String targetId;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final VoidCallback onHangUp;

  const CallScreen({
    super.key,
    required this.targetId,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.onHangUp,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the renderers to start showing video/audio
    widget.localRenderer.initialize();
    widget.remoteRenderer.initialize();
  }

  @override
  void dispose() {
    widget.localRenderer.dispose();
    widget.remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // The remote user's video will fill the screen
          Positioned.fill(
            child: RTCVideoView(widget.remoteRenderer, mirror: true),
          ),
          // The local user's video appears as a small overlay
          Positioned(
            left: 20.0,
            top: 40.0,
            child: SizedBox(
              width: 100.0,
              height: 150.0,
              child: RTCVideoView(widget.localRenderer, mirror: true),
            ),
          ),
          // Hang-up button at the bottom
          Positioned(
            bottom: 30.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: widget.onHangUp,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
