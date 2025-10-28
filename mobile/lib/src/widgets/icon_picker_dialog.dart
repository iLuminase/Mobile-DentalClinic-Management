
import 'package:flutter/material.dart';

// Danh sách các icon có sẵn để lựa chọn.
// Key là tên icon (sẽ được lưu vào DB), Value là IconData để hiển thị.
const Map<String, IconData> availableIcons = {
  'dashboard': Icons.dashboard,
  'people': Icons.people,
  'person_add': Icons.person_add,
  'manage_accounts': Icons.manage_accounts,
  'rule_folder': Icons.rule_folder,
  'calendar_today': Icons.calendar_today,
  'assessment': Icons.assessment,
  'settings': Icons.settings,
  'receipt_long': Icons.receipt_long,
  'medical_services': Icons.medical_services,
  'medication': Icons.medication,
  'description': Icons.description,
  'payments': Icons.payments,
  'insights': Icons.insights,
  'inventory': Icons.inventory,
  'help_outline': Icons.help_outline,
};

/// Một dialog hiển thị một grid các icon cho người dùng lựa chọn.
class IconPickerDialog extends StatelessWidget {
  const IconPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn một Icon'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: availableIcons.length,
          itemBuilder: (context, index) {
            final iconName = availableIcons.keys.elementAt(index);
            final iconData = availableIcons.values.elementAt(index);

            return InkWell(
              onTap: () {
                // Khi người dùng chọn, trả về tên của icon đó.
                Navigator.of(context).pop(iconName);
              },
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, size: 32, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 4),
                  Text(
                    iconName,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
      ],
    );
  }
}
