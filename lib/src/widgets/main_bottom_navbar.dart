
import 'package:flutter/material.dart';

// Widget cho thanh điều hướng dưới cùng, có thể tái sử dụng
class MainBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNavbar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Đặt lịch',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Hóa đơn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey, // Màu cho các mục không được chọn
      onTap: onTap,
      showUnselectedLabels: true, // Hiển thị label cho các mục không được chọn
      type: BottomNavigationBarType.fixed, // Đảm bảo tất cả các mục đều hiển thị
    );
  }
}
