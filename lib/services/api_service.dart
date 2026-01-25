import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _originalBaseUrl = 'http://43.199.253.222';

  // Timeout duration for API requests (Render free tier can be slow)
  static const Duration _timeout = Duration(seconds: 60);

  // For web: Run Flutter with --web-browser-flag "--disable-web-security"
  // Or configure CORS on your Django backend (recommended for production)
  static String get baseUrl => _originalBaseUrl;

  static String? _accessToken;
  static String? _refreshToken;
  static String? _sessionKey;

  // Get stored tokens
  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _sessionKey = prefs.getString('session_key');
  }

  // Save tokens
  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? sessionKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = accessToken;
    await prefs.setString('access_token', accessToken);

    if (refreshToken != null) {
      _refreshToken = refreshToken;
      await prefs.setString('refresh_token', refreshToken);
    }

    if (sessionKey != null) {
      _sessionKey = sessionKey;
      await prefs.setString('session_key', sessionKey);
    }
  }

  // Clear tokens on logout
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = null;
    _refreshToken = null;
    _sessionKey = null;
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('session_key');
  }

  // Get headers with auth
  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    if (_sessionKey != null) {
      headers['X-Session-Key'] = _sessionKey!;
    }

    return headers;
  }

  // Login
  static Future<ApiResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      debugPrint('Login response: $data');

      if (response.statusCode == 200) {
        // Save tokens
        await saveTokens(
          accessToken: data['access'] ?? data['token'],
          refreshToken: data['refresh'],
          sessionKey: data['session_key'],
        );

        return ApiResponse(
          success: true,
          data: data,
          message: 'Login successful',
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['detail'] ?? data['error'] ?? 'Login failed',
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/invoice/logout/'),
        headers: _headers,
      ).timeout(_timeout);
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    await clearTokens();
  }

  // GET request
  static Future<ApiResponse> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET error: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // POST request
  static Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final jsonBody = jsonEncode(data);
      debugPrint('POST $baseUrl$endpoint');
      debugPrint('Headers: $_headers');
      debugPrint('Body: $jsonBody');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonBody,
      ).timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST error: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // PUT request
  static Future<ApiResponse> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final jsonBody = jsonEncode(data);
      debugPrint('PUT $baseUrl$endpoint');
      debugPrint('Headers: $_headers');
      debugPrint('Body: $jsonBody');

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonBody,
      ).timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT error: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // PATCH request
  static Future<ApiResponse> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final jsonBody = jsonEncode(data);
      debugPrint('PATCH $baseUrl$endpoint');
      debugPrint('Headers: $_headers');
      debugPrint('Body: $jsonBody');

      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonBody,
      ).timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('PATCH error: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // Multipart POST request (for file uploads)
  // Supports both bytes (for web) and filePath (for mobile)
  static Future<ApiResponse> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    String? filePath,
    String? fileFieldName,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      debugPrint('POST MULTIPART $baseUrl$endpoint');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      // Add auth headers
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      if (_sessionKey != null) {
        request.headers['X-Session-Key'] = _sessionKey!;
      }

      // Add fields
      request.fields.addAll(fields);
      debugPrint('Fields: $fields');

      // Add file if provided - prefer bytes for web compatibility
      if (fileBytes != null && fileFieldName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          fileFieldName,
          fileBytes,
          filename: fileName ?? 'image.jpg',
        ));
        debugPrint('File added from bytes: $fileFieldName');
      } else if (filePath != null && fileFieldName != null && !kIsWeb) {
        request.files.add(await http.MultipartFile.fromPath(
          fileFieldName,
          filePath,
        ));
        debugPrint('File added from path: $fileFieldName = $filePath');
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST MULTIPART error: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // Multipart PUT request (for file uploads with update)
  // Supports both bytes (for web) and filePath (for mobile)
  static Future<ApiResponse> putMultipart(
    String endpoint,
    Map<String, String> fields, {
    String? filePath,
    String? fileFieldName,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      debugPrint('PUT MULTIPART $baseUrl$endpoint');

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl$endpoint'),
      );

      // Add auth headers
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      if (_sessionKey != null) {
        request.headers['X-Session-Key'] = _sessionKey!;
      }

      // Add fields
      request.fields.addAll(fields);
      debugPrint('Fields: $fields');

      // Add file if provided - prefer bytes for web compatibility
      if (fileBytes != null && fileFieldName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          fileFieldName,
          fileBytes,
          filename: fileName ?? 'image.jpg',
        ));
        debugPrint('File added from bytes: $fileFieldName');
      } else if (filePath != null && fileFieldName != null && !kIsWeb) {
        request.files.add(await http.MultipartFile.fromPath(
          fileFieldName,
          filePath,
        ));
        debugPrint('File added from path: $fileFieldName = $filePath');
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT MULTIPART error: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // DELETE request
  static Future<ApiResponse> delete(String endpoint) async {
    try {
      debugPrint('DELETE $baseUrl$endpoint');
      debugPrint('Headers: $_headers');

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      ).timeout(_timeout);

      debugPrint('DELETE Response status: ${response.statusCode}');
      debugPrint('DELETE Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE error: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  // Handle response
  static ApiResponse _handleResponse(http.Response response) {
    try {
      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        debugPrint('Server returned HTML error page');
        return ApiResponse(
          success: false,
          message: 'Server error (${response.statusCode}). Please try again.',
          statusCode: response.statusCode,
        );
      }

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: data,
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 401) {
        // Token expired - need to refresh or re-login
        return ApiResponse(
          success: false,
          message: 'Session expired. Please login again.',
          statusCode: response.statusCode,
        );
      } else {
        String message = 'Request failed (${response.statusCode})';
        if (data is Map) {
          message = data['detail'] ?? data['error'] ?? data['message'] ?? message;
        }
        return ApiResponse(
          success: false,
          message: message,
          statusCode: response.statusCode,
          data: data,
        );
      }
    } catch (e) {
      debugPrint('Response parsing error: $e');
      debugPrint('Response body was: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      return ApiResponse(
        success: false,
        message: 'Server error. Status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated => _accessToken != null;

  static String? get accessToken => _accessToken;
  static String? get sessionKey => _sessionKey;
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });
}
