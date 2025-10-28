
import 'package:flutter/material.dart';

// Màn hình giữ chỗ cho các chức năng chưa được triển khai
class PlaceholderScreen extends StatelessWidget {
  final String route;

  const PlaceholderScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Màn hình cho route: $route\nChức năng này đang được phát triển.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
