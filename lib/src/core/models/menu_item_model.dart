
// Model cho đối tượng Menu, hỗ trợ cấu trúc lồng nhau từ API
class MenuItem {
  final String id;
  final String title;
  final String route;
  final String icon;
  final String? parentId;
  final List<String> roles; // Danh sách các role được gán cho menu này
  List<MenuItem> children;      // Danh sách các menu con

  MenuItem({
    required this.id,
    required this.title,
    required this.route,
    required this.icon,
    required this.roles,
    this.parentId,
    this.children = const [],
  });

  // Factory constructor để tạo MenuItem từ JSON, có xử lý đệ quy
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    var childrenFromJson = json['children'] as List?;
    List<MenuItem> childrenList = childrenFromJson != null
        ? childrenFromJson.map((child) => MenuItem.fromJson(child)).toList()
        : [];

    // API có thể trả về roles dưới dạng list các object hoặc list các string
    // Giả sử là list các string, ví dụ: ["ROLE_ADMIN", "ROLE_DOCTOR"]
    var rolesFromJson = json['roles'] as List?;
    List<String> rolesList = rolesFromJson != null 
        ? rolesFromJson.map((role) => role.toString().replaceAll('ROLE_', '')).toList() 
        : [];

    return MenuItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      route: json['path'] ?? '/', 
      icon: json['icon'] ?? 'help',
      parentId: json['parentId']?.toString(),
      roles: rolesList, // Thêm lại danh sách roles
      children: childrenList,
    );
  }
}
