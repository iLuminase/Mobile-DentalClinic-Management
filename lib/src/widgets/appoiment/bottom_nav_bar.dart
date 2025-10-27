import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback onAddPressed;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home,
                color: selectedIndex == 0 ? Colors.blue : Colors.grey),
            onPressed: () => onItemTapped(0),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today,
                color: selectedIndex == 1 ? Colors.blue : Colors.grey),
            onPressed: () => onItemTapped(1),
          ),
          const SizedBox(width: 40), // chừa chỗ cho nút "+"
          IconButton(
            icon: Icon(Icons.settings,
                color: selectedIndex == 2 ? Colors.blue : Colors.grey),
            onPressed: () => onItemTapped(2),
          ),
        ],
      ),
    );
  }
}
