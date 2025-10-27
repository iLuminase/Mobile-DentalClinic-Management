# Hướng dẫn Setup Database MSSQL

## Yêu cầu

- SQL Server 2019 trở lên (Express, Developer, hoặc Standard)
- SQL Server Management Studio (SSMS) hoặc Azure Data Studio

## Bước 1: Tạo Database

### Cách 1: Dùng SQL Server Management Studio (SSMS)

1. Mở SSMS và connect vào SQL Server (server: `localhost` hoặc `.`)
2. Click chuột phải vào **Databases** → chọn **New Database**
3. Nhập tên database: `DentalClinicDB`
4. Để các settings mặc định
5. Click **OK**

### Cách 2: Dùng SQL Script

Mở New Query trong SSMS và chạy script sau:

```sql
-- Tạo database
CREATE DATABASE DentalClinicDB;
GO

-- Sử dụng database
USE DentalClinicDB;
GO

-- Kiểm tra đã tạo thành công
SELECT name FROM sys.databases WHERE name = 'DentalClinicDB';
```

## Bước 2: Tạo Login và User (nếu dùng SQL Authentication)

### Tạo SQL Login với username `sa` và password `admin123`

**Chú ý:** Account `sa` thường đã có sẵn trong SQL Server. Bạn chỉ cần:

1. Click chuột phải vào **Security** → **Logins** → tìm **sa**
2. Nếu chưa có, tạo mới:

```sql
-- Tạo login mới (nếu chưa có sa)
CREATE LOGIN sa
WITH PASSWORD = 'admin123',
CHECK_POLICY = OFF,
CHECK_EXPIRATION = OFF;
GO

-- Hoặc reset password nếu đã có
ALTER LOGIN sa
WITH PASSWORD = 'admin123';
ALTER LOGIN sa ENABLE;
GO

-- Gán quyền vào database
USE DentalClinicDB;
GO

CREATE USER sa FOR LOGIN sa;
GO

-- Gán quyền db_owner (full quyền)
ALTER ROLE db_owner ADD MEMBER sa;
GO
```

## Bước 3: Cấu hình Application

### Option 1: SQL Authentication (đã config sẵn trong `application.yml`)

```yaml
datasource:
  url: jdbc:sqlserver://localhost:1433;databaseName=DentalClinicDB;encrypt=true;trustServerCertificate=true
  username: sa
  password: admin123
```

### Option 2: Windows Authentication

1. **Download sqljdbc_auth.dll:**

   - Tải từ [Microsoft JDBC Driver](https://learn.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server)
   - Chọn version x64 hoặc x86 tùy hệ thống

2. **Copy file vào thư mục:**

   - `C:\Windows\System32\` (cho x64)
   - Hoặc thêm vào `PATH` environment variable

3. **Sửa `application.yml`:**

```yaml
datasource:
  url: jdbc:sqlserver://localhost:1433;databaseName=DentalClinicDB;integratedSecurity=true;encrypt=true;trustServerCertificate=true
  username:
  password:
```

## Bước 4: Chạy Application

1. Đảm bảo SQL Server đang chạy
2. Chạy lệnh:

```bash
mvn clean install
mvn spring-boot:run
```

3. Application sẽ tự động:
   - Connect vào database `DentalClinicDB`
   - Tạo tất cả các tables (users, roles, patients, appointments, v.v.)
   - Insert dữ liệu mẫu (4 roles, admin user)

## Bước 5: Kiểm tra Database

Chạy query sau trong SSMS để kiểm tra:

```sql
USE DentalClinicDB;
GO

-- Xem danh sách tables
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Kiểm tra dữ liệu roles
SELECT * FROM roles;

-- Kiểm tra admin user
SELECT u.username, u.email, r.name as role_name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE u.username = 'admin';
```

## Dữ liệu Mẫu Được Tạo Tự Động

Khi chạy lần đầu, hệ thống sẽ tự động tạo:

### 1. Roles:

- `ROLE_ADMIN` - Quản trị viên (full quyền)
- `ROLE_DOCTOR` - Bác sĩ
- `ROLE_RECEPTIONIST` - Lễ tân
- `ROLE_VIEWER` - Người xem (chỉ đọc)

### 2. Admin User:

- **Username:** `admin`
- **Password:** `admin123`
- **Email:** `admin@dentalclinic.com`
- **Role:** ROLE_ADMIN

## Troubleshooting

### Lỗi: "Login failed for user 'sa'"

- Kiểm tra SQL Server Authentication đã bật:
  - Chuột phải vào Server → Properties → Security → chọn "SQL Server and Windows Authentication mode"
  - Restart SQL Server service

### Lỗi: "Cannot open database 'DentalClinicDB'"

- Đảm bảo đã tạo database theo Bước 1
- Check connection string trong `application.yml`

### Lỗi: "The TCP/IP connection to the host localhost, port 1433 has failed"

- Bật TCP/IP protocol trong SQL Server Configuration Manager
- Restart SQL Server service
- Check firewall cho port 1433

### Lỗi: "This driver is not configured for integrated authentication"

- Cần download và cài đặt `sqljdbc_auth.dll` (xem Bước 3 - Option 2)
- Hoặc dùng SQL Authentication thay vì Windows Auth

## Chuyển sang Production

Khi deploy production, nên:

1. **Đổi `ddl-auto` thành `validate`:**

```yaml
jpa:
  hibernate:
    ddl-auto: validate # Không tự động sửa schema
```

2. **Dùng Flyway hoặc Liquibase** để quản lý migration
3. **Tắt `show-sql`** để tránh log quá nhiều
4. **Dùng connection pool** với HikariCP (Spring Boot mặc định)

## Backup Database

```sql
-- Backup database
BACKUP DATABASE DentalClinicDB
TO DISK = 'C:\Backup\DentalClinicDB.bak'
WITH FORMAT, MEDIANAME = 'SQLServerBackups';
GO

-- Restore database
RESTORE DATABASE DentalClinicDB
FROM DISK = 'C:\Backup\DentalClinicDB.bak'
WITH REPLACE;
GO
```
