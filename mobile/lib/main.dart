
import 'package:doanmobile/src/core/providers/auth_provider.dart';
import 'package:doanmobile/src/screens/admin/menu_management_screen.dart'; // Import màn hình mới
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
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
      child: MaterialApp(
        title: 'Phòng khám Nha khoa',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const HomePage(),
          '/login': (context) => const LoginScreen(),
          '/pending': (context) => const PendingApprovalScreen(),
          // SỬA LỖI: Thêm route cho màn hình quản lý menu
          '/menu-management': (context) => const MenuManagementScreen(),
        },
        debugShowCheckedModeBanner: false,
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
          auth.tryAutoLogin();
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isAuthenticated) {
          if (auth.user!.role == 'PENDING_USER') {
            return const PendingApprovalScreen();
          } else {
            return const HomePage();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
