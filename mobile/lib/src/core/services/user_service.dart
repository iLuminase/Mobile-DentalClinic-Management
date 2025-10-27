
import 'dart:convert';
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Service để xử lý các nghiệp vụ liên quan đến quản lý người dùng
class UserService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  final StorageService _storageService = StorageService();

  // Lấy danh sách tất cả người dùng (yêu cầu quyền Admin)
  Future<List<User>> getUsers() async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/api/users');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((user) => User.fromJson(user)).toList();
      } else {
        debugPrint('Lấy danh sách user thất bại: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách user: $e');
      return [];
    }
  }

  // Cập nhật quyền cho người dùng (yêu cầu quyền Admin)
  Future<bool> updateUserRole(String userId, String newRole) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/api/users/$userId/role');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'role': newRole}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Lỗi khi cập nhật role: $e');
      return false;
    }
  }

  // Cấp lại mật khẩu cho người dùng (yêu cầu quyền Admin)
  Future<String?> resetPassword(String userId) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/api/users/$userId/reset-password');

    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        // Giả sử API trả về mật khẩu mới trong body
        final responseBody = jsonDecode(response.body);
        return responseBody['newPassword'];
      } else {
         debugPrint('Lỗi cấp lại mật khẩu: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi cấp lại mật khẩu: $e');
      return null;
    }
  }
}
