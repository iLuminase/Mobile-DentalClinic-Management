import 'dart:convert';
import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MenuService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api';
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

  void _debugResponse(String endpoint, http.Response response) {
    if (kDebugMode) {
      print('🌐 $endpoint → ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ ${response.body}');
      }
    }
  }

  Future<List<MenuItem>> getMenuItems() async {
    final url = Uri.parse('$_baseUrl/menus/me');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      _debugResponse('GET /menus/me', response);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((json) => MenuItem.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('❌ Lỗi lấy menu: $e');
    }
    return [];
  }

  Future<List<MenuItem>> getAllMenusForAdmin() async {
    final url = Uri.parse('$_baseUrl/menus/all-for-management');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      _debugResponse('GET /menus/all-for-management', response);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((json) => MenuItem.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('❌ Lỗi lấy menu admin: $e');
    }
    return [];
  }

  Future<MenuItem?> getMenuById(int menuId) async {
    final url = Uri.parse('$_baseUrl/menus/$menuId');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return MenuItem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint('❌ Lỗi lấy menu $menuId: $e');
    }
    return null;
  }

  Future<List<String>> getAllRoles() async {
    final url = Uri.parse('$_baseUrl/roles');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      _debugResponse('GET /roles', response);

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<String> roles = [];
        if (jsonResponse is List) {
          roles = jsonResponse.map<String>((role) {
            if (role is String) return role;
            if (role is Map && role.containsKey('name')) return role['name'].toString();
            return role.toString();
          }).toList();
        }
        return roles;
      }
    } catch (e) {
      debugPrint('❌ Lỗi lấy roles: $e');
    }
    return [];
  }

  Future<bool> updateMenuRoles(int menuId, List<String> roleNames) async {
    final url = Uri.parse('$_baseUrl/menus/$menuId/roles');
    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'roleNames': roleNames}),
      );
      _debugResponse('PUT /menus/$menuId/roles', response);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Lỗi update menu roles: $e');
      return false;
    }
  }

  Future<MenuItem?> createMenu(Map<String, dynamic> menuData) async {
    final url = Uri.parse('$_baseUrl/menus');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(menuData),
      );
      _debugResponse('POST /menus', response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return MenuItem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint('❌ Lỗi tạo menu: $e');
    }
    return null;
  }

  Future<MenuItem?> updateMenu(int menuId, Map<String, dynamic> menuData) async {
    final url = Uri.parse('$_baseUrl/menus/$menuId');
    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(menuData),
      );
      _debugResponse('PUT /menus/$menuId', response);

      if (response.statusCode == 200) {
        return MenuItem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint('❌ Lỗi update menu: $e');
    }
    return null;
  }

  Future<bool> deleteMenu(int menuId) async {
    final url = Uri.parse('$_baseUrl/menus/$menuId');
    try {
      final response = await http.delete(url, headers: await _getHeaders());
      _debugResponse('DELETE /menus/$menuId', response);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Lỗi xóa menu: $e');
      return false;
    }
  }

  Future<bool> toggleMenuActive(int menuId) async {
    final url = Uri.parse('$_baseUrl/menus/$menuId/toggle-active');
    try {
      final response = await http.patch(url, headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Lỗi toggle menu: $e');
      return false;
    }
  }

  Future<List<MenuItem>> getFlatMenuList() async {
    final menus = await getAllMenusForAdmin();
    final flatList = <MenuItem>[];
    for (final menu in menus) {
      flatList.addAll(menu.toFlatList());
    }
    return flatList;
  }

  Future<List<MenuItem>> getParentMenuCandidates({int? excludeId}) async {
    final allMenus = await getFlatMenuList();
    return allMenus.where((menu) {
      if (excludeId != null && menu.id == excludeId) return false;
      return menu.depth < 2;
    }).toList();
  }
}

