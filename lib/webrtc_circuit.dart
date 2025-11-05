
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
class WebRTCService {
  final String currentUserId;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final String token;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  late final WebSocketChannel _channel;
  String? _targetId;

  Function(Map<String, dynamic> offerData)? onOfferReceived;

  // --- Backend base URL ---
  final String _serverUrl = "healix-backend-1.onrender.com";

  WebRTCService({
    required this.currentUserId,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.token,
  });

  // --- Initialize connection ---
  Future<void> initialize() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final wsUrl = 'wss://$_serverUrl/ws/call/?token=$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    print("WebRTC: Connecting to $wsUrl");

    _channel.stream.listen((message) {
      final data = json.decode(message);
      _handleSignalingMessage(data);
    });
  }
  // final String _serverHost = "healix-backend-1.onrender.com"; // host only


  // Future<void> initialize() async {
  //   await [Permission.camera, Permission.microphone].request();
  //
  //   final uri = Uri(
  //     scheme: 'wss',
  //     host: _serverUrl,
  //     path: '/ws/call/',
  //     queryParameters: {'token': token},
  //   );
  //
  //   // Send Origin header matching server validator
  //   _channel = IOWebSocketChannel.connect(
  //     uri,
  //     headers: {'Origin': 'https://healix-backend-1.onrender.com'},
  //   );
  //
  //   _channel.stream.listen((message) {
  //     final data = json.decode(message);
  //     _handleSignalingMessage(data);
  //   }, onError: (e) {
  //     print('Signaling WS error: $e');
  //   }, onDone: () {
  //     print('Signaling WS closed');
  //   });
  //
  //   print("WebRTC: Connecting to $uri");
  // }

  // --- Fetch TURN credentials and create PeerConnection ---
  Future<void> _createPeerConnection() async {
    print("WebRTC: Fetching ICE servers from backend...");
    Map<String, dynamic> iceConfig;

    try {
      final turnData = await getTurnCredentials();

      if (turnData != null && turnData.containsKey('iceServers')) {
        iceConfig = turnData;
        print("WebRTC: Got ICE config: ${jsonEncode(iceConfig)}");
      } else {
        print("TURN response missing iceServers — using fallback STUN.");
        iceConfig = {
          'iceServers': [
            {'urls': 'stun:stun.l.google.com:19302'}
          ]
        };
      }
    } catch (e) {
      print("Exception fetching ICE servers: $e");
      iceConfig = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'}
        ]
      };
    }

    iceConfig['sdpSemantics'] = 'unified-plan';

    _peerConnection = await createPeerConnection(iceConfig);

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
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

  // --- Make call ---
  Future<void> makeCall(String targetId) async {
    if (_peerConnection == null) await _createPeerConnection();
    _targetId = targetId;

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      _sendSignalingMessage({
        'type': 'candidate',
        'candidate': candidate.toMap(),
        'target': targetId,
      });
    };

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _sendSignalingMessage({
      'type': 'offer',
      'offer': offer.toMap(),
      'target': _targetId,
    });
    print("WebRTC: Making call to $_targetId");
  }

  // --- Accept call ---
  Future<void> acceptCall(Map<String, dynamic> offerData) async {
    if (_peerConnection == null) await _createPeerConnection();

    final offer = offerData['offer'];
    final fromId = offerData['from'];
    _targetId = fromId;

    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _sendSignalingMessage({
      'type': 'answer',
      'answer': answer.toMap(),
      'target': fromId,
    });
    print("WebRTC: Accepting call from $fromId");
  }

  // --- Handle signaling messages ---
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

  // --- Send signaling message ---
  void _sendSignalingMessage(Map<String, dynamic> data) {
    _channel.sink.add(json.encode(data));
  }

  // --- Hang up ---
  void hangUp() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();
    _peerConnection = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    _targetId = null;
    print("WebRTC: Call hung up.");
  }

  // --- Dispose ---
  void dispose() {
    _channel.sink.close();
    hangUp();
  }

  // --- Fetch TURN credentials with token refresh support ---
  Future<Map<String, dynamic>?> getTurnCredentials() async {
    final url = Uri.parse('https://$_serverUrl/api/get-turn-credentials/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("[DEBUG] GET-TURN: status=${response.statusCode}");
      print("[DEBUG] GET-TURN: body=${response.body}");

      if (response.statusCode == 200) {
        print("[DEBUG] TURN credentials fetched successfully.");
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        print("[DEBUG] TURN fetch failed: Token expired or invalid.");
        // Optional: handle refresh via ApiService if accessible
        return null;
      } else {
        print("[ERROR] TURN fetch failed: ${response.statusCode} — ${response.body}");
        return null;
      }
    } catch (e) {
      print("[ERROR] Exception fetching TURN credentials: $e");
      return null;
    }
  }
}





