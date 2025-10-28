
import 'package:doanmobile/src/core/providers/auth_provider.dart';
import 'package:doanmobile/src/screens/auth/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // SỬA LỖI: Lấy chuỗi lỗi trả về từ provider
    final errorMessage = await authProvider.login(
      _usernameController.text,
      _passwordController.text,
    );

    // Nếu có chuỗi lỗi, hiển thị nó ra.
    if (errorMessage != null && mounted) {
      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thông báo'), // Đổi tiêu đề cho thân thiện hơn
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
              ),
              const SizedBox(height: 20),
              authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _login(authProvider),
                      child: const Text('Đăng nhập'),
                    ),
              TextButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                  );
                },
                child: const Text('Chưa có tài khoản? Đăng ký ngay'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
