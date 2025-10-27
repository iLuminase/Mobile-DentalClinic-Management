
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/user_service.dart';
import 'package:flutter/material.dart';

// Màn hình quản lý người dùng
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
    _usersFuture = _userService.getUsers();
  }

  // Hàm để tải lại danh sách người dùng
  void _refreshUsers() {
    setState(() {
      _usersFuture = _userService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          // Trong khi đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Nếu có lỗi
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          // Nếu không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có người dùng nào.'));
          }

          final users = snapshot.data!;

          // Hiển thị danh sách người dùng
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(user.fullName ?? user.username),
                  subtitle: Text('Role: ${user.role}\nEmail: ${user.email ?? 'N/A'}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'reset_password') {
                        _handleResetPassword(context, user.id);
                      } else if (value == 'change_role') {
                        _handleChangeRole(context, user);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'change_role',
                        child: Text('Thay đổi quyền'),
                      ),
                      const PopupMenuItem(
                        value: 'reset_password',
                        child: Text('Cấp lại mật khẩu'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Xử lý logic thay đổi quyền
  void _handleChangeRole(BuildContext context, User user) {
    // TODO: Lấy danh sách roles từ API thay vì hardcode
    const availableRoles = ['ADMIN', 'DOCTOR', 'RECEPTIONIST', 'PENDING_USER'];
    showDialog(
      context: context,
      builder: (ctx) {
        String selectedRole = user.role;
        return AlertDialog(
          title: const Text('Chọn quyền mới'),
          content: DropdownButton<String>(
            value: selectedRole,
            isExpanded: true,
            items: availableRoles.map((String role) {
              return DropdownMenuItem<String>(value: role, child: Text(role));
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                selectedRole = newValue;
              }
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final success = await _userService.updateUserRole(user.id, selectedRole);
                Navigator.of(ctx).pop();
                if (success) {
                  _showSnackBar(context, 'Cập nhật quyền thành công!', Colors.green);
                  _refreshUsers(); // Tải lại danh sách
                } else {
                  _showSnackBar(context, 'Cập nhật quyền thất bại.', Colors.red);
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  // Xử lý logic cấp lại mật khẩu
  void _handleResetPassword(BuildContext context, String userId) async {
    final newPassword = await _userService.resetPassword(userId);
    if (newPassword != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mật khẩu mới'),
          content: Text('Mật khẩu mới của người dùng là: $newPassword'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
    } else {
      _showSnackBar(context, 'Cấp lại mật khẩu thất bại.', Colors.red);
    }
  }

  // Hàm helper để hiển thị SnackBar
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
