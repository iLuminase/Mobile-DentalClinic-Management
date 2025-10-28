
import 'dart:convert';
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Xử lý các nghiệp vụ về xác thực: đăng nhập, đăng ký, đăng xuất.
class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  final StorageService _storageService = StorageService();

  // Tạo headers chuẩn cho các request (bao gồm token và header chống cache).
  Future<Map<String, String>> _getHeaders([String? token]) async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${token ?? ''}',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    };
  }

  // Đăng ký người dùng mới.
  Future<bool> register(String username, String fullName, String password, String email) async {
    final url = Uri.parse('$_baseUrl/api/auth/register');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(), // Không cần token khi đăng ký
        body: jsonEncode({
          'username': username,
          'fullName': fullName,
          'password': password,
          'email': email,
        }),
      );
      // SỬA LỖI: Chấp nhận cả 200 (OK) hoặc 201 (Created) là thành công.
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Lỗi đăng ký: $e');
      return false;
    }
  }

  // Đăng nhập và trả về đối tượng User nếu thành công.
  Future<User?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(), // Không cần token khi đăng nhập
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['accessToken'];

        if (token != null) {
          await _storageService.saveToken(token);
          // Nguồn thông tin user duy nhất và đáng tin cậy nhất là từ token.
          return _parseJwt(token);
        }
      }
    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
    }
    return null;
  }

  // Đăng xuất.
  Future<void> logout() async {
    await _storageService.deleteToken();
  }

  // Lấy thông tin user từ token đã lưu.
  Future<User?> getLoggedInUser() async {
    final token = await _storageService.getToken();
    if (token != null) {
      return _parseJwt(token);
    }
    return null;
  }

  // Giải mã JWT để lấy thông tin user.
  User? _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      if (payloadMap == null) return null;

      // Luôn sử dụng User.fromJson để tạo đối tượng User.
      return User.fromJson(payloadMap);
    } catch (e) {
      debugPrint("Lỗi giải mã token: $e");
      // Nếu token lỗi, xóa nó đi để tránh bị lặp lại lỗi.
      _storageService.deleteToken();
      return null;
    }
  }
}
