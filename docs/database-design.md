# Database Design - Authentication & Authorization System

## Entity Relationship Diagram (ERD)

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│      User       │         │   UserRole      │         │      Role       │
├─────────────────┤         ├─────────────────┤         ├─────────────────┤
│ id (PK)         │────────<│ user_id (FK)    │>────────│ id (PK)         │
│ username        │         │ role_id (FK)    │         │ name            │
│ password        │         │ branch_id (FK)  │         │ description     │
│ full_name       │         │ assigned_at     │         │ created_at      │
│ email           │         │ assigned_by     │         │ updated_at      │
│ phone           │         │ is_active       │         └─────────────────┘
│ date_of_birth   │         └─────────────────┘                 │
│ is_active       │                                             │
│ created_at      │                                             │
│ updated_at      │                                             │
└─────────────────┘                                             │
                                                                │
                                                                │
┌─────────────────┐         ┌─────────────────┐                 │
│   Permission    │         │ RolePermission  │                 │
├─────────────────┤         ├─────────────────┤                 │
│ id (PK)         │────────<│ role_id (FK)    │>────────────────┘
│ name            │         │ permission_id   │
│ code            │         │ created_at      │
│ resource        │         └─────────────────┘
│ action          │
│ description     │
│ created_at      │
└─────────────────┘

┌─────────────────┐
│     Branch      │
├─────────────────┤
│ id (PK)         │
│ name            │
│ address         │
│ phone           │
│ manager_id (FK) │
│ is_active       │
│ created_at      │
│ updated_at      │
└─────────────────┘
         △
         │
         │ (referenced by UserRole.branch_id)
```

## Key Features

### 1. User - Role Relationship (Many-to-Many with Context)

- Một user có thể có nhiều role
- Mỗi role assignment có thể gắn với một branch cụ thể
- VD: User A là "Giám đốc" tại Chi nhánh 1 và "Bác sĩ" tại Chi nhánh 2

### 2. Role - Permission Relationship (Many-to-Many)

- Một role có thể có nhiều permission
- Một permission có thể được gán cho nhiều role
- Dễ dàng thay đổi permission của role mà không ảnh hưởng user

### 3. Permission Structure

- **resource**: Tài nguyên (APPOINTMENT, PATIENT, INVOICE, REPORT, etc.)
- **action**: Hành động (CREATE, READ, UPDATE, DELETE, APPROVE, etc.)
- **code**: Mã unique (VD: APPOINTMENT_CREATE, PATIENT_READ)

### 4. Branch Context

- Phân quyền theo chi nhánh
- User có thể có role khác nhau ở các chi nhánh khác nhau
- Hỗ trợ mô hình multi-tenant/multi-branch

## Example Data

### Roles

- ADMIN: Quản trị viên hệ thống
- DIRECTOR: Giám đốc chi nhánh
- DOCTOR: Bác sĩ
- NURSE: Y tá
- RECEPTIONIST: Lễ tân
- ACCOUNTANT: Kế toán

### Permissions Examples

- APPOINTMENT_CREATE: Tạo lịch hẹn
- APPOINTMENT_READ: Xem lịch hẹn
- APPOINTMENT_UPDATE: Cập nhật lịch hẹn
- APPOINTMENT_DELETE: Xóa lịch hẹn
- PATIENT_CREATE: Tạo bệnh nhân
- PATIENT_READ: Xem thông tin bệnh nhân
- PATIENT_UPDATE: Cập nhật bệnh nhân
- INVOICE_CREATE: Tạo hóa đơn
- INVOICE_APPROVE: Duyệt hóa đơn
- REPORT_VIEW: Xem báo cáo
- REPORT_EXPORT: Xuất báo cáo

### Use Cases

1. **User "John" - Giám đốc Chi nhánh 1**

   - UserRole: user_id=1, role_id=DIRECTOR, branch_id=1
   - Permissions: All permissions for Branch 1

2. **User "John" - Bác sĩ Chi nhánh 2**

   - UserRole: user_id=1, role_id=DOCTOR, branch_id=2
   - Permissions: Limited to doctor permissions at Branch 2

3. **User "Admin" - Admin toàn hệ thống**
   - UserRole: user_id=2, role_id=ADMIN, branch_id=NULL
   - Permissions: All permissions, all branches
