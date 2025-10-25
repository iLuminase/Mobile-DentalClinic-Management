# MSSQL Server Configuration Guide

## Yêu cầu:

1. MSSQL Server đã cài đặt
2. SQL Server Configuration Manager đã bật TCP/IP
3. Windows Authentication được enable

## Các bước cấu hình:

### 1. Tải sqljdbc_auth.dll (Windows Authentication)

Để sử dụng Windows Authentication, bạn cần file `sqljdbc_auth.dll`:

**Tự động** (Maven đã tải):

- File DLL nằm trong dependency `mssql-jdbc`
- Đường dẫn: `%USERPROFILE%\.m2\repository\com\microsoft\sqlserver\mssql-jdbc\{version}\auth\x64\`

**Cấu hình JVM** (chọn 1 trong 3 cách):

#### Cách 1: Thêm vào PATH

```bash
setx PATH "%PATH%;%USERPROFILE%\.m2\repository\com\microsoft\sqlserver\mssql-jdbc\12.8.1.jre11\auth\x64"
```

#### Cách 2: VM Options trong IDE

```
-Djava.library.path=C:\Users\{YourUser}\.m2\repository\com\microsoft\sqlserver\mssql-jdbc\12.8.1.jre11\auth\x64
```

#### Cách 3: Copy vào System32

```bash
copy "%USERPROFILE%\.m2\repository\com\microsoft\sqlserver\mssql-jdbc\12.8.1.jre11\auth\x64\sqljdbc_auth.dll" C:\Windows\System32\
```

### 2. Tạo Database

Mở SQL Server Management Studio (SSMS) và chạy:

```sql
-- Tạo database
CREATE DATABASE dentalclinic_db;
GO

-- Kiểm tra
USE dentalclinic_db;
SELECT DB_NAME() AS CurrentDatabase;
```

### 3. Cấu hình SQL Server

#### Enable TCP/IP:

1. Mở **SQL Server Configuration Manager**
2. Vào **SQL Server Network Configuration** > **Protocols for [Instance Name]**
3. Enable **TCP/IP**
4. Restart SQL Server Service

#### Kiểm tra Windows Authentication:

1. Mở **SSMS**
2. Connect với **Windows Authentication**
3. Kiểm tra user hiện tại:

```sql
SELECT SYSTEM_USER, USER_NAME();
```

### 4. Test Connection

Chạy class test này:

```java
import java.sql.Connection;
import java.sql.DriverManager;

public class TestMSSQLConnection {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://.;databaseName=dentalclinic_db;integratedSecurity=true;encrypt=false;trustServerCertificate=true";

        try (Connection conn = DriverManager.getConnection(url)) {
            System.out.println("✅ Connected successfully!");
            System.out.println("Database: " + conn.getCatalog());
        } catch (Exception e) {
            System.err.println("❌ Connection failed!");
            e.printStackTrace();
        }
    }
}
```

### 5. Common Issues

#### Lỗi: "This driver is not configured for integrated authentication"

- **Nguyên nhân**: Không tìm thấy `sqljdbc_auth.dll`
- **Giải pháp**: Thêm DLL vào PATH hoặc java.library.path

#### Lỗi: "Login failed for user"

- **Nguyên nhân**: User Windows không có quyền truy cập SQL Server
- **Giải pháp**:

```sql
-- Chạy trong SSMS với admin
USE master;
GO
CREATE LOGIN [DOMAIN\Username] FROM WINDOWS;
GO
ALTER SERVER ROLE sysadmin ADD MEMBER [DOMAIN\Username];
GO
```

#### Lỗi: "The TCP/IP connection to the host has failed"

- **Nguyên nhân**: TCP/IP không được enable hoặc SQL Server không chạy
- **Giải pháp**: Enable TCP/IP và restart SQL Server Service

### 6. Connection String Options

```yaml
# Default instance
jdbc:sqlserver://.;databaseName=dentalclinic_db;integratedSecurity=true;encrypt=false;trustServerCertificate=true

# Named instance
jdbc:sqlserver://.\SQLEXPRESS;databaseName=dentalclinic_db;integratedSecurity=true;encrypt=false;trustServerCertificate=true

# Production (với encryption)
jdbc:sqlserver://.;databaseName=dentalclinic_db;integratedSecurity=true;encrypt=true
```

### 7. Hibernate DDL Options

```yaml
spring.jpa.hibernate.ddl-auto: update    # Development (tự động tạo/update tables)
spring.jpa.hibernate.ddl-auto: validate  # Production (chỉ validate schema)
spring.jpa.hibernate.ddl-auto: none      # Production (không làm gì)
```

## Timezone Configuration

MSSQL Server mặc định là UTC. Để sync với Asia/Ho_Chi_Minh:

```yaml
spring:
  datasource:
    url: jdbc:sqlserver://.;databaseName=dentalclinic_db;integratedSecurity=true;encrypt=false;trustServerCertificate=true
  jpa:
    properties:
      hibernate:
        jdbc:
          time_zone: Asia/Ho_Chi_Minh
```

## Monitoring

Enable SQL logging để debug:

```yaml
logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
    com.microsoft.sqlserver: DEBUG
```
