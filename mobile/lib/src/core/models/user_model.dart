
import 'dart:convert';

class User {
  final String id;
  final String username;
  final String? email;
  final String? fullName;
  final String role;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    this.email,
    this.fullName,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<dynamic> rolesFromJson = json['roles'] ?? [];
    String mainRole = 'PENDING_USER';

    if (rolesFromJson.isNotEmpty) {
      final firstRole = rolesFromJson.first;
      if (firstRole is String) {
        mainRole = firstRole.replaceAll('ROLE_', '');
      } else if (firstRole is Map<String, dynamic> && firstRole.containsKey('name')) {
        final roleName = firstRole['name'] as String?;
        if (roleName != null) {
          mainRole = roleName.replaceAll('ROLE_', '');
        }
      }
    }

    bool parseActive(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    return User(
      id: json['id']?.toString() ?? json['sub']?.toString() ?? '',
      username: json['username'] ?? json['sub'] ?? '',
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      role: mainRole,
      isActive: parseActive(json['active']),
    );
  }

  String toJson() => json.encode({
    'id': id,
    'username': username,
    'email': email,
    'fullName': fullName,
    'role': role,
    'isActive': isActive,
  });
}
