
import 'package:shared_preferences/shared_preferences.dart';

// Lớp dịch vụ để quản lý việc lưu trữ cục bộ (token, cài đặt, v.v.)
class StorageService {
  // Khóa để lưu token trong SharedPreferences
  static const String _tokenKey = 'auth_token';

  // Lưu token vào SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Lấy token từ SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Xóa token (khi đăng xuất)
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
