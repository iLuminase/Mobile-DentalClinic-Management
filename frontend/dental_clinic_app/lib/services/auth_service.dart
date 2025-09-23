import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;

  AuthService() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _userEmail = prefs.getString('userEmail');
      _userRole = prefs.getString('userRole');
      notifyListeners();
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      // For now, implement a simple authentication
      // In a real app, this would call the backend API
      if (email.isNotEmpty && password.length >= 6) {
        _isAuthenticated = true;
        _userEmail = email;
        _userRole = email.contains('admin') ? 'ADMIN' : 'RECEPTIONIST';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userRole', _userRole!);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isAuthenticated = false;
      _userEmail = null;
      _userRole = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  bool hasRole(String role) {
    return _userRole == role;
  }

  bool hasAnyRole(List<String> roles) {
    return roles.contains(_userRole);
  }
}