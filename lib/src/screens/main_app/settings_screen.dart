
import 'package:flutter/material.dart';

// Màn hình Cài đặt (Placeholder)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: const Center(
        child: Text('Giao diện cài đặt sẽ ở đây', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
