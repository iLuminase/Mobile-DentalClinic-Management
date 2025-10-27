
import 'dart:convert';
import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Service để xử lý các nghiệp vụ liên quan đến menu
class MenuService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  final StorageService _storageService = StorageService();

  // Lấy danh sách menu cho người dùng hiện tại (đã phân quyền bởi backend)
  Future<List<MenuItem>> getMenuItems() async {
    final token = await _storageService.getToken();
    if (token == null) return [];
    final url = Uri.parse('$_baseUrl/api/menus'); // Endpoint này trả về menu theo role
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((item) => MenuItem.fromJson(item)).toList();
      } else {
        debugPrint('Lấy menu thất bại: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Lỗi mạng khi lấy menu: $e');
      return [];
    }
  }

  // Lấy TẤT CẢ menu để quản lý (dành cho Admin)
  Future<List<MenuItem>> getAllMenusForManagement() async {
    final token = await _storageService.getToken();
    if (token == null) return [];
    // Giả sử có một endpoint riêng để lấy tất cả menu cho admin
    final url = Uri.parse('$_baseUrl/api/menus/all'); 
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((item) => MenuItem.fromJson(item)).toList();
      } else {
        debugPrint('Lấy tất cả menu thất bại: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Lỗi mạng khi lấy tất cả menu: $e');
      return [];
    }
  }

  // Cập nhật quyền cho một menu
  Future<bool> updateMenuRoles(String menuId, List<String> newRoles) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/api/menus/$menuId/roles');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // Gửi danh sách roles mới, có thêm tiền tố "ROLE_"
        body: jsonEncode({'roles': newRoles.map((r) => 'ROLE_$r').toList()}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Lỗi khi cập nhật menu roles: $e');
      return false;
    }
  }
}
