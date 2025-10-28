
import 'package:doanmobile/src/core/providers/auth_provider.dart';
import 'package:doanmobile/src/screens/admin/menu_management_screen.dart';
import 'package:doanmobile/src/screens/admin/user_management_screen.dart';
import 'package:doanmobile/src/screens/placeholder_screen.dart';
import 'package:doanmobile/src/screens/settings_screen.dart';
import 'package:doanmobile/src/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  List<Widget> _getPages(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return [
          const PlaceholderScreen(route: '/dashboard'),
          const UserManagementScreen(),
          const MenuManagementScreen(),
          const SettingsScreen(),
        ];
      case 'RECEPTIONIST':
        return [
          const PlaceholderScreen(route: '/dashboard'),
          const PlaceholderScreen(route: '/appointments/create'),
          const PlaceholderScreen(route: '/reports'),
          const SettingsScreen(),
        ];
      case 'DOCTOR':
        return [
          const PlaceholderScreen(route: '/dashboard'),
          const PlaceholderScreen(route: '/appointments/my-schedule'),
          const PlaceholderScreen(route: '/reports'),
          const SettingsScreen(),
        ];
      default:
        return [
          const PlaceholderScreen(route: '/dashboard'),
          const PlaceholderScreen(route: '/appointments'),
          const PlaceholderScreen(route: '/profile'),
          const SettingsScreen(),
        ];
    }
  }

  List<String> _getPageTitles(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return ['Tổng quan', 'Người dùng', 'Phân quyền Menu', 'Cài đặt'];
      case 'RECEPTIONIST':
        return ['Tổng quan', 'Đặt lịch', 'Báo cáo', 'Cài đặt'];
      case 'DOCTOR':
        return ['Tổng quan', 'Lịch của tôi', 'Báo cáo', 'Cài đặt'];
      default:
        return ['Tổng quan', 'Lịch hẹn', 'Hồ sơ', 'Cài đặt'];
    }
  }

  List<BottomNavigationBarItem> _getNavBarItems(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Người dùng'),
          BottomNavigationBarItem(icon: Icon(Icons.rule_folder), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ];
      case 'RECEPTIONIST':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Đặt lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Báo cáo'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ];
      case 'DOCTOR':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Lịch của tôi'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Báo cáo'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ];
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch hẹn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role ?? 'USER';

    final pages = _getPages(userRole);
    final pageTitles = _getPageTitles(userRole);
    final navBarItems = _getNavBarItems(userRole);

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => authProvider.logout(),
          )
        ],
      ),
      drawer: MainDrawer(onMenuSelected: (route) {
        Navigator.of(context).pushNamed(route);
      }),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: navBarItems,
      ),
    );
  }
}
