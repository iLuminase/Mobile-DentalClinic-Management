
import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/auth_service.dart';
import 'package:doanmobile/src/core/services/menu_service.dart';
import 'package:flutter/material.dart';

// Provider để quản lý trạng thái xác thực và dữ liệu người dùng
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final MenuService _menuService = MenuService();

  User? _user;
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  User? get user => _user;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    final user = await _authService.login(username, password);
    _setLoading(false);

    if (user != null) {
      _user = user;
      if (user.role != 'PENDING_USER') {
        await _loadMenuItems();
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _menuItems = [];
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final user = await _authService.getLoggedInUser();
    if (user != null) {
      _user = user;
      if (user.role != 'PENDING_USER') {
        await _loadMenuItems();
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  // Tải và xây dựng cây menu
  Future<void> _loadMenuItems() async {
    // SỬA LỖI: Chỉ cần gán kết quả trực tiếp.
    // MenuService đã trả về danh sách menu đã được lọc và xây dựng thành cây.
    _menuItems = await _menuService.getMenuItems();
    notifyListeners(); // Thông báo cho UI sau khi menu được tải
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
