
import 'dart:convert';
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/*
  VÍ DỤ JSON RESPONSE TỪ API /api/auth/login:
  {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsInJvbGUiOiJBRE1JTiIsImlkIjoiMSJ9.abcde...",
    "id": "1",
    "username": "admin",
    "role": "ADMIN"
  }
*/

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  static const String _loginEndpoint = '/api/auth/login';

  final StorageService _storageService = StorageService();

  // Hàm đăng nhập, trả về User nếu thành công, null nếu thất bại
  Future<User?> login(String username, String password) async {
    final url = Uri.parse(_baseUrl + _loginEndpoint);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];

        if (token != null) {
          // Lưu token
          await _storageService.saveToken(token);
          // Parse thông tin user từ token
          final user = _parseJwt(token);
          debugPrint('Đăng nhập thành công cho role: ${user.role}');
          return user;
        } 
      }
      debugPrint('Đăng nhập thất bại: ${response.body}');
      return null;

    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
      return null;
    }
  }

  // Đăng xuất: Xóa token đã lưu
  Future<void> logout() async {
    await _storageService.deleteToken();
  }

  // Kiểm tra user đã đăng nhập khi khởi động app
  Future<User?> getLoggedInUser() async {
    final token = await _storageService.getToken();
    if (token != null) {
      // Nếu có token, parse nó để lấy thông tin user
      return _parseJwt(token);
    }
    return null;
  }

  // Hàm helper để parse JWT và trích xuất thông tin user
  User _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token không hợp lệ');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);

    if (payloadMap == null) {
      throw Exception('Payload không hợp lệ');
    }

    // Giả định payload có chứa các key 'id', 'sub' (username), và 'role'
    return User(
      id: payloadMap['id'] ?? '',
      username: payloadMap['sub'] ?? '',
      role: payloadMap['role'] ?? 'PENDING_USER',
    );
  }
}
