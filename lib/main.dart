
import 'package:doanmobile/src/screens/home_page.dart';
import 'package:doanmobile/src/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phòng khám nha khoa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      // Bắt đầu ứng dụng với route '/login'
      initialRoute: '/login',
      // Định nghĩa các routes cho việc điều hướng
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false, // Tắt banner debug
    );
  }
}
