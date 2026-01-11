import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isSuperAdmin => _currentUser?.role == 'super_admin';
  bool get isAdmin => _currentUser?.role == 'admin';
  // Can manage users if super_admin OR admin
  bool get canManageUsers => isSuperAdmin || isAdmin;
  String? get errorMessage => _errorMessage;

  // Local users list (fetched from API or cached)
  final List<UserModel> _users = [];

  List<UserModel> get allUsers => _users;

  // Initialize - check for stored session
  Future<void> init() async {
    await ApiService.loadTokens();
    if (ApiService.isAuthenticated) {
      // Try to get user profile
      await _fetchCurrentUser();
    }
  }

  // Fetch current user profile
  Future<void> _fetchCurrentUser() async {
    final response = await ApiService.get('/invoice/profile/');
    debugPrint('Profile response: ${response.data}');
    if (response.success && response.data != null) {
      // Handle nested 'user' object if present
      final userData = response.data['user'] ?? response.data;
      debugPrint('Profile userData for parsing: $userData');
      _currentUser = UserModel.fromJson(userData);
      debugPrint('Current user role after profile fetch: ${_currentUser?.role}');
      debugPrint('isSuperAdmin after profile fetch: $isSuperAdmin');
      notifyListeners();
    }
  }

  // Helper to parse role from API response
  String _parseRole(Map<String, dynamic> data) {
    // Check 'role' field first (SUPERADMIN, ADMIN, USER, etc.)
    if (data['role'] != null) {
      final apiRole = data['role'].toString().toUpperCase();
      if (apiRole == 'SUPERADMIN' || apiRole == 'SUPER_ADMIN') {
        return 'super_admin';
      } else if (apiRole == 'ADMIN') {
        return 'admin';
      }
    }
    // Fallback to is_superuser/is_staff flags
    if (data['is_superuser'] == true) {
      return 'super_admin';
    }
    if (data['is_staff'] == true) {
      return 'admin';
    }
    return 'user';
  }

  // Login with API
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.login(username, password);

    if (response.success) {
      // Extract user data from response - handle nested 'user' object
      final data = response.data;
      debugPrint('Login response data: $data');

      // Check if user data is nested under 'user' key
      final userData = data['user'] ?? data;
      debugPrint('User data for parsing: $userData');

      final role = _parseRole(userData);
      debugPrint('Parsed role: $role');

      _currentUser = UserModel(
        id: userData['user_id']?.toString() ?? userData['id']?.toString() ?? data['user_id']?.toString() ?? '1',
        name: userData['username'] ?? userData['name'] ?? username,
        email: userData['email'] ?? '$username@invoice.com',
        password: '',
        role: role,
        createdAt: DateTime.now(),
      );
      debugPrint('Current user role set to: ${_currentUser?.role}');
      debugPrint('isSuperAdmin after login: $isSuperAdmin');
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await ApiService.logout();

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  // Fetch all users (admin only)
  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Debug: Check if we have a valid token
    print('Fetching users... Token available: ${ApiService.accessToken != null}');

    final response = await ApiService.get('/accounts/users/');
    print('Fetch users response: ${response.success}, status: ${response.statusCode}, message: ${response.message}');
    if (response.success && response.data != null) {
      _users.clear();
      List<dynamic> usersData = [];

      // Handle different API response formats
      if (response.data is List) {
        usersData = response.data;
      } else if (response.data is Map) {
        // Try common wrapper keys
        usersData = response.data['results'] ??
                    response.data['users'] ??
                    response.data['data'] ?? [];
      }

      for (var userData in usersData) {
        _users.add(UserModel.fromJson(userData));
      }
    } else {
      _errorMessage = response.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  // Helper to convert role to API format
  String _toApiRole(String role) {
    // super_admin -> SUPERADMIN, admin -> ADMIN, user -> USER
    if (role == 'super_admin' || role.toUpperCase() == 'SUPERADMIN') {
      return 'SUPERADMIN';
    } else if (role == 'admin' || role.toUpperCase() == 'ADMIN') {
      return 'ADMIN';
    }
    return 'USER';
  }

  // Add user
  Future<bool> addUser(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.post('/accounts/users/', {
      'username': user.name,
      'email': user.email,
      'password': user.password,
      'role': _toApiRole(user.role),
      'is_active': true,
    });

    _isLoading = false;
    if (response.success) {
      await fetchUsers();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  // Update user
  Future<bool> updateUser(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Password is REQUIRED by the API for updates
    if (user.password.isEmpty) {
      _errorMessage = 'Password is required to update user';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final body = {
      'username': user.name,
      'email': user.email,
      'password': user.password,
      'role': _toApiRole(user.role),
      'is_active': true,
    };

    debugPrint('Update user request body: $body');

    final response = await ApiService.put('/accounts/users/${user.id}/', body);

    debugPrint('Update user response: success=${response.success}, status=${response.statusCode}, message=${response.message}');

    _isLoading = false;
    if (response.success) {
      // Refresh users list to get updated data from server
      await fetchUsers();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.delete('/accounts/users/$userId/');

    _isLoading = false;
    if (response.success || response.statusCode == 204) {
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
