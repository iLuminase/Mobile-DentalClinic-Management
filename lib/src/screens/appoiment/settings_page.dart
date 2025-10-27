import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Ngôn ngữ'),
            subtitle: Text('Tiếng Việt'),
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Chủ đề'),
            subtitle: Text('Màu teal'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Phiên bản'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
