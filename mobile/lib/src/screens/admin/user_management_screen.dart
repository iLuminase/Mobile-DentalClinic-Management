import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/user_service.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  late Future<List<User>> _usersFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _userService.getUsers();
    });
  }

  void _showAddEditUserDialog({User? user}) {
    final isEdit = user != null;
    final formKey = GlobalKey<FormState>();

    final usernameController = TextEditingController(text: user?.username ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final fullNameController = TextEditingController(text: user?.fullName ?? '');
    final passwordController = TextEditingController();

    final availableRoles = ['USER', 'VIEWER', 'DOCTOR', 'RECEPTIONIST', 'ADMIN'];
    String selectedRole = user?.role ?? 'USER';
    if (!availableRoles.contains(selectedRole)) {
      selectedRole = 'USER';
    }
    bool isActive = user?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(isEdit ? Icons.edit : Icons.person_add, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(isEdit ? 'Sửa Người Dùng' : 'Thêm Người Dùng'),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                        enabled: !isEdit,
                        validator: (v) => v?.isEmpty ?? true ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!isEdit)
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (v) => v?.isEmpty ?? true ? 'Bắt buộc' : null,
                        ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: Icon(Icons.security),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'USER', child: Text('USER')),
                          DropdownMenuItem(value: 'VIEWER', child: Text('VIEWER')),
                          DropdownMenuItem(value: 'DOCTOR', child: Text('DOCTOR')),
                          DropdownMenuItem(value: 'RECEPTIONIST', child: Text('RECEPTIONIST')),
                          DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                        ],
                        onChanged: (val) {
                          setDialogState(() => selectedRole = val ?? 'USER');
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Kích hoạt'),
                        value: isActive,
                        onChanged: (val) {
                          setDialogState(() => isActive = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton.icon(
                icon: Icon(isEdit ? Icons.save : Icons.add),
                label: Text(isEdit ? 'Cập nhật' : 'Tạo'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  setState(() => _isLoading = true);

                  bool success = false;

                  if (isEdit) {
                    final basicData = {
                      'username': usernameController.text.trim(),
                      'email': emailController.text.trim(),
                      'fullName': fullNameController.text.trim(),
                      'active': isActive,
                    };

                    success = await _userService.updateUser(user!.id, basicData);

                    if (success && selectedRole != user.role) {
                      final roleSuccess = await _userService.updateUserRole(user.id, selectedRole);
                      if (!roleSuccess) {
                        success = false;
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚠️ Cập nhật thông tin thành công nhưng role thất bại'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    }
                  } else {
                    final userData = {
                      'username': usernameController.text.trim(),
                      'email': emailController.text.trim(),
                      'fullName': fullNameController.text.trim(),
                      'role': selectedRole,
                      'active': isActive,
                      'password': passwordController.text,
                    };
                    success = await _userService.createUser(userData);
                  }

                  setState(() => _isLoading = false);

                  if (mounted) {
                    Navigator.of(context).pop();
                    _showSnackBar(
                      success
                          ? '✅ ${isEdit ? "Cập nhật" : "Tạo"} người dùng thành công!'
                          : '❌ ${isEdit ? "Cập nhật" : "Tạo"} người dùng thất bại',
                      success,
                    );
                    if (success) _refreshUsers();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleUserStatus(User user) async {
    setState(() => _isLoading = true);
    final success = await _userService.setUserStatus(user.id, !user.isActive);
    setState(() => _isLoading = false);

    if (mounted) {
      _showSnackBar(
        success
            ? '✅ Cập nhật trạng thái thành công'
            : '❌ Cập nhật trạng thái thất bại',
        success,
      );
      if (success) _refreshUsers();
    }
  }

  void _resetPassword(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Xác nhận reset mật khẩu'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset mật khẩu cho user: ${user.username}?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Lưu ý:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('• Mật khẩu mới: password123'),
                  Text('• User nên đổi mật khẩu ngay'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true);
      final result = await _userService.resetPassword(user.id);
      setState(() => _isLoading = false);

      if (mounted) {
        if (result?['success'] == true) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Reset thành công'),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mật khẩu đã được reset thành công!'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Mật khẩu mới: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: SelectableText(
                            result?['newPassword'] ?? 'password123',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vui lòng gửi mật khẩu này cho user.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        } else {
          _showSnackBar('❌ Reset mật khẩu thất bại', false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người Dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<User>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Lỗi: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                        onPressed: _refreshUsers,
                      ),
                    ],
                  ),
                );
              }

              final users = snapshot.data ?? [];

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Chưa có người dùng nào'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm người dùng đầu tiên'),
                        onPressed: () => _showAddEditUserDialog(),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _refreshUsers(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: users.length,
                  itemBuilder: (context, index) => _buildUserCard(users[index]),
                ),
              );
            },
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditUserDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm User'),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive ? _getRoleColor(user.role) : Colors.grey,
          child: Text(
            (user.fullName ?? user.username).substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.fullName ?? user.username,
                style: TextStyle(
                  color: user.isActive ? null : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!user.isActive)
              const Chip(
                label: Text('Inactive', style: TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user.username}${user.email != null ? " • ${user.email}" : ""}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                user.role,
                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
              ),
              backgroundColor: _getRoleColor(user.role),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showAddEditUserDialog(user: user);
                break;
              case 'toggle':
                _toggleUserStatus(user);
                break;
              case 'reset':
                _resetPassword(user);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Sửa thông tin'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                    color: user.isActive ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.lock_reset, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Reset mật khẩu', style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    final roleUpper = role.toUpperCase();
    if (roleUpper.contains('ADMIN')) return Colors.red;
    if (roleUpper.contains('DOCTOR')) return Colors.blue.shade700;
    if (roleUpper.contains('RECEPTIONIST')) return Colors.green.shade700;
    if (roleUpper.contains('VIEWER')) return Colors.orange.shade700;
    if (roleUpper.contains('USER')) return Colors.purple.shade700;
    return Colors.grey.shade600;
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

