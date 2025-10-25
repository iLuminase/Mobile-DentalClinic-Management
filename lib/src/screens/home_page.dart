
import 'package:doanmobile/src/screens/main_app/booking_screen.dart';
import 'package:doanmobile/src/screens/main_app/dashboard_screen.dart';
import 'package:doanmobile/src/screens/main_app/invoices_screen.dart';
import 'package:doanmobile/src/screens/main_app/settings_screen.dart';
import 'package:doanmobile/src/widgets/main_bottom_navbar.dart';
import 'package:flutter/material.dart';

// Màn hình chính của ứng dụng, quản lý các trang con và thanh điều hướng
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index của tab đang được chọn
  int _selectedIndex = 0;

  // Danh sách các trang (widget) tương ứng với mỗi tab
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    BookingScreen(),
    InvoicesScreen(),
    SettingsScreen(),
  ];

  // Hàm được gọi khi người dùng chọn một tab, cập nhật lại trạng thái
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body sẽ hiển thị trang tương ứng với tab được chọn
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      // Sử dụng widget BottomNavigationBar
      bottomNavigationBar: MainBottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
