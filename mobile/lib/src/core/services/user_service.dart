
import 'dart:convert';
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Xử lý các nghiệp vụ về quản lý người dùng.
class UserService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  final StorageService _storageService = StorageService();

  // Tạo headers chuẩn cho các request (bao gồm token và header chống cache).
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${token ?? ''}',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    };
  }

  // Lấy danh sách tất cả người dùng.
  Future<List<User>> getUsers() async {
    final url = Uri.parse('$_baseUrl/api/users');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((user) => User.fromJson(user)).toList();
      }
      debugPrint('Lỗi lấy danh sách user: ${response.statusCode}');
    } catch (e) {
      debugPrint('Exception khi lấy danh sách user: $e');
    }
    return [];
  }

  // Tạo người dùng mới.
  Future<bool> createUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/api/users');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(userData),
      );
      return response.statusCode == 201; // Created
    } catch (e) {
      debugPrint('Exception khi tạo user: $e');
      return false;
    }
  }

  // Cập nhật thông tin người dùng.
  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/api/users/$userId');
    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(userData),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception khi cập nhật user: $e');
      return false;
    }
  }

  // Cập nhật trạng thái active cho người dùng.
  Future<bool> setUserStatus(String userId, bool isActive) async {
    final url = Uri.parse('$_baseUrl/api/users/$userId/status');
    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'active': isActive}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception khi đổi trạng thái user: $e');
      return false;
    }
  }
}
