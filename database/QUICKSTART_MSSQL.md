# Quick Start: Chuyển từ H2 sang MSSQL

## TL;DR - 3 Bước Nhanh

### 1️⃣ Tạo Database (30 giây)

Mở **SQL Server Management Studio (SSMS)** → chạy file này:

```bash
setup-database.sql
```

Nhấn **F5**. Xong!

### 2️⃣ Verify Connection

```sql
USE DentalClinicDB;
SELECT name FROM sys.databases WHERE name = 'DentalClinicDB';
```

Thấy kết quả → OK ✅

### 3️⃣ Chạy Application

```bash
mvn spring-boot:run
```

Application tự động:

- ✅ Connect vào MSSQL
- ✅ Tạo tất cả tables
- ✅ Insert dữ liệu mẫu (roles + admin user)

---

## Thông Tin Kết Nối

| Thông tin     | Giá trị              |
| ------------- | -------------------- |
| **Server**    | `localhost` hoặc `.` |
| **Database**  | `DentalClinicDB`     |
| **Username**  | `sa`                 |
| **Password**  | `admin123`           |
| **Port**      | `1433` (default)     |
| **Auth Type** | SQL Authentication   |

---

## File Configs

### application.yml (Đã config sẵn MSSQL)

```yaml
datasource:
  url: jdbc:sqlserver://localhost:1433;databaseName=DentalClinicDB;encrypt=true;trustServerCertificate=true
  username: sa
  password: admin123
```

### Profiles (Tuỳ chọn)

```bash
# Production (MSSQL) - Mặc định
mvn spring-boot:run

# Development (H2) - Để test nhanh
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

---

## Kiểm Tra Tables Đã Tạo

```sql
USE DentalClinicDB;

-- Xem tất cả tables
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Kiểm tra dữ liệu
SELECT * FROM roles;
SELECT * FROM users;
```

Expected output:

- **4 roles:** ROLE_ADMIN, ROLE_DOCTOR, ROLE_RECEPTIONIST, ROLE_VIEWER
- **1 user:** admin (username: `admin`, password: `admin123`)

---

## Test API

### 1. Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 2. Get Users (với token)

```bash
curl http://localhost:8080/api/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Troubleshooting Nhanh

| Lỗi                   | Fix                                         |
| --------------------- | ------------------------------------------- |
| ❌ Cannot connect     | Check SQL Server đang chạy (`services.msc`) |
| ❌ Login failed       | Chạy lại `setup-database.sql`               |
| ❌ Database not found | Chạy lại `setup-database.sql`               |
| ❌ Port 1433 refused  | Bật TCP/IP trong SQL Configuration Manager  |

---

## Đổi về H2 (Nếu cần)

```bash
# Chạy với H2 in-memory
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Truy cập H2 Console
http://localhost:8080/h2-console
```

---

## Chi Tiết Đầy Đủ

📖 [DATABASE_SETUP.md](./DATABASE_SETUP.md) - Hướng dẫn chi tiết  
📖 [README.md](./README.md) - Tài liệu đầy đủ API

---

**Lưu ý:**

- File `application.yml` đã config sẵn MSSQL, bạn không cần đổi gì!
- Nếu muốn dùng Windows Authentication, xem [DATABASE_SETUP.md](./DATABASE_SETUP.md)
