
import 'package:doanmobile/src/core/providers/auth_provider.dart';
import 'package:doanmobile/src/screens/admin/menu_management_screen.dart';
import 'package:doanmobile/src/screens/admin/user_management_screen.dart';
import 'package:doanmobile/src/screens/main_app/appointment_screen.dart';
import 'package:doanmobile/src/screens/main_app/invoice_screen.dart';
import 'package:doanmobile/src/screens/main_app/payment_screen.dart';
import 'package:doanmobile/src/screens/main_app/settings_screen.dart';
import 'package:doanmobile/src/screens/placeholder_screen.dart';
import 'package:doanmobile/src/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Trang chủ chính, sử dụng BottomNavigationBar tĩnh và Drawer động
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Danh sách các trang CỐ ĐỊNH cho BottomNavigationBar
  final List<Widget> _staticPages = [
    const AppointmentScreen(),
    const PaymentScreen(),
    const InvoiceScreen(),
    const SettingsScreen(), // hoặc giữ nguyên MenuManagementScreen
  ];

  final List<String> pageTitles = ['Lịch hẹn', 'Thanh toán', 'Hóa đơn', 'Cài đặt'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index); // Chuyển trang
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy tiêu đề cho AppBar
    final List<String> pageTitles = ['Tổng quan', 'Lịch hẹn', 'Người dùng', 'Cài đặt'];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          )
        ],
      ),
      // Drawer sẽ chứa menu động từ API
      drawer: MainDrawer(onMenuSelected: (route) {
        // TODO: Xử lý điều hướng từ Drawer nếu cần
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Điều hướng tới $route")));
      }),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _staticPages,
      ),
      // BottomNavigationBar tĩnh, luôn hiển thị
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch hẹn'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Người dùng'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
