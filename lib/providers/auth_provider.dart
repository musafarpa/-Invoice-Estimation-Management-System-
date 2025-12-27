import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isSuperAdmin => _currentUser?.role == 'super_admin';

  // Dummy users for testing
  final List<UserModel> _dummyUsers = [
    UserModel(
      id: '1',
      name: 'Leandro',
      email: 'admin@invoice.com',
      password: 'admin123',
      role: 'super_admin',
      createdAt: DateTime.now(),
    ),
    UserModel(
      id: '2',
      name: 'John Doe',
      email: 'user@invoice.com',
      password: 'user123',
      role: 'user',
      createdAt: DateTime.now(),
    ),
  ];

  List<UserModel> get allUsers => _dummyUsers;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = _dummyUsers.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void addUser(UserModel user) {
    _dummyUsers.add(user);
    notifyListeners();
  }

  void updateUser(UserModel user) {
    final index = _dummyUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _dummyUsers[index] = user;
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _dummyUsers.removeWhere((u) => u.id == userId);
    notifyListeners();
  }
}
