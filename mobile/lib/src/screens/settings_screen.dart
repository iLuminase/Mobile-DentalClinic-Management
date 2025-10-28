import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/providers/auth_provider.dart';
import 'package:doanmobile/src/core/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  bool _isLoading = false;

  void _showEditProfileDialog(User user) {
    final formKey = GlobalKey<FormState>();

    final fullNameController = TextEditingController(text: user.fullName ?? '');
    final emailController = TextEditingController(text: user.email ?? '');
    final phoneController = TextEditingController(text: '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Chỉnh sửa thông tin'),
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
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (!v.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
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
            icon: const Icon(Icons.save),
            label: const Text('Lưu'),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              setState(() => _isLoading = true);

              final userData = {
                'fullName': fullNameController.text.trim(),
                'email': emailController.text.trim(),
                'phone': phoneController.text.trim(),
              };

              final success = await _userService.updateUser(user.id, userData);

              setState(() => _isLoading = false);

              if (mounted) {
                Navigator.of(context).pop();
                _showSnackBar(
                  success
                      ? '✅ Cập nhật thông tin thành công!'
                      : '❌ Cập nhật thông tin thất bại',
                  success,
                );

                if (success) {
                  Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(User user) {
    final formKey = GlobalKey<FormState>();

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.lock, color: Colors.orange),
                SizedBox(width: 8),
                Text('Đổi mật khẩu'),
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
                        controller: currentPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu hiện tại',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setDialogState(() => obscureCurrentPassword = !obscureCurrentPassword);
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: obscureCurrentPassword,
                        validator: (v) => v?.isEmpty ?? true ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setDialogState(() => obscureNewPassword = !obscureNewPassword);
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: obscureNewPassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Bắt buộc';
                          if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu mới',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setDialogState(() => obscureConfirmPassword = !obscureConfirmPassword);
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: obscureConfirmPassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Bắt buộc';
                          if (v != newPasswordController.text) return 'Mật khẩu không khớp';
                          return null;
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
                icon: const Icon(Icons.save),
                label: const Text('Đổi mật khẩu'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  setState(() => _isLoading = true);

                  final passwordData = {
                    'currentPassword': currentPasswordController.text,
                    'newPassword': newPasswordController.text,
                  };

                  final success = await _userService.changePassword(user.id, passwordData);

                  setState(() => _isLoading = false);

                  if (mounted) {
                    Navigator.of(context).pop();
                    _showSnackBar(
                      success
                          ? '✅ Đổi mật khẩu thành công!'
                          : '❌ Đổi mật khẩu thất bại',
                      success,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Center(
        child: Text('Không tìm thấy thông tin người dùng'),
      );
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileCard(user),
            const SizedBox(height: 16),
            _buildSettingsSection(user),
            const SizedBox(height: 16),
            _buildAboutSection(),
          ],
        ),

        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildProfileCard(User user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: _getRoleColor(user.role),
              child: Text(
                (user.fullName ?? user.username).substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName ?? user.username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                user.role,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: _getRoleColor(user.role),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.account_circle, 'Username', user.username),
            if (user.email != null && user.email!.isNotEmpty)
              _buildInfoRow(Icons.email, 'Email', user.email!),
            _buildInfoRow(
              user.isActive ? Icons.check_circle : Icons.cancel,
              'Trạng thái',
              user.isActive ? 'Đang hoạt động' : 'Không hoạt động',
              valueColor: user.isActive ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(User user) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('Chỉnh sửa thông tin'),
            subtitle: const Text('Cập nhật họ tên, email, số điện thoại'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditProfileDialog(user),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.orange),
            title: const Text('Đổi mật khẩu'),
            subtitle: const Text('Thay đổi mật khẩu đăng nhập'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(user),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.purple),
            title: const Text('Thông báo'),
            subtitle: const Text('Cài đặt thông báo'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                _showSnackBar('Chức năng đang phát triển', false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text('Về ứng dụng'),
            subtitle: Text('Dental Clinic Management v1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.green),
            title: const Text('Trợ giúp'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showSnackBar('Chức năng đang phát triển', false);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.policy, color: Colors.orange),
            title: const Text('Chính sách & Điều khoản'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showSnackBar('Chức năng đang phát triển', false);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Provider.of<AuthProvider>(context, listen: false).logout();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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

