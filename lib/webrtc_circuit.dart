import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebRTCService {
  final String currentUserId;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  late final WebSocketChannel _channel;

  // Configuration for the STUN servers (for NAT traversal)
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  WebRTCService({
    required this.currentUserId,
    required this.localRenderer,
    required this.remoteRenderer,
  });

  Future<void> initialize() async {
    // Connect to your signaling server
    _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8765')); // Use your machine's IP for physical device

    // Authenticate with the signaling server
    _channel.sink.add(json.encode({'user_id': currentUserId}));

    // Listen for incoming messages
    _channel.stream.listen((message) {
      final data = json.decode(message);
      _handleSignalingMessage(data);
    });

    await _createPeerConnection();
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      // Send the ICE candidate to the other peer
      _sendSignalingMessage({
        'type': 'candidate',
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      // When the remote stream is added, attach it to the renderer
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    // Get the user's camera and microphone
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    // Add the local stream to the peer connection
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // Display the local stream
    localRenderer.srcObject = _localStream;
  }

  Future<void> makeCall(String targetId) async {
    if (_peerConnection == null) await _createPeerConnection();

    // Create an SDP offer
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // Send the offer to the target user via the signaling server
    _sendSignalingMessage({
      'type': 'offer',
      'offer': offer.toMap(),
      'target': targetId,
    });
  }

  void _handleSignalingMessage(Map<String, dynamic> data) async {
    final type = data['type'];
    final fromId = data['from'];

    if (type == 'offer') {
      // Received an offer, create an answer
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(data['offer']['sdp'], data['offer']['type']),
      );

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      // Send the answer back to the caller
      _sendSignalingMessage({
        'type': 'answer',
        'answer': answer.toMap(),
        'target': fromId,
      });

    } else if (type == 'answer') {
      // Received an answer, set the remote description
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
      );

    } else if (type == 'candidate') {
      // Received an ICE candidate, add it to the peer connection
      await _peerConnection?.addCandidate(
        RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        ),
      );
    }
  }

  void _sendSignalingMessage(Map<String, dynamic> data) {
    _channel.sink.add(json.encode(data));
  }

  void hangUp() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();
    _peerConnection = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
  }

  void dispose() {
    _channel.sink.close();
    hangUp();
  }
}
