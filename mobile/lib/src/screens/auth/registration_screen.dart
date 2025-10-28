
import 'package:doanmobile/src/core/services/auth_service.dart';
import 'package:flutter/material.dart';

// Màn hình đăng ký tài khoản mới.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Xử lý khi nhấn nút Đăng ký.
  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.register(
      _usernameController.text,
      _fullNameController.text,
      _passwordController.text,
      _emailController.text,
    );

    if (mounted) {
      if (success) {
        // Hiển thị dialog thông báo thành công và quay về màn hình đăng nhập.
        showDialog(
          context: context,
          barrierDismissible: false, // Người dùng phải nhấn nút OK.
          builder: (ctx) => AlertDialog(
            title: const Text('Đăng ký thành công!'),
            content: const Text('Tài khoản của bạn đã được tạo và đang chờ quản trị viên phê duyệt. Vui lòng quay lại sau.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Đóng dialog.
                  Navigator.of(context).pop(); // Quay về màn hình đăng nhập.
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Hiển thị SnackBar thông báo thất bại.
        _showSnackBar(context, 'Đăng ký thất bại. Tên đăng nhập hoặc email có thể đã tồn tại.', Colors.red);
      }
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Tên đăng nhập (*)'),
                validator: (val) => (val?.isEmpty ?? true) ? 'Tên đăng nhập không được để trống' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Họ và Tên (*)'),
                validator: (val) => (val?.isEmpty ?? true) ? 'Họ và tên không được để trống' : null,
              ),
               const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (*)'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => (val?.isEmpty ?? true) || !val!.contains('@') ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu (*)'),
                obscureText: true,
                validator: (val) => (val?.length ?? 0) < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu (*)'),
                obscureText: true,
                validator: (val) => val != _passwordController.text ? 'Mật khẩu không khớp' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Đăng ký'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
