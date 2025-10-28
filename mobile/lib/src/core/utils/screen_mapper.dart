
import 'package:doanmobile/src/screens/admin/menu_management_screen.dart';
import 'package:doanmobile/src/screens/admin/user_management_screen.dart';
import 'package:doanmobile/src/screens/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Ánh xạ một đường dẫn (path) hoặc tên component từ API thành một Widget cụ thể.
/// 
/// Đây là trung tâm điều phối của ứng dụng, quyết định màn hình nào
/// sẽ được hiển thị cho một route nhất định.
Widget getScreenForRoute(String path) {
  switch (path) {
    // --- CÁC ROUTE CHÍNH ---
    case '/dashboard':
      return const PlaceholderScreen(route: '/dashboard');
    case '/appointments':
      return const PlaceholderScreen(route: '/appointments');
    
    // --- CÁC ROUTE QUẢN TRỊ ---
    case '/user-management':
      return const UserManagementScreen();
    case '/menu-management':
      return const MenuManagementScreen();
      
    // --- THÊM CÁC ROUTE KHÁC CỦA BẠN Ở ĐÂY ---

    // Màn hình mặc định nếu không tìm thấy route
    default:
      return PlaceholderScreen(route: path);
  }
}
