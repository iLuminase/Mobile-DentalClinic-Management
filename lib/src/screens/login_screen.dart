
import 'package:flutter/material.dart';

// Màn hình đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Global key để validate form
  final _formKey = GlobalKey<FormState>();
  
  // Controller cho các trường text với giá trị mặc định để debug
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');

  // Biến để hiển thị/ẩn mật khẩu
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhấn nút đăng nhập
  void _login() {
    // Validate form, dù có giá trị mặc định, người dùng vẫn có thể xóa nó
    if (_formKey.currentState!.validate()) {
      // Lấy tên người dùng và mật khẩu từ controller
      final username = _usernameController.text;
      final password = _passwordController.text;
      
      // TODO: Gọi API đăng nhập ở đây

      print('Username: $username');
      print('Password: $password');
      
      // Giả sử đăng nhập thành công, chuyển đến trang chủ
      // dùng pushReplacementNamed để người dùng không thể back lại trang đăng nhập
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trường nhập tên người dùng
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person), // Đổi icon cho phù hợp
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên người dùng';
                  }
                  return null; // Bỏ kiểm tra định dạng email
                },
              ),
              const SizedBox(height: 16.0),
              // Trường nhập mật khẩu
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              // Nút đăng nhập
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
