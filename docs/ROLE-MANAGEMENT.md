# Role Management with RoleEnum

## Overview

Hệ thống sử dụng enum `RoleEnum` để quản lý các role trong ứng dụng. Khi tạo user mới (register hoặc create user API), role mặc định sẽ là **`ROLE_PENDING_USER`** (ID = 5).

## RoleEnum Structure

### File: `src/main/java/com/dentalclinic/dentalclinic_api/enums/RoleEnum.java`

```java
public enum RoleEnum {
    ADMIN(1L, "ROLE_ADMIN", "Quản trị viên hệ thống"),
    DOCTOR(2L, "ROLE_DOCTOR", "Bác sĩ nha khoa"),
    RECEPTIONIST(3L, "ROLE_RECEPTIONIST", "Lễ tân"),
    VIEWER(4L, "ROLE_VIEWER", "Người dùng chỉ xem"),
    PENDING_USER(5L, "ROLE_PENDING_USER", "Người dùng chờ duyệt");
}
```

### Properties

- **ID**: Database ID của role
- **Role Name**: Tên role dùng trong hệ thống (e.g., "ROLE_ADMIN")
- **Description**: Mô tả role bằng tiếng Việt

### Methods

#### `getDefaultRole()`

Trả về role mặc định cho user mới đăng ký.

```java
RoleEnum defaultRole = RoleEnum.getDefaultRole(); // Returns PENDING_USER
```

#### `fromRoleName(String roleName)`

Tìm RoleEnum theo tên role.

```java
RoleEnum role = RoleEnum.fromRoleName("ROLE_ADMIN");
```

#### `fromId(Long id)`

Tìm RoleEnum theo ID.

```java
RoleEnum role = RoleEnum.fromId(1L); // Returns ADMIN
```

## Database Setup

### DataInitializer

File `DataInitializer.java` tự động tạo role `ROLE_PENDING_USER` khi khởi động ứng dụng:

```java
createRoleIfNotExists("ROLE_PENDING_USER", "Người dùng chờ duyệt");
```

### Database Schema

Table: `roles`

| ID  | Name              | Description            | Active |
| --- | ----------------- | ---------------------- | ------ |
| 1   | ROLE_ADMIN        | Quản trị viên hệ thống | true   |
| 2   | ROLE_DOCTOR       | Bác sĩ nha khoa        | true   |
| 3   | ROLE_RECEPTIONIST | Lễ tân                 | true   |
| 4   | ROLE_VIEWER       | Người dùng chỉ xem     | true   |
| 5   | ROLE_PENDING_USER | Người dùng chờ duyệt   | true   |

## API Usage

### 1. Register New User (Public)

**Endpoint:** `POST /api/auth/register`

**Default Role:** `ROLE_PENDING_USER` (ID = 5)

**Request:**

```json
{
  "username": "newuser",
  "password": "password123",
  "email": "newuser@example.com",
  "fullName": "Nguyen Van A",
  "phoneNumber": "0912345678"
}
```

**Response:**

```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 86400,
  "user": {
    "id": 10,
    "username": "newuser",
    "email": "newuser@example.com",
    "fullName": "Nguyen Van A",
    "roles": ["ROLE_PENDING_USER"]
  }
}
```

**Logic:**

```java
// AuthService.register()
Role pendingUserRole = roleRepository.findByName(RoleEnum.getDefaultRole().getRoleName())
        .orElseThrow(() -> new RuntimeException("Không tìm thấy role mặc định"));
```

### 2. Create New User (Admin)

**Endpoint:** `POST /api/users`

**Default Role (if not specified):** `ROLE_PENDING_USER` (ID = 5)

#### Case 1: Without specifying roles

**Request:**

```json
{
  "username": "doctor2",
  "password": "doctor123",
  "email": "doctor2@dentalclinic.com",
  "fullName": "Bác sĩ Trần Văn B",
  "phoneNumber": "0923456789",
  "active": true
}
```

**Result:** User được tạo với role `ROLE_PENDING_USER`

#### Case 2: With specified roles

**Request:**

```json
{
  "username": "doctor2",
  "password": "doctor123",
  "email": "doctor2@dentalclinic.com",
  "fullName": "Bác sĩ Trần Văn B",
  "phoneNumber": "0923456789",
  "active": true,
  "roleNames": ["ROLE_DOCTOR"]
}
```

**Result:** User được tạo với role `ROLE_DOCTOR`

**Logic:**

```java
// UserService.createUser()
if (request.getRoleNames() != null && !request.getRoleNames().isEmpty()) {
    // Use specified roles
} else {
    // Use default role: ROLE_PENDING_USER
    Role defaultRole = roleRepository.findByName(RoleEnum.getDefaultRole().getRoleName())
            .orElseThrow(() -> new RuntimeException("Default role not found"));
}
```

## Workflow: User Approval Process

### Step 1: User Registration

User đăng ký tài khoản mới → Hệ thống tự động gán role `ROLE_PENDING_USER`

### Step 2: Admin Review

Admin xem danh sách user với role `ROLE_PENDING_USER` và duyệt/từ chối

### Step 3: Role Assignment

Admin cập nhật role cho user đã được duyệt:

**Update User API:**

```http
PUT /api/users/{id}
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "username": "doctor2",
  "email": "doctor2@dentalclinic.com",
  "fullName": "Bác sĩ Trần Văn B",
  "phoneNumber": "0923456789",
  "active": true,
  "roleNames": ["ROLE_DOCTOR"]
}
```

### Step 4: User Login

User đăng nhập với role mới được gán

## Testing

### Test 1: Register with Default Role

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "test123",
    "email": "test@example.com",
    "fullName": "Test User",
    "phoneNumber": "0912345678"
  }'
```

**Expected:** User được tạo với `roles: ["ROLE_PENDING_USER"]`

### Test 2: Create User Without Roles

```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {admin_token}" \
  -d '{
    "username": "testuser2",
    "password": "test123",
    "email": "test2@example.com",
    "fullName": "Test User 2",
    "phoneNumber": "0923456789",
    "active": true
  }'
```

**Expected:** User được tạo với role `ROLE_PENDING_USER`

### Test 3: Create User With Specific Role

```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {admin_token}" \
  -d '{
    "username": "doctor3",
    "password": "doctor123",
    "email": "doctor3@dentalclinic.com",
    "fullName": "Bác sĩ Lê Văn C",
    "phoneNumber": "0934567890",
    "active": true,
    "roleNames": ["ROLE_DOCTOR"]
  }'
```

**Expected:** User được tạo với role `ROLE_DOCTOR`

## Frontend Integration

### Check User Role

```dart
// Model
class UserInfo {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final List<String> roles;

  bool get isPendingUser => roles.contains('ROLE_PENDING_USER');
  bool get isAdmin => roles.contains('ROLE_ADMIN');
  bool get isDoctor => roles.contains('ROLE_DOCTOR');
}

// Usage
if (currentUser.isPendingUser) {
  showPendingApprovalDialog();
}
```

### Display Role Badge

```dart
Widget buildRoleBadge(List<String> roles) {
  if (roles.contains('ROLE_PENDING_USER')) {
    return Chip(
      label: Text('Chờ duyệt'),
      backgroundColor: Colors.orange,
    );
  } else if (roles.contains('ROLE_ADMIN')) {
    return Chip(
      label: Text('Admin'),
      backgroundColor: Colors.red,
    );
  }
  // ... other roles
}
```

### Filter Users by Role

```dart
// Get pending users for admin approval
Future<List<User>> getPendingUsers() async {
  final allUsers = await userService.getAllUsers();
  return allUsers.where((user) =>
    user.roles.contains('ROLE_PENDING_USER')
  ).toList();
}
```

## Security Considerations

1. **Default Role:** Mặc định là `ROLE_PENDING_USER` - quyền hạn thấp nhất, cần admin duyệt
2. **Permission Check:** Kiểm tra role trước khi cho phép truy cập tài nguyên
3. **Admin Only:** Chỉ admin có thể thay đổi role của user
4. **Audit Log:** Ghi log khi thay đổi role (nên implement)

## Migration Notes

Nếu database đã có user với role cũ, cần migration:

```sql
-- Add new role if not exists
INSERT INTO roles (name, description, active, created_at, updated_at)
VALUES ('ROLE_PENDING_USER', N'Người dùng chờ duyệt', 1, GETDATE(), GETDATE())
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_PENDING_USER');

-- Optional: Update existing ROLE_VIEWER users to ROLE_PENDING_USER
-- (Only if you want to change business logic)
```

## Summary

✅ **Default Role:** `ROLE_PENDING_USER` (ID = 5)
✅ **Auto-created:** Role được tạo tự động khi khởi động app
✅ **Register API:** Tự động gán `ROLE_PENDING_USER`
✅ **Create User API:** Gán `ROLE_PENDING_USER` nếu không chỉ định role
✅ **Enum-based:** Sử dụng `RoleEnum` để quản lý constants
✅ **Type-safe:** Compile-time checking với enum
