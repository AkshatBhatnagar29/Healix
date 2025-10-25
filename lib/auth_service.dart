
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
final _storage = const FlutterSecureStorage();
// final String _baseUrl = "https://healix-backend-goc4.onrender.com/api";
// final String _baseUrl="http://192.168.29.196:8000/api";
final String _baseUrl = "http://127.0.0.1:8000/api";

bool _isRefreshing = false;
Future<Map<String, dynamic>> getStudentProfile() async {
  try {
    final accessToken = await _storage.read(key: 'access_token');

    if (accessToken == null) {
      print('[DEBUG] No access token found — forcing logout.');
      return {'success': false, 'logout': true};
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/student/profile/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('[DEBUG] Profile response code: ${response.statusCode}');
    print('[DEBUG] Profile response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else if (response.statusCode == 401) {
      // Token expired or invalid
      return {'success': false, 'logout': true};
    } else {
      return {'success': false, 'message': jsonDecode(response.body).toString()};
    }
  } catch (e) {
    print('[ERROR] Failed to load profile: $e');
    return {'success': false, 'message': 'Could not load profile data.'};
  }
}

Future<Map<String, dynamic>> updateStudentProfile(Map<String, dynamic> updatedData) async {
  try {
    final accessToken = await _storage.read(key: 'access_token');

    if (accessToken == null) return {'success': false, 'logout': true};

    final response = await http.put(
      Uri.parse('$_baseUrl/student/profile/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    print('[DEBUG] Update response code: ${response.statusCode}');
    print('[DEBUG] Update response body: ${response.body}');

    if (response.statusCode == 200) {
      return {'success': true};
    } else if (response.statusCode == 401) {
      return {'success': false, 'logout': true};
    } else {
      return {'success': false, 'message': response.body};
    }
  } catch (e) {
    print('[ERROR] Update profile failed: $e');
    return {'success': false, 'message': 'Error updating profile'};
  }
}


Future<void> makeCall(String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    print('Could not launch $phoneNumber');
  }
}
// -------------------------------
// --- TOKEN STORAGE METHODS -----
// -------------------------------

Future<void> _storeTokens(String accessToken, String refreshToken) async {
print("[DEBUG] Storing tokens securely...");
print("[DEBUG] Access Token (truncated): ${accessToken.substring(0, 20)}...");
print("[DEBUG] Refresh Token (truncated): ${refreshToken.substring(0, 20)}...");

await _storage.write(key: 'access_token', value: accessToken);
await _storage.write(key: 'refresh_token', value: refreshToken);

print("[DEBUG] Tokens saved successfully!");
}

Future<String?> getAccessToken() async {
final token = await _storage.read(key: 'access_token');
print("[DEBUG] Retrieved access token: ${token != null ? token.substring(0, 20) + '...' : 'null'}");
return token;
}

Future<String?> getRefreshToken() async {
final token = await _storage.read(key: 'refresh_token');
print("[DEBUG] Retrieved refresh token: ${token != null ? token.substring(0, 20) + '...' : 'null'}");
return token;
}

Future<void> deleteTokens() async {
print("[DEBUG] Deleting tokens from secure storage...");
await _storage.deleteAll();
print("[DEBUG] Tokens deleted.");
}

// -------------------------------
// --- TOKEN REFRESH LOGIC -------
// -------------------------------
Future<bool> refreshToken() async {
print("[DEBUG] Attempting to refresh token...");
if (_isRefreshing) {
print("[DEBUG] Already refreshing — skipping duplicate call.");
return false;
}

_isRefreshing = true;
final refreshToken = await getRefreshToken();

if (refreshToken == null) {
print("[DEBUG] No refresh token found — cannot refresh.");
_isRefreshing = false;
return false;
}

try {
final response = await http.post(
Uri.parse('$_baseUrl/token/refresh/'),
headers: {'Content-Type': 'application/json'},
body: json.encode({'refresh': refreshToken}),
);

print("[DEBUG] Refresh token response code: ${response.statusCode}");
print("[DEBUG] Response body: ${response.body}");

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

// -------------------------------
// --- AUTHENTICATED REQUEST -----
// -------------------------------
Future<http.Response> _makeAuthenticatedRequest(
Future<http.Response> Function(String token) requestFunction) async {
String? accessToken = await getAccessToken();

if (accessToken == null) {
print("[DEBUG] No access token found — returning 401.");
return http.Response(json.encode({'detail': 'Not authenticated'}), 401);
}

print("[DEBUG] Sending authenticated request...");
http.Response response = await requestFunction(accessToken);
print("[DEBUG] Response code: ${response.statusCode}");

if (response.statusCode == 401) {
print("[DEBUG] Access token expired — attempting refresh...");
final bool refreshed = await refreshToken();

if (refreshed) {
accessToken = await getAccessToken();
if (accessToken != null) {
print("[DEBUG] Retrying request with new token...");
response = await requestFunction(accessToken);
}
} else {
print("[DEBUG] Refresh failed — clearing tokens.");
await deleteTokens();
}
}

return response;
}

// -------------------------------
// --- LOGIN FUNCTION ------------
// -------------------------------
Future<Map<String, dynamic>> login(String username, String password) async {
print("[DEBUG] Login attempt for: $username");

try {
final response = await http.post(
Uri.parse('$_baseUrl/token/'),
headers: {'Content-Type': 'application/json'},
body: json.encode({'username': username, 'password': password}),
);

print("[DEBUG] Login response: ${response.statusCode}");
print("[DEBUG] Body: ${response.body}");

if (response.statusCode == 200) {
final data = json.decode(response.body);
final accessToken = data['access'];
final refreshToken = data['refresh'];

await _storeTokens(accessToken, refreshToken);

Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
final role = decodedToken.containsKey('role') ? decodedToken['role'] : 'unknown';

print("[DEBUG] Decoded JWT Role: $role");

return {'success': true, 'role': role};
} else {
final message = json.decode(response.body).toString();
print("[DEBUG] Login failed: $message");
return {'success': false, 'message': message};
}
} catch (e) {
print("[ERROR] Login exception: $e");
return {'success': false, 'message': 'Network error during login.'};
}
}

// -------------------------------
// --- SIGNUP FUNCTION -----------
// -------------------------------
Future<Map<String, dynamic>> signup(
String username, String email, String password, String role, String fullName) async {
print("[DEBUG] Signup attempt for: $username ($role)");

try {
final response = await http.post(
Uri.parse('$_baseUrl/signup/'),
headers: {'Content-Type': 'application/json'},
body: json.encode({
'username': username,
'email': email,
'password': password,
'role': role,
'full_name': fullName,
}),
);

print("[DEBUG] Signup response: ${response.statusCode}");
print("[DEBUG] Body: ${response.body}");

if (response.statusCode == 201) {
print("[DEBUG] Signup successful!");
return {'success': true};
} else {
final msg = json.decode(response.body).toString();
print("[DEBUG] Signup failed: $msg");
return {'success': false, 'message': msg};
}
} catch (e) {
print("[ERROR] Signup exception: $e");
return {'success': false, 'message': 'Network error during signup.'};
}
}

// -------------------------------
// --- OTP VERIFICATION ----------
// -------------------------------
Future<bool> verifyOtp(String username, String otp) async {
print("[DEBUG] Verifying OTP for $username with OTP $otp");
final response = await http.post(
Uri.parse('$_baseUrl/verify-otp/'),
headers: {'Content-Type': 'application/json'},
body: json.encode({'username': username, 'otp': otp}),
);
print("[DEBUG] OTP Response: ${response.statusCode}");
return response.statusCode == 200;
}

Future<Map<String, dynamic>> triggerSOS(String location) async {
print("[DEBUG] Triggering SOS at: $location");

final response = await _makeAuthenticatedRequest((token) => http.post(
Uri.parse('$_baseUrl/sos/trigger/'),
headers: {
'Content-Type': 'application/json',
'Authorization': 'Bearer $token',
},
body: json.encode({'location_info': location}),
));

// await makeCall('+917060045109');
final response2 = await http.post(
  Uri.parse('$_baseUrl/sos/send-email/'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'location': location}),
);

if (response2.statusCode == 200) {
  print("SOS email sent successfully via Resend!");
} else {
  print("Failed to send SOS email: ${response2.body}");
}

print("[DEBUG] SOS Response Code: ${response.statusCode}");

if (response.statusCode == 201) return {'success': true, 'data': json.decode(response.body)};
if (response.statusCode == 401) return {'success': false, 'logout': true};

return {'success': false, 'message': json.decode(response.body).toString()};
}

Future<List<dynamic>> getActiveAlerts() async {
print("[DEBUG] Fetching active SOS alerts...");
final response = await _makeAuthenticatedRequest((token) => http.get(
Uri.parse('$_baseUrl/sos/active/'),
headers: {'Authorization': 'Bearer $token'},
));
print("[DEBUG] Alerts response: ${response.statusCode}");
if (response.statusCode == 200) return json.decode(response.body);
return [];
}

Future<bool> acknowledgeAlert(int alertId) async {
print("[DEBUG] Acknowledging alert ID: $alertId");
final response = await _makeAuthenticatedRequest((token) => http.post(
Uri.parse('$_baseUrl/sos/$alertId/acknowledge/'),
headers: {'Authorization': 'Bearer $token'},
));
print("[DEBUG] Acknowledge response: ${response.statusCode}");
return response.statusCode == 200;
}

Future<bool> resolveAlert(int alertId) async {
print("[DEBUG] Resolving alert ID: $alertId");
final response = await _makeAuthenticatedRequest((token) => http.post(
Uri.parse('$_baseUrl/sos/$alertId/resolve/'),
headers: {'Authorization': 'Bearer $token'},
));
print("[DEBUG] Resolve response: ${response.statusCode}");
return response.statusCode == 200;
}}
