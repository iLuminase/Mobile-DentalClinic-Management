
import 'dart:convert';
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  final StorageService _storageService = StorageService();

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

  Future<bool> createUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/api/users');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(userData),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Exception khi tạo user: $e');
      return false;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/api/users/$userId');
    try {
      if (kDebugMode) {
        print('🔄 Updating user $userId with data: $userData');
      }

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(userData),
      );

      if (kDebugMode) {
        print('📊 Update user response: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('❌ Response body: ${response.body}');
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception khi cập nhật user: $e');
      return false;
    }
  }

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

  Future<bool> updateUserRole(String userId, String role) async {
    final url = Uri.parse('$_baseUrl/api/users/$userId/roles');
    try {
      if (kDebugMode) {
        print('🔄 Updating user $userId role to: $role');
      }

      final roleWithPrefix = role.startsWith('ROLE_') ? role : 'ROLE_$role';

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode([roleWithPrefix]),
      );

      if (kDebugMode) {
        print('📊 Update role response: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('❌ Response body: ${response.body}');
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception khi cập nhật role: $e');
      return false;
    }
  }

  Future<bool> changePassword(String userId, Map<String, dynamic> passwordData) async {
    final url = Uri.parse('$_baseUrl/api/users/$userId/change-password');
    try {
      if (kDebugMode) {
        print('🔄 Changing password for user $userId');
      }

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(passwordData),
      );

      if (kDebugMode) {
        print('📊 Change password response: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('❌ Response body: ${response.body}');
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception khi đổi mật khẩu: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> resetPassword(String userId) async {
    final url = Uri.parse('$_baseUrl/api/users/$userId/reset-password');
    try {
      if (kDebugMode) {
        print('🔄 Resetting password for user $userId');
      }

      final response = await http.put(
        url,
        headers: await _getHeaders(),
      );

      if (kDebugMode) {
        print('📊 Reset password response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'newPassword': data['newPassword'] ?? 'password123',
          'message': data['message'] ?? 'Password reset successfully',
        };
      } else {
        if (kDebugMode) {
          print('❌ Response body: ${response.body}');
        }
        return {
          'success': false,
          'message': 'Failed to reset password',
        };
      }
    } catch (e) {
      debugPrint('Exception khi reset mật khẩu: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
