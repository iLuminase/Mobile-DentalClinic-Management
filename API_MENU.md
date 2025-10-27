# Menu & Permission Management API

## Tổng quan

Hệ thống phân quyền menu động dựa trên role của user. Mỗi menu có thể gán cho nhiều roles, và mỗi user nhận menu dựa trên roles được assign.

## Database Schema

### Table: `menus`

| Column      | Type          | Description           |
| ----------- | ------------- | --------------------- |
| id          | BIGINT        | Primary key           |
| name        | NVARCHAR(100) | Tên menu (unique key) |
| title       | NVARCHAR(100) | Tiêu đề hiển thị      |
| path        | NVARCHAR(255) | URL path              |
| icon        | NVARCHAR(50)  | Icon name             |
| order_index | INT           | Thứ tự hiển thị       |
| parent_id   | BIGINT        | Menu cha (nullable)   |
| active      | BIT           | Trạng thái            |

### Table: `menu_roles`

| Column  | Type   | Description |
| ------- | ------ | ----------- |
| menu_id | BIGINT | FK to menus |
| role_id | BIGINT | FK to roles |

## API Endpoints

### 1. Lấy menu của user hiện tại

**Endpoint:** `GET /api/menus/me`

**Authorization:** Bearer Token (tất cả roles)

**Response:**

```json
[
  {
    "id": 1,
    "name": "dashboard",
    "title": "Tổng quan",
    "path": "/dashboard",
    "icon": "dashboard",
    "orderIndex": 1,
    "parentId": null,
    "children": [],
    "active": true
  },
  {
    "id": 3,
    "name": "patients",
    "title": "Quản lý bệnh nhân",
    "path": "/patients",
    "icon": "person",
    "orderIndex": 3,
    "parentId": null,
    "children": [
      {
        "id": 4,
        "name": "patients-list",
        "title": "Danh sách bệnh nhân",
        "path": "/patients/list",
        "icon": "list",
        "orderIndex": 1,
        "parentId": 3,
        "children": [],
        "active": true
      }
    ],
    "active": true
  }
]
```

### 2. Lấy tất cả menu (Admin)

**Endpoint:** `GET /api/menus`

**Authorization:** Bearer Token (ROLE_ADMIN only)

**Response:** Tương tự như `/api/menus/me`

### 3. Lấy menu theo ID

**Endpoint:** `GET /api/menus/{id}`

**Authorization:** Bearer Token (ROLE_ADMIN only)

**Response:**

```json
{
  "id": 1,
  "name": "dashboard",
  "title": "Tổng quan",
  "path": "/dashboard",
  "icon": "dashboard",
  "orderIndex": 1,
  "parentId": null,
  "children": [],
  "active": true
}
```

### 4. Tạo menu mới

**Endpoint:** `POST /api/menus`

**Authorization:** Bearer Token (ROLE_ADMIN only)

**Request Body:**

```json
{
  "name": "reports",
  "title": "Báo cáo",
  "path": "/reports",
  "icon": "assessment",
  "orderIndex": 8,
  "parentId": null,
  "roleNames": ["ROLE_ADMIN", "ROLE_DOCTOR"],
  "active": true
}
```

**Response:** Menu object đã tạo

### 5. Cập nhật menu

**Endpoint:** `PUT /api/menus/{id}`

**Authorization:** Bearer Token (ROLE_ADMIN only)

**Request Body:** Tương tự POST

**Response:** Menu object đã cập nhật

### 6. Xóa menu (soft delete)

**Endpoint:** `DELETE /api/menus/{id}`

**Authorization:** Bearer Token (ROLE_ADMIN only)

**Response:** 204 No Content

## Menu mặc định

Khi chạy lần đầu, hệ thống tự động tạo các menu:

| Menu                | Title               | Path               | Roles               | Icon             |
| ------------------- | ------------------- | ------------------ | ------------------- | ---------------- |
| dashboard           | Tổng quan           | /dashboard         | ALL                 | dashboard        |
| users               | Quản lý người dùng  | /users             | ADMIN               | people           |
| patients            | Quản lý bệnh nhân   | /patients          | ADMIN, RECEPTIONIST | person           |
| - patients-list     | Danh sách bệnh nhân | /patients/list     | ADMIN, RECEPTIONIST | list             |
| - patients-add      | Thêm bệnh nhân      | /patients/add      | ADMIN, RECEPTIONIST | add              |
| appointments        | Quản lý lịch hẹn    | /appointments      | ALL                 | calendar_today   |
| - appointments-list | Danh sách lịch hẹn  | /appointments/list | ALL                 | list             |
| - appointments-add  | Đặt lịch mới        | /appointments/add  | ADMIN, RECEPTIONIST | add              |
| medical-records     | Hồ sơ bệnh án       | /medical-records   | ADMIN, DOCTOR       | description      |
| services            | Dịch vụ nha khoa    | /services          | ADMIN, RECEPTIONIST | medical_services |
| invoices            | Hóa đơn             | /invoices          | ADMIN, RECEPTIONIST | receipt          |
| reports             | Báo cáo             | /reports           | ADMIN               | assessment       |
| settings            | Cài đặt             | /settings          | ADMIN               | settings         |

## Test với cURL

### 1. Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 2. Lấy menu của user hiện tại

```bash
curl http://localhost:8080/api/menus/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3. Tạo menu mới (Admin)

```bash
curl -X POST http://localhost:8080/api/menus \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "statistics",
    "title": "Thống kê",
    "path": "/statistics",
    "icon": "bar_chart",
    "orderIndex": 10,
    "roleNames": ["ROLE_ADMIN"],
    "active": true
  }'
```

## Frontend Integration

### React/Angular/Vue Example

```typescript
// 1. Lấy menu sau khi login
const getMenus = async () => {
  const response = await fetch("/api/menus/me", {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  const menus = await response.json();
  return menus;
};

// 2. Render menu tree
const renderMenu = (menus) => {
  return menus.map((menu) => (
    <MenuItem key={menu.id}>
      <Icon>{menu.icon}</Icon>
      <Link to={menu.path}>{menu.title}</Link>
      {menu.children.length > 0 && renderMenu(menu.children)}
    </MenuItem>
  ));
};
```

### Flutter Example

```dart
// 1. Fetch menus
Future<List<Menu>> getMenus() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/menus/me'),
    headers: {'Authorization': 'Bearer $token'},
  );
  final List data = jsonDecode(response.body);
  return data.map((json) => Menu.fromJson(json)).toList();
}

// 2. Build menu UI
Widget buildMenu(List<Menu> menus) {
  return ListView.builder(
    itemCount: menus.length,
    itemBuilder: (context, index) {
      final menu = menus[index];
      return ListTile(
        leading: Icon(getIconData(menu.icon)),
        title: Text(menu.title),
        onTap: () => Navigator.pushNamed(context, menu.path),
      );
    },
  );
}
```

## Business Rules

1. **Phân quyền động:** Menu hiển thị dựa trên role của user
2. **Hierarchical:** Hỗ trợ menu cha-con (unlimited depth)
3. **Soft delete:** Menu bị xóa chỉ set `active = false`
4. **Order control:** Thứ tự hiển thị theo `orderIndex`
5. **Multi-role:** Một menu có thể gán cho nhiều roles

## Notes

- Icon names sử dụng Material Icons (https://fonts.google.com/icons)
- Path phải unique trong hệ thống
- Menu con tự động ẩn khi menu cha bị deactivate
- Admin có quyền xem tất cả menu
