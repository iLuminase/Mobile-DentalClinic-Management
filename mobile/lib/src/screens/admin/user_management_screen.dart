
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/user_service.dart';
import 'package:doanmobile/src/screens/admin/add_edit_user_screen.dart';
import 'package:flutter/material.dart';

// Màn hình quản lý người dùng (dành cho Admin).
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  // Tải lại danh sách người dùng từ server.
  void _refreshUsers() {
    setState(() {
      _usersFuture = _userService.getUsers();
    });
  }

  // Điều hướng đến màn hình thêm/sửa và làm mới lại danh sách nếu có thay đổi.
  void _navigateAndRefresh(User? user) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditUserScreen(user: user),
      ),
    );

    // Nếu màn hình add/edit trả về true (có nghĩa là đã lưu thành công)
    if (result == true) {
      _refreshUsers();
    }
  }

  // Thay đổi trạng thái active/inactive của người dùng.
  void _toggleUserStatus(User user) async {
    final newStatus = !user.isActive;
    final success = await _userService.setUserStatus(user.id, newStatus);

    if (mounted) {
      _showSnackBar(
        context,
        success ? 'Cập nhật trạng thái thành công!' : 'Cập nhật trạng thái thất bại.',
        success ? Colors.green : Colors.red,
      );
      if (success) {
        _refreshUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có người dùng nào.'));
          }

          final users = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshUsers(),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isActive ? Colors.green : Colors.grey,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(user.fullName ?? user.username),
                    subtitle: Text('Role: ${user.role}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateAndRefresh(user);
                        } else if (value == 'toggle_status') {
                          _toggleUserStatus(user);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Sửa & Phân quyền'),
                        ),
                        PopupMenuItem<String>(
                          value: 'toggle_status',
                          child: Text(user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(null), // null để vào chế độ thêm mới
        child: const Icon(Icons.add),
        tooltip: 'Thêm người dùng mới',
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
