
// Model cho đối tượng người dùng
class User {
  final String id;
  final String username;
  final String? email;
  final String? fullName;
  final String role; // Chỉ lưu role chính để xử lý logic trong app

  User({
    required this.id,
    required this.username,
    this.email,
    this.fullName,
    required this.role,
  });

  // Factory constructor để tạo User từ JSON mà API trả về
  factory User.fromJson(Map<String, dynamic> json) {
    List<dynamic> rolesFromJson = json['roles'] ?? [];
    String mainRole = 'PENDING_USER'; // Mặc định
    if (rolesFromJson.isNotEmpty) {
      // Lấy role đầu tiên và xóa tiền tố "ROLE_"
      mainRole = (rolesFromJson.first as String).replaceAll('ROLE_', '');
    }

    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      fullName: json['fullName'],
      role: mainRole,
    );
  }
}
