
import 'package:doanmobile/src/core/providers/auth_provider.dart';
import 'package:doanmobile/src/screens/auth/login_screen.dart';
import 'package:doanmobile/src/screens/home_page.dart';
import 'package:doanmobile/src/screens/main_app/pending_approval_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng ChangeNotifierProvider để cung cấp AuthProvider cho toàn bộ cây widget
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
      child: MaterialApp(
        title: 'Phòng khám Nha khoa',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(), // Màn hình điều hướng chính
        routes: {
          '/home': (context) => const HomePage(),
          '/login': (context) => const LoginScreen(),
          '/pending':(context) => const PendingApprovalScreen(),
        },
        debugShowCheckedModeBanner: false, // tắt debug banner
      ),
    );
  }
}

// Widget này quyết định màn hình nào sẽ được hiển thị khi khởi động
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isInitialized) {
           // Nếu chưa khởi tạo xong, thử tự động đăng nhập
          auth.tryAutoLogin();
          // và hiển thị màn hình chờ
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nếu đã đăng nhập
        if (auth.isAuthenticated) {
          // Nếu là user đang chờ duyệt
          if (auth.user!.role == 'PENDING_USER') {
            return const PendingApprovalScreen();
          } else {
            // Nếu có quyền hợp lệ, vào trang chủ
            return const HomePage();
          }
        } else {
          // Nếu chưa đăng nhập, hiển thị màn hình đăng nhập
          return const LoginScreen();
        }
      },
    );
  }
}
