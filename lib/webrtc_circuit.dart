import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
class WebRTCService {
  final String currentUserId;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  late final WebSocketChannel _channel;
  String? _targetId; // To remember who we are calling/talking to

  // Callback to notify the UI of an incoming offer
  Function(Map<String, dynamic> offerData)? onOfferReceived;

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
    // Connect to your standalone Python signaling server
    // Use 10.0.2.2 for Android Emulator, or your PC's IP for a real phone

    await [
      Permission.camera,
      Permission.microphone,
    ].request();
    final wsUrl = 'ws://192.168.29.196:8765';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // Authenticate with the signaling server as per your Python script
    _channel.sink.add(json.encode({'user_id': currentUserId}));
    print("WebRTC: Sent auth with user_id: $currentUserId");

    _channel.stream.listen((message) {
      final data = json.decode(message);
      _handleSignalingMessage(data);
    });

    await _createPeerConnection();
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      // Send candidate only if we know who we are talking to
      if (_targetId != null) {
        _sendSignalingMessage({
          'type': 'candidate',
          'candidate': candidate.toMap(),
          'target': _targetId,
        });
      }
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    localRenderer.srcObject = _localStream;
  }

  Future<void> makeCall(String targetId) async {
    if (_peerConnection == null) await _createPeerConnection();
    _targetId = targetId; // Remember who we are calling

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _sendSignalingMessage({
      'type': 'offer',
      'offer': offer.toMap(),
      'target': _targetId,
    });
    print("WebRTC: Making call to $_targetId");
  }

  Future<void> acceptCall(Map<String, dynamic> offerData) async {
    if (_peerConnection == null) await _createPeerConnection();

    final offer = offerData['offer'];
    final fromId = offerData['from'];
    _targetId = fromId; // Remember this person for candidates

    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _sendSignalingMessage({
      'type': 'answer',
      'answer': answer.toMap(),
      'target': fromId, // Send answer back to the caller
    });
    print("WebRTC: Accepting call from $fromId");
  }

  void _handleSignalingMessage(Map<String, dynamic> data) async {
    final type = data['type'];
    final fromId = data['from'];

    switch (type) {
      case 'offer':
        if (onOfferReceived != null) {
          onOfferReceived!(data);
        }
        break;
      case 'answer':
        print("WebRTC: Received answer from $fromId");
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
        );
        break;
      case 'candidate':
        await _peerConnection?.addCandidate(
          RTCIceCandidate(
            data['candidate']['candidate'],
            data['candidate']['sdpMid'],
            data['candidate']['sdpMLineIndex'],
          ),
        );
        break;
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
    _targetId = null;
    print("WebRTC: Call hung up.");
  }

  void dispose() {
    _channel.sink.close();
    hangUp();
  }
}
