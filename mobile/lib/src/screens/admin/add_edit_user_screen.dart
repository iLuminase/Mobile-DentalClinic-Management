
import 'package:doanmobile/src/core/models/user_model.dart';
import 'package:doanmobile/src/core/services/user_service.dart';
import 'package:flutter/material.dart';

// Màn hình để Thêm hoặc Sửa thông tin người dùng.
class AddEditUserScreen extends StatefulWidget {
  final User? user; // user == null -> Thêm mới, user != null -> Sửa

  const AddEditUserScreen({super.key, this.user});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  bool _isLoading = false;

  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  String _selectedRole = 'DOCTOR';
  final List<String> _assignableRoles = ['ADMIN', 'DOCTOR', 'RECEPTIONIST'];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _fullNameController = TextEditingController(text: widget.user?.fullName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();

    if (widget.user != null) {
      if (_assignableRoles.contains(widget.user!.role)) {
        _selectedRole = widget.user!.role;
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhấn nút "Lưu lại"
  void _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Chuẩn bị dữ liệu cơ bản
    final Map<String, dynamic> userData = {
      'username': _usernameController.text,
      'fullName': _fullNameController.text,
      'email': _emailController.text,
    };

    if (_passwordController.text.isNotEmpty) {
      userData['password'] = _passwordController.text;
    }

    bool success = false;
    if (widget.user == null) {
      // **THÊM MỚI**: Không gửi role, để backend tự gán ROLE_PENDING_USER.
      success = await _userService.createUser(userData);
    } else {
      // **CẬP NHẬT**: Gửi role đã chọn với tiền tố "ROLE_".
      userData['roleNames'] = ['ROLE_$_selectedRole'];
      success = await _userService.updateUser(widget.user!.id, userData);
    }

    if (mounted) {
      _showSnackBar(context, success ? 'Lưu thành công!' : 'Lưu thất bại.', success ? Colors.green : Colors.red);
      if (success) {
        Navigator.of(context).pop(true); // Trả về true để báo hiệu cần làm mới
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa & Phân quyền' : 'Thêm người dùng mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Tên đăng nhập (*)'),
                validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Họ và Tên (*)'),
                 validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (*)'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => (val?.isEmpty ?? true) || !val!.contains('@') ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: isEditMode ? 'Mật khẩu mới (bỏ trống nếu không đổi)' : 'Mật khẩu (*)'),
                obscureText: true,
                validator: (val) => !isEditMode && (val?.isEmpty ?? true) ? 'Không được để trống' : null,
              ),
              if (isEditMode) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Phân quyền (*)'),
                  items: _assignableRoles.map((String role) {
                    return DropdownMenuItem<String>(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() => _selectedRole = newValue);
                    }
                  },
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Lưu lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
