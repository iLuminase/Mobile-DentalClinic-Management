import 'package:flutter/material.dart';
import 'calendar_page.dart'; // thêm dòng này để import trang lịch

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Chào mừng bạn đến với ứng dụng Quản lý lịch hẹn nha khoa!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: const Text('Hôm nay có 3 khách hẹn khám răng'),
              subtitle: const Text('Bấm vào tab “Lịch” để xem chi tiết'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_hospital, color: Colors.teal),
              title: const Text('Thông tin phòng khám'),
              subtitle: const Text('123 Nguyễn Trãi, Hà Nội\nHotline: 0909 888 999'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
