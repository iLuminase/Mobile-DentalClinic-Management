
import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/auth_service.dart';
import 'package:doanmobile/src/core/services/menu_service.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final MenuService _menuService = MenuService();

  User? _user;
  List<MenuItem> _menuItems = [];
  Map<int, String> _allRoles = {};
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _user;
  List<MenuItem> get menuItems => _menuItems;
  Map<int, String> get allRoles => _allRoles;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _user!.role != 'PENDING_USER';
  bool get isInitialized => _isInitialized;

  Future<void> tryAutoLogin() async {
    try {
      final user = await _authService.getLoggedInUser();
      if (user != null) {
        if (user.role == 'PENDING_USER') {
          await _authService.logout();
          _user = null;
        } else {
          _user = user;
          await _loadInitialData();
        }
      }
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(username, password);

      if (user == null) {
        return 'Đăng nhập thất bại. Vui lòng kiểm tra lại tên đăng nhập và mật khẩu.';
      }

      if (user.role == 'PENDING_USER') {
        await _authService.logout();
        _user = null;
        return 'Tài khoản của bạn đã được tạo và đang chờ quản trị viên phê duyệt.';
      }

      _user = user;
      await _loadInitialData();
      return null;
    } catch (e) {
      debugPrint("Lỗi trong AuthProvider.login: $e");
      return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _menuItems = [];
    _allRoles = {};
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    _menuItems = await _menuService.getMenuItems();

    if (_user?.role == 'ADMIN') {
      final roles = await _menuService.getAllRoles();
      _allRoles = Map.fromEntries(
        roles.asMap().entries.map((e) => MapEntry(e.key, e.value))
      );
    }
  }
}
