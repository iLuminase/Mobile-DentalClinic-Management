
import 'package:flutter/material.dart';

import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/auth_service.dart';
import 'package:doanmobile/src/core/services/menu_service.dart';

// Quản lý trạng thái xác thực, thông tin người dùng và menu điều hướng.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final MenuService _menuService = MenuService();

  User? _user;
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _user;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _user!.role != 'PENDING_USER';
  bool get isInitialized => _isInitialized;

  // Cố gắng đăng nhập tự động khi khởi động ứng dụng.
  Future<void> tryAutoLogin() async {
    try {
      final user = await _authService.getLoggedInUser();
      if (user != null) {
        // Nếu user đang chờ duyệt, không đăng nhập và xóa token.
        if (user.role == 'PENDING_USER') {
          await _authService.logout();
          _user = null;
        } else {
          _user = user;
          await _loadMenuItems();
        }
      }
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Xử lý đăng nhập, trả về null nếu thành công, hoặc chuỗi lỗi nếu thất bại.
  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(username, password);

      if (user == null) {
        return 'Đăng nhập thất bại. Vui lòng kiểm tra lại tên đăng nhập và mật khẩu.';
      }

      // SỬA LỖI: Kiểm tra role PENDING_USER
      if (user.role == 'PENDING_USER') {
        // Không cấp quyền truy cập, xóa token và thông báo.
        await _authService.logout();
        _user = null;
        return 'Tài khoản của bạn đã được tạo và đang chờ quản trị viên phê duyệt.';
      }

      // Đăng nhập thành công
      _user = user;
      await _loadMenuItems();
      return null; // Thành công
    } catch (e) {
      debugPrint("Lỗi trong AuthProvider.login: $e");
      return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xử lý đăng xuất.
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _menuItems = [];
    notifyListeners();
  }

  Future<void> _loadMenuItems() async {
    _menuItems = await _menuService.getMenuItems();
  }
}
