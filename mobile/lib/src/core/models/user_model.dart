
import 'dart:convert';

// Model cho đối tượng người dùng.
class User {
  final String id;
  final String username;
  final String? email;
  final String? fullName;
  final String role; // Role chính của người dùng (ví dụ: ADMIN, DOCTOR)
  final bool isActive; // SỬA LỖI: Thêm lại trường trạng thái active

  User({
    required this.id,
    required this.username,
    this.email,
    this.fullName,
    required this.role,
    required this.isActive, // SỬA LỖI: Thêm lại vào constructor
  });

  // Tạo một đối tượng User từ dữ liệu JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    List<dynamic> rolesFromJson = json['roles'] ?? [];
    String mainRole = 'PENDING_USER'; // Mặc định

    if (rolesFromJson.isNotEmpty) {
      final firstRole = rolesFromJson.first;
      if (firstRole is String) {
        // Xử lý trường hợp roles là List<String>, ví dụ: ["ROLE_ADMIN"]
        mainRole = firstRole.replaceAll('ROLE_', '');
      } else if (firstRole is Map<String, dynamic> && firstRole.containsKey('name')) {
        // Xử lý trường hợp roles là List<Map>, ví dụ: [{"id": 1, "name": "ROLE_ADMIN"}]
        final roleName = firstRole['name'] as String?;
        if (roleName != null) {
          mainRole = roleName.replaceAll('ROLE_', '');
        }
      }
    }

    return User(
      // Lấy id từ key 'id' (cho API response) hoặc 'sub' (cho JWT token)
      id: json['id']?.toString() ?? json['sub']?.toString() ?? '',
      username: json['username'] ?? json['sub'] ?? '',
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      role: mainRole,
      // SỬA LỖI: Đọc trạng thái 'active' từ JSON. Mặc định là false.
      isActive: json['active'] as bool? ?? false,
    );
  }

  // Chuyển đổi User thành chuỗi JSON (hữu ích cho việc debug).
  String toJson() => json.encode({
    'id': id,
    'username': username,
    'email': email,
    'fullName': fullName,
    'role': role,
    'isActive': isActive,
  });
}
