import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  // Use 10.0.2.2 for Android Emulator, or your PC's IP for a real phone
 final String _baseUrl = "https://healix-backend-1.onrender.com/api";

  bool _isRefreshing = false;

  // --- Profile: Student ---
  Future<Map<String, dynamic>> getStudentProfile() async {
    final response = await _makeAuthenticatedRequest((token) => http.get(
      Uri.parse('$_baseUrl/student/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    ));
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    return {'success': false, 'message': 'Failed to load profile'};
  }

  Future<Map<String, dynamic>> updateStudentProfile(Map<String, dynamic> updatedData) async {
    final response = await _makeAuthenticatedRequest((token) => http.put(
      Uri.parse('$_baseUrl/student/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    ));
    if (response.statusCode == 200) {
      return {'success': true};
    }
    return {'success': false, 'message': response.body};
  }

  // --- Profile: Doctor ---
  Future<Map<String, dynamic>> getDoctorProfile() async {
    final response = await _makeAuthenticatedRequest((token) => http.get(
      Uri.parse('$_baseUrl/doctor/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    ));
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    return {'success': false, 'message': 'Failed to load profile'};
  }

  Future<Map<String, dynamic>> updateDoctorProfile(Map<String, dynamic> updatedData) async {
    final response = await _makeAuthenticatedRequest((token) => http.put(
      Uri.parse('$_baseUrl/doctor/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    ));
    if (response.statusCode == 200) {
      return {'success': true};
    }
    return {'success': false, 'message': response.body};
  }

  // --- Profile: Caretaker ---
  Future<Map<String, dynamic>> getCaretakerProfile() async {
    final response = await _makeAuthenticatedRequest((token) => http.get(
      Uri.parse('$_baseUrl/caretaker/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    ));
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    return {'success': false, 'message': 'Failed to load caretaker profile'};
  }

  Future<Map<String, dynamic>> updateCaretakerProfile(Map<String, dynamic> updatedData) async {
    final response = await _makeAuthenticatedRequest((token) => http.put(
      Uri.parse('$_baseUrl/caretaker/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    ));
    if (response.statusCode == 200) {
      return {'success': true};
    }
    return {'success': false, 'message': response.body};
  }

  // --- Profile: (Other) Staff ---
  Future<Map<String, dynamic>> getStaffProfile() async {
    final response = await _makeAuthenticatedRequest((token) => http.get(
      Uri.parse('$_baseUrl/staff/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    ));
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    return {'success': false, 'message': 'Failed to load staff profile'};
  }

  Future<Map<String, dynamic>> updateStaffProfile(Map<String, dynamic> updatedData) async {
    final response = await _makeAuthenticatedRequest((token) => http.put(
      Uri.parse('$_baseUrl/staff/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    ));
    if (response.statusCode == 200) {
      return {'success': true};
    }
    return {'success': false, 'message': response.body};
  }

  // --- Phone Call ---
  Future<void> makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }

  // --- Token Storage ---
  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }
  // =====================================================================================================
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
  // Future<String?> getAccessToken() async {
  //   final accessToken = await _storage.read(key: 'access_token');
  //   if (accessToken == null) {
  //     print("[Auth] No access token found.");
  //     return null;
  //   }
  //
  //   // 5-minute tolerance for upcoming expiry
  //   if (JwtDecoder.isExpired(accessToken)) {
  //     print("[Auth] Token expired. Attempting refresh...");
  //     final refreshed = await refreshToken();
  //     if (refreshed) {
  //       final newToken = await _storage.read(key: 'access_token');
  //       print("[Auth] Token refreshed successfully!");
  //       return newToken;
  //     } else {
  //       print("[Auth] Token refresh failed. Logging out user.");
  //       return null;
  //     }
  //   }
  //
  //   // Still valid
  //   return accessToken;
  // }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteTokens() async {
    await _storage.deleteAll();
  }

  // --- Token Refresh ---
  Future<bool> refreshToken() async {
    print("[DEBUG] Attempting to refresh token...");
    if (_isRefreshing) return false;
    _isRefreshing = true;

    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      _isRefreshing = false;
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'access_token', value: data['access']);
        print("[DEBUG] Access token refreshed successfully!");
        _isRefreshing = false;
        return true;
      } else {
        print("[DEBUG] Refresh failed — deleting tokens.");
        await deleteTokens();
        _isRefreshing = false;
        return false;
      }
    } catch (e) {
      print("[ERROR] Exception during token refresh: $e");
      _isRefreshing = false;
      return false;
    }
  }
  // Future<bool> refreshToken() async {
  //   print("[DEBUG] Attempting to refresh token...");
  //   if (_isRefreshing) return false;
  //   _isRefreshing = true;
  //
  //   final refreshToken = await getRefreshToken();
  //   if (refreshToken == null) {
  //     _isRefreshing = false;
  //     return false;
  //   }
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/token/refresh/'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'refresh': refreshToken}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       // ✅ Update both secure storage & in-memory token
  //       final newAccessToken = data['access'];
  //       await _storage.write(key: 'access_token', value: newAccessToken);
  //       print("[DEBUG] Access token refreshed successfully!");
  //
  //       _isRefreshing = false;
  //       return true;
  //     } else {
  //       print("[DEBUG] Refresh failed — deleting tokens.");
  //       await deleteTokens();
  //       _isRefreshing = false;
  //       return false;
  //     }
  //   } catch (e) {
  //     print("[ERROR] Exception during token refresh: $e");
  //     _isRefreshing = false;
  //     return false;
  //   }
  // }
  // Future<bool> refreshToken() async {
  //   if (_isRefreshing) return false;
  //   _isRefreshing = true;
  //
  //   try {
  //     final refreshToken = await _storage.read(key: 'refresh_token');
  //     if (refreshToken == null) {
  //       print("[Auth] No refresh token found.");
  //       _isRefreshing = false;
  //       return false;
  //     }
  //
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/token/refresh/'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'refresh': refreshToken}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       await _storage.write(key: 'access_token', value: data['access']);
  //
  //       // If backend returns a new refresh token, store it too
  //       if (data.containsKey('refresh')) {
  //         await _storage.write(key: 'refresh_token', value: data['refresh']);
  //       }
  //
  //       print("[DEBUG] Access token refreshed successfully!");
  //       _isRefreshing = false;
  //       return true;
  //     } else {
  //       print("[Auth] Refresh token invalid. ${response.body}");
  //       _isRefreshing = false;
  //       return false;
  //     }
  //   } catch (e) {
  //     print("[Auth] Exception during token refresh: $e");
  //     _isRefreshing = false;
  //     return false;
  //   }
  // }



  // --- Authenticated Request Wrapper ---
  Future<http.Response> _makeAuthenticatedRequest(
      Future<http.Response> Function(String token) requestFunction) async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      return http.Response(json.encode({'detail': 'Not authenticated'}), 401);
    }

    http.Response response = await requestFunction(accessToken);

    if (response.statusCode == 401) {
      final bool refreshed = await refreshToken();
      if (refreshed) {
        accessToken = await getAccessToken();
        if (accessToken != null) {
          response = await requestFunction(accessToken);
        }
      } else {
        await deleteTokens(); // Force logout
      }
    }
    return response;
  }

  // --- Auth: Login, Signup, OTP ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storeTokens(data['access'], data['refresh']);
        Map<String, dynamic> decodedToken = JwtDecoder.decode(data['access']);
        final role = decodedToken['role'] ?? 'unknown';
        return {'success': true, 'role': role};
      } else {
        return {'success': false, 'message': json.decode(response.body).toString()};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> signup(String username, String email,
      String password, String role, String fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/signup/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username, 'email': email, 'password': password,
          'role': role, 'full_name': fullName,
        }),
      );
      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {'success': false, 'message': json.decode(response.body).toString()};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  Future<bool> verifyOtp(String username, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'otp': otp}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- SOS & Alerts ---
  Future<Map<String, dynamic>> triggerSOS({
    required String location,
    required Map<String, dynamic> profileData,
  }) async {
    print("[DEBUG] Triggering SOS at: $location");
    final response = await _makeAuthenticatedRequest((token) => http.post(
      Uri.parse('$_baseUrl/sos/trigger/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'location_info': location,
        'profile': profileData,
      }),
    ));

    print("[DEBUG] SOS Response Code: ${response.statusCode}");
    if (response.statusCode == 201) {
      return {'success': true, 'data': json.decode(response.body)};
    }
    return {'success': false, 'message': json.decode(response.body).toString()};
  }

  Future<List<dynamic>> getActiveAlerts() async {
    final response = await _makeAuthenticatedRequest((token) => http.get(
      Uri.parse('$_baseUrl/sos/active/'),
      headers: {'Authorization': 'Bearer $token'},
    ));
    if (response.statusCode == 200) return json.decode(response.body);
    return [];
  }

  Future<bool> resolveAlert(int alertId) async {
    final response = await _makeAuthenticatedRequest((token) => http.post(
      Uri.parse('$_baseUrl/sos/$alertId/resolve/'),
      headers: {'Authorization': 'Bearer $token'},
    ));
    return response.statusCode == 200;
  }
}

