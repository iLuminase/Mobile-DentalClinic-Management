import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/providers/auth_provider.dart';
import 'package:doanmobile/src/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanmobile/src/screens/main_app/booking_calendar_screen.dart';
import 'package:doanmobile/src/screens/main_app/booking_screen.dart';

class MainDrawer extends StatelessWidget {
  final Function(String) onMenuSelected;

  const MainDrawer({super.key, required this.onMenuSelected});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final menuItems = authProvider.menuItems;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.fullName ?? user?.username ?? 'Unknown User'),
            accountEmail: Text(user?.role ?? 'No Role'),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 50),
            ),
          ),
          if (authProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (menuItems.isEmpty)
            const ListTile(title: Text('Không có menu phụ.'))
          else
            ...menuItems.map((item) => _buildMenuItem(context, item)).toList(),

          // ✅ Mục Lịch hẹn cố định
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event, color: Colors.teal),
            title: const Text('Đặt lịch hẹn'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingCalendarScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    if (item.children.isEmpty) {
      return ListTile(
        leading: Icon(getIconData(item.icon), size: 22),
        title: Text(item.title),
        onTap: () {
          Navigator.of(context).pop();
          onMenuSelected(item.route);
        },
      );
    } else {
      return ExpansionTile(
        leading: Icon(getIconData(item.icon)),
        title: Text(item.title),
        children: item.children
            .map((child) => Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: _buildMenuItem(context, child),
        ))
            .toList(),
      );
    }
  }
}
