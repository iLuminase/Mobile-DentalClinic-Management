
import 'package:flutter/material.dart';

// Ánh xạ tên icon từ API (String) sang đối tượng IconData của Flutter
IconData getIconData(String iconName) {
  switch (iconName) {
    case 'dashboard':
      return Icons.dashboard;
    case 'people':
      return Icons.people;
    case 'person':
      return Icons.person;
    case 'list':
      return Icons.list;
    case 'add':
      return Icons.add;
    case 'calendar_today':
      return Icons.calendar_today;
    case 'description':
      return Icons.description;
    case 'medical_services':
      return Icons.medical_services;
    case 'receipt':
      return Icons.receipt;
    case 'assessment':
      return Icons.assessment;
    case 'settings':
      return Icons.settings;
    default:
      return Icons.help; // Icon mặc định nếu không tìm thấy
  }
}
