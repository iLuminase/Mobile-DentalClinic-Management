# Quick Reference: Menu API Endpoints

## 📱 User Endpoints (Authenticated)

### 1. Get My Menus (Tree Structure)

```
GET /api/menus/me
Headers: Authorization: Bearer {token}
```

**Response**: Menu hierarchy với children

---

### 2. Get My Menus (Flat List)

```
GET /api/menus/flat
Headers: Authorization: Bearer {token}
```

**Response**: Tất cả menus dạng flat array (dễ search)

---

### 3. Get Breadcrumb

```
GET /api/menus/breadcrumb/{menuId}
Headers: Authorization: Bearer {token}
```

**Response**: Path từ root đến menu (ví dụ: [Home, Users, User List])

---

### 4. Get Menu Statistics

```
GET /api/menus/stats
Headers: Authorization: Bearer {token}
```

**Response**:

```json
{
  "totalMenus": 15,
  "parentMenus": 5,
  "childMenus": 10,
  "byDepth": { "0": 5, "1": 8, "2": 2 },
  "roles": ["ROLE_ADMIN"]
}
```

---

## 🔐 Admin Endpoints

### 5. Get All Menus

```
GET /api/menus
Headers: Authorization: Bearer {token}
Access: ROLE_ADMIN
```

### 6. Get Full Hierarchy

```
GET /api/menus/hierarchy
Headers: Authorization: Bearer {token}
Access: ROLE_ADMIN
```

### 7. Get Menu by ID

```
GET /api/menus/{id}
Headers: Authorization: Bearer {token}
Access: ROLE_ADMIN
```

### 8. Create Menu

```
POST /api/menus
Headers: Authorization: Bearer {token}
Access: ROLE_ADMIN
```

### 9. Update Menu

```
PUT /api/menus/{id}
Headers: Authorization: Bearer {token}
Access: ROLE_ADMIN
```

### 10. Delete Menu

```
DELETE /api/menus/{id}
Headers: Authorization: Bearer {token}
Access: ROLE_ADMIN
```

---

## 📋 JSON Response Fields

| Field           | Type     | Mobile Usage                         |
| --------------- | -------- | ------------------------------------ |
| `id`            | Long     | Unique identifier                    |
| `name`          | String   | Route key (e.g., "users")            |
| `title`         | String   | Display name (VN)                    |
| `path`          | String   | Route path (e.g., "/users")          |
| `icon`          | String   | Icon name (Material Icons)           |
| `iconType`      | String   | "material", "fontawesome", etc.      |
| `componentName` | String   | Flutter screen name (auto-generated) |
| `orderIndex`    | Integer  | Display order                        |
| `depth`         | Integer  | 0=root, 1=level1, ...                |
| `hasChildren`   | Boolean  | Has submenu?                         |
| `children`      | Array    | Submenu items                        |
| `roles`         | String[] | Required roles                       |
| `canView`       | Boolean  | User can view?                       |
| `canEdit`       | Boolean  | User can edit?                       |
| `canDelete`     | Boolean  | User can delete?                     |
| `tooltip`       | String   | Tooltip text                         |

---

## 🚀 Flutter Quick Start

```dart
// 1. Fetch menus
final response = await dio.get('/api/menus/me',
  options: Options(headers: {'Authorization': 'Bearer $token'}));

// 2. Parse JSON
List<MenuItem> menus = (response.data as List)
    .map((json) => MenuItem.fromJson(json))
    .toList();

// 3. Render sidebar
ListView.builder(
  itemCount: menus.length,
  itemBuilder: (context, index) {
    final menu = menus[index];
    return ListTile(
      leading: Icon(getIcon(menu.icon)),
      title: Text(menu.title),
      onTap: () => Navigator.pushNamed(context, menu.path),
    );
  },
)
```

---

## 📱 Test Commands

```bash
# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Get menus (replace TOKEN)
curl -X GET http://localhost:8080/api/menus/me \
  -H "Authorization: Bearer TOKEN"

curl -X GET http://localhost:8080/api/menus/flat \
  -H "Authorization: Bearer TOKEN"

curl -X GET http://localhost:8080/api/menus/breadcrumb/22 \
  -H "Authorization: Bearer TOKEN"

curl -X GET http://localhost:8080/api/menus/stats \
  -H "Authorization: Bearer TOKEN"
```

---

## 📖 Full Documentation

Chi tiết đầy đủ: [MENU-API-FOR-MOBILE.md](./MENU-API-FOR-MOBILE.md)

---

**Last Updated**: 2025-10-28  
**Status**: ✅ PRODUCTION READY
