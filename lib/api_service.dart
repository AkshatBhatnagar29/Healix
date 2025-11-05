import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

// --- Models (kept in same file for simplicity) ---

class SosDetails {
  final String studentUsername;
  final Map<String, dynamic> profile;
  final String locationInfo;
  final String alertTime;

  SosDetails({
    required this.studentUsername,
    required this.profile,
    required this.locationInfo,
    required this.alertTime,
  });

  factory SosDetails.fromJson(Map<String, dynamic> json) {
    return SosDetails(
      studentUsername: json['student_username'] ?? 'N/A',
      profile: json['profile'] ?? {},
      locationInfo: json['location_info'] ?? 'No location provided',
      alertTime: json['alert_time'] ?? 'N/A',
    );
  }
}

class DoctorProfile {
  final String username;
  final String fullName;
  final String email;
  final String specialization;
  final int experience;
  final String profilePictureUrl;

  DoctorProfile({
    required this.username,
    required this.fullName,
    required this.email,
    required this.specialization,
    required this.experience,
    required this.profilePictureUrl,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      specialization: json['specialization'] ?? '',
      experience: json['experience'] ?? 0,
      profilePictureUrl: json['profile_picture_url'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

// --- Main API Service ---
class ApiService with ChangeNotifier {
  // Use 10.0.2.2 for Android Emulator, or your PC's IP for a real phone
  final String _baseUrl = "https://healix-backend-1.onrender.com/api";
  String? _token;

  bool _isAvailable = false;
  bool _isLoading = false;
  String? _activeSosEventId;
  WebSocketChannel? _channel;

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  String? get activeSosEventId => _activeSosEventId;

  void updateToken(String token) {
    _token = token;
    print("Doctor ApiService: Token updated.");
  }

  Future<void> setAvailability(bool available) async {
    if (_token == null) {
      print("Doctor ApiService: Cannot set availability, token is null.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    final url = available ? '/doctor/available/' : '/doctor/unavailable/';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$url'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        _isAvailable = available;
        if (_isAvailable) {
          _connectToWebSocket();
        } else {
          _disconnectFromWebSocket();
        }
      } else {
        print('Failed to update availability: ${response.statusCode}');
      }
    } catch (e) {
      print('Availability error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _connectToWebSocket() {
    if (_token == null) return;

    // Use 10.0.2.2 for Android Emulator, or your PC's IP for a real phone
    final wsUrl = 'wss://healix-backend-1.onrender.com/ws/sos_alerts/?token=$_token';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['type'] == 'sos_notification') {
          _activeSosEventId = data['sos_event_id'];
          print('🚨 Doctor: New SOS Alert: $_activeSosEventId');
          notifyListeners();
        }
      }, onDone: () {
        print('Doctor WebSocket closed');
        if (_isAvailable) {
          _connectToWebSocket(); // Attempt to reconnect
        }
      }, onError: (error) {
        print('Doctor WebSocket Error: $error');
      });
    } catch (e) {
      print('Doctor WebSocket connection error: $e');
    }
  }

  void _disconnectFromWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }

  Future<SosDetails> getSosDetails(String eventId) async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/sos/details/$eventId/'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      return SosDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load SOS details');
    }
  }

  Future<DoctorProfile> getDoctorProfile() async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/doctor/profile/'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      return DoctorProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<bool> updateDoctorProfile(Map<String, dynamic> data) async {
    if (_token == null) return false;

    final response = await http.put( // Use PUT
      Uri.parse('$_baseUrl/doctor/profile/'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  void clearSosAlert() {
    _activeSosEventId = null;
    notifyListeners();
  }
}
