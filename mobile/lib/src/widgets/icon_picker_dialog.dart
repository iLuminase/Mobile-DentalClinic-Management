
import 'package:flutter/material.dart';

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
            crossAxisCount: 4, // Giảm số cột để có nhiều không gian hơn
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: availableIcons.length,
          itemBuilder: (context, index) {
            final iconName = availableIcons.keys.elementAt(index);
            final iconData = availableIcons.values.elementAt(index);

            return InkWell(
              onTap: () => Navigator.of(context).pop(iconName),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, size: 30, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 8),
                  // SỬA LỖI: Dùng FittedBox để text tự co lại nếu cần
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      iconName,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                    ),
                  ),
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
