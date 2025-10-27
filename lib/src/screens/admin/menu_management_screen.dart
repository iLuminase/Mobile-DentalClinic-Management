
import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/services/menu_service.dart';
import 'package:flutter/material.dart';

// Màn hình quản lý phân quyền menu cho Admin
class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final MenuService _menuService = MenuService();
  late Future<List<MenuItem>> _menuTreeFuture;

  @override
  void initState() {
    super.initState();
    _menuTreeFuture = _menuService.getAllMenusForManagement();
  }

  // Hàm tải lại cây menu
  void _refreshMenus() {
    setState(() {
      _menuTreeFuture = _menuService.getAllMenusForManagement();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<MenuItem>>(
        future: _menuTreeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không thể tải dữ liệu menu.'));
          }

          final menuTree = snapshot.data!;
          // Hiển thị cây menu trong một ListView
          return ListView(children: menuTree.map((item) => _buildMenuTile(item)).toList());
        },
      ),
    );
  }

  // Hàm đệ quy để xây dựng từng mục menu
  Widget _buildMenuTile(MenuItem item) {
    // ListTile cho từng mục menu, có subtitle hiển thị các role được gán
    final tile = ListTile(
      title: Text(item.title),
      subtitle: Text('Quyền: ${item.roles.join(', ')}', style: const TextStyle(color: Colors.blueGrey)),
      onTap: () => _showEditRolesDialog(context, item), // Mở dialog khi nhấn vào
    );

    if (item.children.isEmpty) {
      return tile; // Nếu không có con, trả về ListTile
    } else {
      // Nếu có con, trả về ExpansionTile
      return ExpansionTile(
        title: tile.title!,
        subtitle: tile.subtitle,
        leading: Icon(Icons.folder_open),
        children: item.children.map((child) {
          // Thêm Padding để thụt vào cho các mục con
          return Padding(padding: const EdgeInsets.only(left: 16.0), child: _buildMenuTile(child));
        }).toList(),
      );
    }
  }

  // Hiển thị dialog để chỉnh sửa quyền
  void _showEditRolesDialog(BuildContext context, MenuItem item) {
    // TODO: Lấy danh sách roles từ API thay vì hardcode
    const allAvailableRoles = ['ADMIN', 'DOCTOR', 'RECEPTIONIST'];
    List<String> selectedRoles = List.from(item.roles);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder( // Dùng StatefulBuilder để cập nhật UI trong dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Chỉnh sửa quyền cho "${item.title}"'),
              content: Wrap(
                spacing: 8.0,
                children: allAvailableRoles.map((role) {
                  return FilterChip(
                    label: Text(role),
                    selected: selectedRoles.contains(role),
                    onSelected: (isSelected) {
                      setDialogState(() {
                        if (isSelected) {
                          selectedRoles.add(role);
                        } else {
                          selectedRoles.remove(role);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    final success = await _menuService.updateMenuRoles(item.id, selectedRoles);
                    Navigator.of(ctx).pop();
                    if (success) {
                      _showSnackBar(context, 'Cập nhật thành công!', Colors.green);
                      _refreshMenus(); // Tải lại cây menu để thấy thay đổi
                    } else {
                      _showSnackBar(context, 'Cập nhật thất bại.', Colors.red);
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // Hàm helper để hiển thị SnackBar
  void _showSnackBar(BuildContext context, String message, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
}
