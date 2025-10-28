
import 'package:flutter/material.dart';

// Màn hình Hóa đơn (Placeholder)
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn')),
      body: const Center(
        child: Text('Giao diện quản lý hóa đơn sẽ ở đây', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
