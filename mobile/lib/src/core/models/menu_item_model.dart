// filepath: d:\LapTrinhMobile\DoAn\Mobile-DentalClinic-Management\mobile\lib\src\core\models\menu_item_model.dart

class MenuItem {
  final int id;
  final String name;
  final String title;
  final String path;
  final String icon;
  final String? iconType;
  final int orderIndex;
  final int? parentId;
  final bool active;
  final int depth;
  final bool hasChildren;
  final List<MenuItem> children;
  final List<String> roles;
  final bool canView;
  final bool canEdit;
  final bool canDelete;
  final String? componentName;
  final String? tooltip;

  MenuItem({
    required this.id,
    required this.name,
    required this.title,
    required this.path,
    required this.icon,
    this.iconType,
    required this.orderIndex,
    this.parentId,
    required this.active,
    required this.depth,
    required this.hasChildren,
    this.children = const [],
    this.roles = const [],
    required this.canView,
    required this.canEdit,
    required this.canDelete,
    this.componentName,
    this.tooltip,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    List<MenuItem> childrenList = [];
    if (json['children'] != null && json['children'] is List) {
      try {
        childrenList = (json['children'] as List)
            .where((item) => item != null && item is Map<String, dynamic>)
            .map((childJson) => MenuItem.fromJson(childJson as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('⚠️ Lỗi parse children: $e');
      }
    }

    List<String> rolesList = [];
    if (json['roles'] != null) {
      try {
        if (json['roles'] is List) {
          rolesList = (json['roles'] as List).map<String?>((role) {
            if (role == null) return null;
            if (role is Map<String, dynamic>) {
              return role['name']?.toString();
            }
            if (role is String) {
              return role;
            }
            return role.toString();
          }).where((role) => role != null && role.isNotEmpty).cast<String>().toList();
        } else if (json['roles'] is String) {
          rolesList = [json['roles'] as String];
        }
      } catch (e) {
        print('⚠️ Lỗi parse roles: $e, raw data: ${json['roles']}');
      }
    }

    return MenuItem(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'menu',
      iconType: json['iconType']?.toString(),
      orderIndex: _parseInt(json['orderIndex']) ?? 0,
      parentId: _parseInt(json['parentId']),
      active: _parseBool(json['active']) ?? true,
      depth: _parseInt(json['depth']) ?? 0,
      hasChildren: _parseBool(json['hasChildren']) ?? false,
      children: childrenList,
      roles: rolesList,
      canView: _parseBool(json['canView']) ?? false,
      canEdit: _parseBool(json['canEdit']) ?? false,
      canDelete: _parseBool(json['canDelete']) ?? false,
      componentName: json['componentName']?.toString(),
      tooltip: json['tooltip']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) return value != 0;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'path': path,
      'icon': icon,
      if (iconType != null) 'iconType': iconType,
      'orderIndex': orderIndex,
      if (parentId != null) 'parentId': parentId,
      'active': active,
      'depth': depth,
      'hasChildren': hasChildren,
      'children': children.map((child) => child.toJson()).toList(),
      'roles': roles,
      'canView': canView,
      'canEdit': canEdit,
      'canDelete': canDelete,
      if (componentName != null) 'componentName': componentName,
      if (tooltip != null) 'tooltip': tooltip,
    };
  }

  MenuItem copyWith({
    int? id,
    String? name,
    String? title,
    String? path,
    String? icon,
    String? iconType,
    int? orderIndex,
    int? parentId,
    bool? active,
    int? depth,
    bool? hasChildren,
    List<MenuItem>? children,
    List<String>? roles,
    bool? canView,
    bool? canEdit,
    bool? canDelete,
    String? componentName,
    String? tooltip,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      path: path ?? this.path,
      icon: icon ?? this.icon,
      iconType: iconType ?? this.iconType,
      orderIndex: orderIndex ?? this.orderIndex,
      parentId: parentId ?? this.parentId,
      active: active ?? this.active,
      depth: depth ?? this.depth,
      hasChildren: hasChildren ?? this.hasChildren,
      children: children ?? this.children,
      roles: roles ?? this.roles,
      canView: canView ?? this.canView,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
      componentName: componentName ?? this.componentName,
      tooltip: tooltip ?? this.tooltip,
    );
  }

  List<String> get rolesWithoutPrefix {
    return roles.map((r) => r.replaceAll('ROLE_', '')).toList();
  }

  bool hasRole(String roleName) {
    final normalized = roleName.toUpperCase();
    return roles.any((r) =>
      r.toUpperCase() == normalized ||
      r.toUpperCase() == 'ROLE_$normalized'
    );
  }

  String get displayTitle {
    return '${'\u00A0\u00A0' * depth}${depth > 0 ? '└ ' : ''}$title';
  }

  List<MenuItem> toFlatList() {
    final List<MenuItem> result = [this];
    for (final child in children) {
      result.addAll(child.toFlatList());
    }
    return result;
  }

  @override
  String toString() {
    return 'MenuItem(id: $id, title: $title, roles: $roles, children: ${children.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

