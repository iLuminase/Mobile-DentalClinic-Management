
import 'dart:convert';
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  static const String _loginEndpoint = '/api/auth/login';

  final StorageService _storageService = StorageService();

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
        final token = responseBody['accessToken']; // SỬA 1: Đọc đúng key 'accessToken'

        if (token != null) {
          await _storageService.saveToken(token);

          // SỬA 2: Lấy thông tin user trực tiếp từ response thay vì parse token
          final userMap = responseBody['user'];
          if (userMap != null) {
            List<dynamic> roles = userMap['roles'] ?? [];
            String role = 'PENDING_USER';
            if (roles.isNotEmpty) {
              // Lấy role đầu tiên và xóa tiền tố "ROLE_"
              role = (roles.first as String).replaceAll('ROLE_', '');
            }

            final user = User(
              id: userMap['id']?.toString() ?? '',
              username: userMap['username'] ?? '',
              role: role,
            );

            debugPrint('Đăng nhập thành công cho role: ${user.role}');
            return user;
          }
        }
      }
      debugPrint('Đăng nhập thất bại: ${response.body}');
      return null;

    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }

  Future<User?> getLoggedInUser() async {
    final token = await _storageService.getToken();
    if (token != null) {
      return _parseJwt(token);
    }
    return null;
  }

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

    // SỬA 3: Xử lý đúng cấu trúc role từ JWT
    List<dynamic> roles = payloadMap['roles'] ?? [];
    String role = 'PENDING_USER';
    if (roles.isNotEmpty) {
      role = (roles.first as String).replaceAll('ROLE_', '');
    }

    return User(
      id: payloadMap['sub'] ?? '', // Lấy ID từ 'sub' claim nếu có
      username: payloadMap['sub'] ?? '',
      role: role,
    );
  }
}
