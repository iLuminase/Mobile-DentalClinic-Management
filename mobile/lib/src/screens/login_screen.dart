
import 'package:doanmobile/src/services/auth_service.dart';
import 'package:flutter/material.dart';

// Màn hình đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key để validate form
  final _formKey = GlobalKey<FormState>();
  
  // Controller cho các trường text với giá trị mặc định để debug
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');
  
  // Service xử lý logic đăng nhập
  final _authService = AuthService();

  // Trạng thái loading để hiển thị trên button
  bool _isLoading = false;

  // Biến để hiển thị/ẩn mật khẩu
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhấn nút đăng nhập
  Future<void> _login() async {
    // Kiểm tra validation của form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Cập nhật giao diện để hiển thị loading
    setState(() {
      _isLoading = true;
    });

    try {
      final username = _usernameController.text;
      final password = _passwordController.text;

      // Gọi service để đăng nhập
      final success = await _authService.login(username, password);

      // Kiểm tra widget còn tồn tại trước khi thao tác với context
      if (!mounted) return;

      if (success != null) {
        // Đăng nhập thành công, chuyển đến trang chủ
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Đăng nhập thất bại, hiển thị SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Xử lý các lỗi không mong muốn và hiển thị thông báo
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Dừng hiển thị loading sau khi có kết quả
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên người dùng';
                  }
                  return null;
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
                onPressed: _isLoading ? null : _login, // Vô hiệu hóa nút khi đang tải
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white) // Hiển thị loading
                    : const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
