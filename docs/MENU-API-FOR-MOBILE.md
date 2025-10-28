# Menu Management API - Mobile Integration Guide

## Overview

API quản lý menu theo quyền user với JSON response được tối ưu cho mobile development (Flutter/React Native).

**Base URL**: `http://localhost:8080/api/menus`  
**Authentication**: JWT Bearer Token  
**Response Format**: JSON

---

## 📱 Mobile-Friendly Features

✅ **Hierarchical menu structure** với parent-child relationships  
✅ **Flat menu list** để dễ dàng search và filter  
✅ **Breadcrumb support** để hiển thị navigation path  
✅ **Rich metadata** cho mobile UI (icon, color, badge, tooltip)  
✅ **Permission info** để show/hide features  
✅ **Auto-generated component names** cho Flutter routing  
✅ **@JsonInclude(NON_NULL)** - chỉ trả về fields có giá trị

---

## 🎯 User Endpoints (Authenticated)

### 1. Get My Menus (Hierarchy)

**Endpoint**: `GET /api/menus/me`  
**Description**: Lấy menu tree của user hiện tại theo roles  
**Use case**: Render sidebar menu, navigation drawer

**Request**:

```bash
curl -X GET http://localhost:8080/api/menus/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response**:

```json
[
  {
    "id": 1,
    "name": "dashboard",
    "title": "Tổng quan",
    "path": "/dashboard",
    "icon": "dashboard",
    "iconType": "material",
    "orderIndex": 1,
    "parentId": null,
    "active": true,
    "depth": 0,
    "hasChildren": false,
    "roles": ["ROLE_ADMIN", "ROLE_DOCTOR"],
    "canView": true,
    "canEdit": true,
    "canDelete": true,
    "target": "_self",
    "external": false,
    "componentName": "DashboardScreen",
    "tooltip": "Tổng quan",
    "children": []
  },
  {
    "id": 2,
    "name": "users",
    "title": "Quản lý người dùng",
    "path": "/users",
    "icon": "people",
    "iconType": "material",
    "orderIndex": 2,
    "parentId": null,
    "active": true,
    "depth": 0,
    "hasChildren": true,
    "roles": ["ROLE_ADMIN"],
    "canView": true,
    "canEdit": true,
    "canDelete": true,
    "target": "_self",
    "external": false,
    "componentName": "UsersScreen",
    "tooltip": "Quản lý người dùng",
    "children": [
      {
        "id": 21,
        "name": "users-list",
        "title": "Danh sách người dùng",
        "path": "/users/list",
        "icon": "list",
        "iconType": "material",
        "orderIndex": 1,
        "parentId": 2,
        "active": true,
        "depth": 1,
        "hasChildren": false,
        "roles": ["ROLE_ADMIN"],
        "canView": true,
        "canEdit": true,
        "canDelete": true,
        "target": "_self",
        "external": false,
        "componentName": "UsersListScreen",
        "tooltip": "Danh sách người dùng",
        "children": []
      },
      {
        "id": 22,
        "name": "users-create",
        "title": "Thêm người dùng",
        "path": "/users/create",
        "icon": "person_add",
        "iconType": "material",
        "orderIndex": 2,
        "parentId": 2,
        "active": true,
        "depth": 1,
        "hasChildren": false,
        "roles": ["ROLE_ADMIN"],
        "canView": true,
        "canEdit": true,
        "canDelete": true,
        "target": "_self",
        "external": false,
        "componentName": "UsersCreateScreen",
        "tooltip": "Thêm người dùng",
        "children": []
      }
    ]
  },
  {
    "id": 3,
    "name": "patients",
    "title": "Quản lý bệnh nhân",
    "path": "/patients",
    "icon": "person",
    "iconType": "material",
    "orderIndex": 3,
    "parentId": null,
    "active": true,
    "depth": 0,
    "hasChildren": true,
    "roles": ["ROLE_ADMIN", "ROLE_RECEPTIONIST"],
    "canView": true,
    "canEdit": true,
    "canDelete": true,
    "target": "_self",
    "external": false,
    "componentName": "PatientsScreen",
    "tooltip": "Quản lý bệnh nhân",
    "children": [
      {
        "id": 31,
        "name": "patients-list",
        "title": "Danh sách bệnh nhân",
        "path": "/patients/list",
        "icon": "list",
        "iconType": "material",
        "orderIndex": 1,
        "parentId": 3,
        "active": true,
        "depth": 1,
        "hasChildren": false,
        "roles": ["ROLE_ADMIN", "ROLE_RECEPTIONIST"],
        "canView": true,
        "canEdit": true,
        "canDelete": true,
        "target": "_self",
        "external": false,
        "componentName": "PatientsListScreen",
        "tooltip": "Danh sách bệnh nhân",
        "children": []
      }
    ]
  }
]
```

---

### 2. Get My Menus (Flat List)

**Endpoint**: `GET /api/menus/flat`  
**Description**: Lấy tất cả menu của user dạng flat list (không có hierarchy)  
**Use case**: Search menu, quick access, autocomplete

**Request**:

```bash
curl -X GET http://localhost:8080/api/menus/flat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response**:

```json
[
  {
    "id": 1,
    "name": "dashboard",
    "title": "Tổng quan",
    "path": "/dashboard",
    "icon": "dashboard",
    "iconType": "material",
    "orderIndex": 1,
    "parentId": null,
    "active": true,
    "depth": 0,
    "hasChildren": false,
    "roles": ["ROLE_ADMIN", "ROLE_DOCTOR"],
    "canView": true,
    "canEdit": true,
    "canDelete": true,
    "target": "_self",
    "external": false,
    "componentName": "DashboardScreen",
    "tooltip": "Tổng quan",
    "children": []
  },
  {
    "id": 2,
    "name": "users",
    "title": "Quản lý người dùng",
    "path": "/users",
    "icon": "people",
    "iconType": "material",
    "orderIndex": 2,
    "parentId": null,
    "active": true,
    "depth": 0,
    "hasChildren": true,
    "roles": ["ROLE_ADMIN"],
    "canView": true,
    "canEdit": true,
    "canDelete": true,
    "target": "_self",
    "external": false,
    "componentName": "UsersScreen",
    "tooltip": "Quản lý người dùng",
    "children": []
  },
  {
    "id": 21,
    "name": "users-list",
    "title": "Danh sách người dùng",
    "path": "/users/list",
    "icon": "list",
    "iconType": "material",
    "orderIndex": 1,
    "parentId": 2,
    "active": true,
    "depth": 1,
    "hasChildren": false,
    "roles": ["ROLE_ADMIN"],
    "canView": true,
    "canEdit": true,
    "canDelete": true,
    "target": "_self",
    "external": false,
    "componentName": "UsersListScreen",
    "tooltip": "Danh sách người dùng",
    "children": []
  }
]
```

---

### 3. Get Breadcrumb Path

**Endpoint**: `GET /api/menus/breadcrumb/{id}`  
**Description**: Lấy đường dẫn từ root menu đến menu cụ thể  
**Use case**: Hiển thị breadcrumb navigation

**Request**:

```bash
curl -X GET http://localhost:8080/api/menus/breadcrumb/22 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response**:

```json
[
  {
    "id": 2,
    "name": "users",
    "title": "Quản lý người dùng",
    "path": "/users",
    "icon": "people",
    "iconType": "material",
    "orderIndex": 2,
    "parentId": null,
    "active": true,
    "depth": 0,
    "hasChildren": true,
    "roles": ["ROLE_ADMIN"],
    "canView": true,
    "canEdit": true,
    "canDelete": true,
    "target": "_self",
    "external": false,
    "componentName": "UsersScreen",
    "tooltip": "Quản lý người dùng",
    "children": []
  },
  {
    "id": 22,
    "name": "users-create",
    "title": "Thêm người dùng",
    "path": "/users/create",
    "icon": "person_add",
    "iconType": "material",
    "orderIndex": 2,
    "parentId": 2,
    "active": true,
    "depth": 1,
    "hasChildren": false,
    "roles": ["ROLE_ADMIN"],
    "canView": true,
    "canEdit": true,
    "canDelete": true,
    "target": "_self",
    "external": false,
    "componentName": "UsersCreateScreen",
    "tooltip": "Thêm người dùng",
    "children": []
  }
]
```

**Mobile UI Example** (Flutter):

```dart
// Hiển thị breadcrumb
String breadcrumb = response
    .map((menu) => menu['title'])
    .join(' > ');
// Result: "Quản lý người dùng > Thêm người dùng"
```

---

### 4. Get Menu Statistics

**Endpoint**: `GET /api/menus/stats`  
**Description**: Lấy thống kê menu của user  
**Use case**: Dashboard, analytics

**Request**:

```bash
curl -X GET http://localhost:8080/api/menus/stats \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response**:

```json
{
  "totalMenus": 15,
  "parentMenus": 5,
  "childMenus": 10,
  "byDepth": {
    "0": 5,
    "1": 8,
    "2": 2
  },
  "roles": ["ROLE_ADMIN", "ROLE_DOCTOR"]
}
```

---

## 🔐 Admin Endpoints

### 5. Get All Menus

**Endpoint**: `GET /api/menus`  
**Access**: ROLE_ADMIN  
**Description**: Lấy tất cả parent menus (không có children)

---

### 6. Get Full Menu Hierarchy

**Endpoint**: `GET /api/menus/hierarchy`  
**Access**: ROLE_ADMIN  
**Description**: Lấy toàn bộ menu tree cho quản lý

**Response**: Same structure as `/me` but includes ALL menus regardless of user role

---

## 📋 Response Fields Explained

| Field           | Type     | Description                  | Example                   |
| --------------- | -------- | ---------------------------- | ------------------------- |
| `id`            | Long     | Menu ID                      | 1                         |
| `name`          | String   | Unique identifier            | "users"                   |
| `title`         | String   | Display name (VN)            | "Quản lý người dùng"      |
| `path`          | String   | Route path                   | "/users"                  |
| `icon`          | String   | Icon name                    | "people"                  |
| `iconType`      | String   | Icon library type            | "material", "fontawesome" |
| `orderIndex`    | Integer  | Display order                | 1, 2, 3...                |
| `parentId`      | Long?    | Parent menu ID (null = root) | 2                         |
| `active`        | Boolean  | Is menu active?              | true                      |
| `depth`         | Integer  | Menu depth level             | 0, 1, 2...                |
| `hasChildren`   | Boolean  | Has submenus?                | true/false                |
| `roles`         | String[] | Required roles               | ["ROLE_ADMIN"]            |
| `canView`       | Boolean  | User can view?               | true                      |
| `canEdit`       | Boolean  | User can edit?               | true                      |
| `canDelete`     | Boolean  | User can delete?             | true                      |
| `target`        | String   | Link target                  | "\_self", "\_blank"       |
| `external`      | Boolean  | Is external link?            | false                     |
| `componentName` | String   | Flutter screen name          | "UsersScreen"             |
| `tooltip`       | String   | Tooltip text                 | "Quản lý người dùng"      |
| `children`      | Array    | Submenu items                | []                        |
| `description`   | String?  | Menu description             | "Manage users"            |
| `color`         | String?  | Theme color                  | "#1976D2"                 |
| `badgeCount`    | Integer? | Notification badge           | 5                         |
| `badgeColor`    | String?  | Badge color                  | "red"                     |
| `isNew`         | Boolean? | Show NEW label?              | true                      |

_Fields with `?` are optional and only returned when they have values_

---

## 💡 Flutter Integration Examples

### Example 1: Render Sidebar Menu

```dart
import 'package:flutter/material.dart';

class MenuItem {
  final int id;
  final String name;
  final String title;
  final String path;
  final String icon;
  final List<MenuItem> children;

  MenuItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        title = json['title'],
        path = json['path'],
        icon = json['icon'],
        children = (json['children'] as List? ?? [])
            .map((child) => MenuItem.fromJson(child))
            .toList();
}

class SidebarMenu extends StatelessWidget {
  final List<MenuItem> menus;

  const SidebarMenu({Key? key, required this.menus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: menus.map((menu) => _buildMenuItem(menu)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem menu) {
    if (menu.children.isEmpty) {
      return ListTile(
        leading: Icon(_getIconData(menu.icon)),
        title: Text(menu.title),
        onTap: () {
          // Navigate to menu.path or menu.componentName
        },
      );
    } else {
      return ExpansionTile(
        leading: Icon(_getIconData(menu.icon)),
        title: Text(menu.title),
        children: menu.children.map((child) => Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: _buildMenuItem(child),
        )).toList(),
      );
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dashboard': return Icons.dashboard;
      case 'people': return Icons.people;
      case 'person': return Icons.person;
      case 'calendar_today': return Icons.calendar_today;
      default: return Icons.menu;
    }
  }
}
```

### Example 2: Search Menu

```dart
List<MenuItem> searchMenus(List<MenuItem> flatMenus, String query) {
  return flatMenus.where((menu) {
    return menu.title.toLowerCase().contains(query.toLowerCase()) ||
           menu.name.toLowerCase().contains(query.toLowerCase());
  }).toList();
}
```

### Example 3: Dynamic Routing

```dart
import 'package:go_router/go_router.dart';

List<GoRoute> generateRoutesFromMenus(List<MenuItem> menus) {
  return menus.map((menu) => GoRoute(
    path: menu.path,
    name: menu.name,
    builder: (context, state) => _getScreenWidget(menu.componentName),
  )).toList();
}

Widget _getScreenWidget(String componentName) {
  switch (componentName) {
    case 'DashboardScreen': return DashboardScreen();
    case 'UsersScreen': return UsersScreen();
    case 'PatientsScreen': return PatientsScreen();
    default: return NotFoundScreen();
  }
}
```

### Example 4: Permission Check

```dart
bool canAccess(MenuItem menu) {
  return menu.canView == true;
}

bool canEdit(MenuItem menu) {
  return menu.canEdit == true;
}

Widget buildActionButton(MenuItem menu) {
  if (canEdit(menu)) {
    return IconButton(
      icon: Icon(Icons.edit),
      onTap: () { /* Edit action */ },
    );
  }
  return SizedBox.shrink();
}
```

---

## 🎨 UI Customization

### Badge Support (Future Enhancement)

```json
{
  "id": 4,
  "name": "appointments",
  "title": "Lịch hẹn",
  "badgeCount": 5,
  "badgeColor": "red",
  "isNew": false
}
```

Flutter usage:

```dart
Badge(
  label: Text('${menu.badgeCount}'),
  backgroundColor: _getBadgeColor(menu.badgeColor),
  child: Icon(_getIconData(menu.icon)),
)
```

### Theme Color Support

```json
{
  "id": 5,
  "name": "reports",
  "title": "Báo cáo",
  "color": "#4CAF50"
}
```

Flutter usage:

```dart
ListTile(
  leading: Icon(
    _getIconData(menu.icon),
    color: Color(int.parse(menu.color.replaceFirst('#', '0xFF'))),
  ),
  title: Text(menu.title),
)
```

---

## 🔄 Data Flow

```
Mobile App
    ↓ Login with JWT
    ↓ GET /api/menus/me
Backend
    ↓ Check user roles
    ↓ Filter menus by roles
    ↓ Build hierarchy
    ↓ Return JSON
Mobile App
    ↓ Parse JSON
    ↓ Render UI
    ↓ Setup routing
```

---

## 🚀 Best Practices

### 1. Cache Menu Data

```dart
class MenuService {
  List<MenuItem>? _cachedMenus;
  DateTime? _cacheTime;
  final Duration cacheDuration = Duration(hours: 1);

  Future<List<MenuItem>> getMenus({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedMenus != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < cacheDuration) {
      return _cachedMenus!;
    }

    final response = await dio.get('/api/menus/me');
    _cachedMenus = (response.data as List)
        .map((json) => MenuItem.fromJson(json))
        .toList();
    _cacheTime = DateTime.now();

    return _cachedMenus!;
  }
}
```

### 2. Handle Permissions

```dart
Widget buildScreen(MenuItem menu) {
  if (!menu.canView) {
    return AccessDeniedScreen();
  }

  return YourScreen(
    canEdit: menu.canEdit,
    canDelete: menu.canDelete,
  );
}
```

### 3. Error Handling

```dart
try {
  final menus = await menuService.getMenus();
  // Use menus
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Token expired, redirect to login
  } else if (e.response?.statusCode == 403) {
    // Access denied
  }
}
```

---

## 📱 Testing

### Test với cURL

```bash
# 1. Login để lấy token
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Copy accessToken từ response

# 2. Test menu endpoints
TOKEN="your_access_token_here"

curl -X GET http://localhost:8080/api/menus/me \
  -H "Authorization: Bearer $TOKEN"

curl -X GET http://localhost:8080/api/menus/flat \
  -H "Authorization: Bearer $TOKEN"

curl -X GET http://localhost:8080/api/menus/breadcrumb/22 \
  -H "Authorization: Bearer $TOKEN"

curl -X GET http://localhost:8080/api/menus/stats \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🔒 Security Notes

1. **All endpoints require JWT authentication** (except admin endpoints which also require ROLE_ADMIN)
2. **User only sees menus they have permission to access** (filtered by roles)
3. **Breadcrumb endpoint validates user permission** before returning path
4. **Token expiration**: 24 hours (refresh token: 7 days)

---

## 📞 Support

- **API Base URL**: `http://localhost:8080`
- **Docs**: `/docs` folder
- **Swagger**: (Coming soon)

---

## 🎉 Summary

✅ **4 user endpoints** cho mobile app  
✅ **2 admin endpoints** cho quản lý  
✅ **Rich JSON structure** với metadata đầy đủ  
✅ **Auto-generated component names** cho routing  
✅ **Permission-based filtering** theo user roles  
✅ **Optimized for mobile** với flat list, breadcrumb, statistics  
✅ **Flutter examples** sẵn sàng để integrate

Happy coding! 🚀
