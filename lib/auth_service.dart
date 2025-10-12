import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = "http://localhost:8000/api"; // Your IP address

  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteTokens() async {
    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/token/'), // Your JWT login endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storeTokens(data['access'], data['refresh']);
      return {'success': true};
    } else {
      return {'success': false, 'message': 'Login failed'};
    }
  }

  Future<Map<String, dynamic>> signup(
      String username, String email, String password, String role, String fullName) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/signup/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'full_name': fullName, // <-- ADDED THIS LINE
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      return {'success': false, 'message': json.decode(response.body).toString()};
    }
  }

  Future<bool> verifyOtp(String username, String otp) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/verify-otp/'), // Your new OTP verification endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'otp': otp}),
    );
    return response.statusCode == 200;
  }

  Future<bool> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: 'access_token', value: data['access']);
      return true;
    } else {
      // Refresh token is invalid, force logout
      await deleteTokens();
      return false;
    }
  }
}
//```
//
//2.  **Update `lib/signup_page.dart`:**
//Now, update the call in your signup page to pass the `_nameController.text`.
//
//```dart
//// In lib/signup_page.dart, inside the _handleSignup function
//
//// --- UPDATE THIS CALL ---
//final result = await _authService.signup(
//_idController.text,
//_emailController.text,
//_passwordController.text,
//_selectedRole.toLowerCase(),
//_nameController.text, // <-- ADD THIS ARGUMENT
//);
//```
//
//#### Step 2: Make the Backend More Robust (Highly Recommended)
//
//To prevent your server from crashing with a `KeyError` in the future, it's a best practice to use the `.get()` method on dictionaries. This allows you to provide a default value if a key is missing.
//
//1.  Open your `api/serializers.py` file.
//2.  Find the `create` method in your `UserSerializer`.
//3.  Change the line that accesses `full_name`.
//
//**Change this:**
//```python
//user = User.objects.create_user(
//# ... other fields
//full_name=validated_data['full_name'],
//# ... other fields
//)
//```
//
//**To this (more robust version):**
//```python
//user = User.objects.create_user(
//# ... other fields
//full_name=validated_data.get('full_name', ''), # Use .get() with a default empty string
//# ... other fields
//)


