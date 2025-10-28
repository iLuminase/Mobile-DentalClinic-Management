
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang quản trị'),
        actions: [
          // Nút đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Quay về màn hình đăng nhập và xóa hết các route trước đó
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      // TODO: Thay thế bằng danh sách lịch hẹn thật từ API
      body: ListView.builder(
        itemCount: 5, // Dữ liệu giả
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text('Bệnh nhân ${index + 1}'),
              subtitle: const Text('10:00 - 10:30, 20/07/2024\nKhám tổng quát'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Điều hướng đến chi tiết lịch hẹn
              },
            ),
          );
        },
      ),
    );
  }
}
