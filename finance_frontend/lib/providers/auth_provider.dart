import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String get role => _user?['role'] ?? '';
  bool get isAdmin => role == 'ADMIN';
  bool get isAnalyst => role == 'ANALYST' || role == 'ADMIN';

  Future<void> checkSession() async {
    _user = await ApiService.getUser();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.login(username, password);
      if (res.containsKey('token')) {
        await ApiService.saveToken(res['token']);
        await ApiService.saveUser(res);
        _user = res;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = res['message'] ?? 'Login failed';
    } catch (e) {
      _error = 'Connection error. Is the backend running?';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String username, String password, String email, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.register(username, password, email, role);
      if (res.containsKey('token')) {
        await ApiService.saveToken(res['token']);
        await ApiService.saveUser(res);
        _user = res;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = res['message'] ?? 'Registration failed';
    } catch (e) {
      _error = 'Connection error. Is the backend running?';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await ApiService.clearSession();
    _user = null;
    notifyListeners();
  }
}
