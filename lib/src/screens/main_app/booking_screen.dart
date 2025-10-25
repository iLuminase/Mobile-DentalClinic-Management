
import 'package:flutter/material.dart';

// Màn hình Đặt lịch (Placeholder)
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch hẹn')),
      body: const Center(
        child: Text('Giao diện đặt lịch hẹn sẽ ở đây', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
