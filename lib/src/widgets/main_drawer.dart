
import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/providers/auth_provider.dart';
import 'package:doanmobile/src/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widget Drawer, hiển thị menu động lồng nhau từ API
class MainDrawer extends StatelessWidget {
  final Function(String) onMenuSelected; // Callback để báo cho HomePage biết trang nào được chọn

  const MainDrawer({super.key, required this.onMenuSelected});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    // Lấy cây menu động từ provider
    final menuItems = authProvider.menuItems; 

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.fullName ?? user?.username ?? 'Unknown User'),
            accountEmail: Text(user?.role ?? 'No Role'),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 50),
            ),
          ),
          // Nếu chưa tải xong menu hoặc menu rỗng, hiển thị loading hoặc thông báo
          if (authProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (menuItems.isEmpty)
            const ListTile(title: Text('Không có menu phụ.'))
          else
          // Xây dựng danh sách menu từ cây menu
            ...menuItems.map((item) => _buildMenuItem(context, item)).toList(),
        ],
      ),
    );
  }

  // Hàm đệ quy để xây dựng từng mục menu trong Drawer
  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    // Nếu không có menu con -> ListTile bình thường
    if (item.children.isEmpty) {
      return ListTile(
        leading: Icon(getIconData(item.icon), size: 22),
        title: Text(item.title),
        onTap: () {
          Navigator.of(context).pop(); // Đóng Drawer
          onMenuSelected(item.route); // Thông báo cho HomePage
        },
      );
    } else {
      // Nếu có menu con -> ExpansionTile
      return ExpansionTile(
        leading: Icon(getIconData(item.icon)),
        title: Text(item.title),
        children: item.children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(left: 16.0), // Thụt vào cho các mục con
                  child: _buildMenuItem(context, child), // Gọi đệ quy
                ))
            .toList(),
      );
    }
  }
}
