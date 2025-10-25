# Environment Variables Setup Guide

## Tổng quan

Dự án sử dụng file `.env` để lưu trữ các thông tin nhạy cảm như client secret, database credentials, etc.

## Cấu trúc Files

```
Mobile-DentalClinic-Management/
├── .env                    # File chứa secrets thực (không commit lên Git)
├── .env.example            # File template (commit lên Git)
└── src/main/resources/
    └── application.yml     # Đọc biến từ .env
```

## Setup cho Developer mới

### Bước 1: Tạo file .env

Copy file template:

```bash
cp .env.example .env
```

Hoặc tạo file `.env` với nội dung:

```properties
# Keycloak Configuration
KEYCLOAK_CLIENT_SECRET=your-client-secret-here
KEYCLOAK_AUTH_SERVER_URL=http://localhost:8080
KEYCLOAK_REALM=dental-clinic
KEYCLOAK_CLIENT_ID=dental-clinic-api
```

### Bước 2: Lấy Client Secret từ Keycloak

1. Khởi động Keycloak: `.\start-keycloak.bat`
2. Truy cập Admin Console: http://localhost:8080
3. Login: admin / admin
4. Vào: Clients → dental-clinic-api → tab Credentials
5. Copy Client Secret
6. Paste vào file `.env`:
   ```properties
   KEYCLOAK_CLIENT_SECRET=d7q6Yl6Avn2UlYCwPZ1h8LeL4cLZ6bWt
   ```

### Bước 3: Verify

Kiểm tra file `.env` đã đúng format:

```properties
# Đúng ✅
KEYCLOAK_CLIENT_SECRET=d7q6Yl6Avn2UlYCwPZ1h8LeL4cLZ6bWt

# Sai ❌ - có dấu ngoặc kép
KEYCLOAK_CLIENT_SECRET="d7q6Yl6Avn2UlYCwPZ1h8LeL4cLZ6bWt"

# Sai ❌ - có khoảng trắng
KEYCLOAK_CLIENT_SECRET = d7q6Yl6Avn2UlYCwPZ1h8LeL4cLZ6bWt
```

## Cách Spring Boot đọc .env

Spring Boot tự động load file `.env` trong thư mục root của project khi khởi động.

Các biến trong `.env` sẽ được inject vào `application.yml`:

```yaml
# application.yml
spring:
  security:
    oauth2:
      client:
        registration:
          keycloak:
            client-secret: ${KEYCLOAK_CLIENT_SECRET} # ← Đọc từ .env
```

## Environment Variables

### Keycloak

| Variable                   | Description               | Example                            |
| -------------------------- | ------------------------- | ---------------------------------- |
| `KEYCLOAK_CLIENT_SECRET`   | Client secret từ Keycloak | `d7q6Yl6Avn2UlYCwPZ1h8LeL4cLZ6bWt` |
| `KEYCLOAK_AUTH_SERVER_URL` | URL của Keycloak server   | `http://localhost:8080`            |
| `KEYCLOAK_REALM`           | Tên realm                 | `dental-clinic`                    |
| `KEYCLOAK_CLIENT_ID`       | Client ID                 | `dental-clinic-api`                |

### Database (Future)

| Variable      | Description            | Example                |
| ------------- | ---------------------- | ---------------------- |
| `DB_URL`      | JDBC connection string | `jdbc:sqlserver://...` |
| `DB_USERNAME` | Database username      | `sa`                   |
| `DB_PASSWORD` | Database password      | `YourPassword123`      |

## Chạy ứng dụng

### Development

```bash
# Spring Boot tự động đọc .env
.\mvnw spring-boot:run
```

### Production

```bash
# Set environment variables trực tiếp
$env:KEYCLOAK_CLIENT_SECRET="production-secret"
$env:KEYCLOAK_AUTH_SERVER_URL="https://auth.dentalclinic.com"

# Hoặc dùng file .env (Windows)
Get-Content .env | ForEach-Object {
    $name, $value = $_.split('=')
    Set-Content env:\$name $value
}

# Chạy ứng dụng
.\mvnw spring-boot:run
```

## Security Best Practices

### ✅ DO (Nên làm)

- ✅ Commit `.env.example` lên Git (template)
- ✅ Add `.env` vào `.gitignore` (đã có sẵn)
- ✅ Dùng secrets khác nhau cho dev/staging/production
- ✅ Rotate client secret định kỳ
- ✅ Giữ `.env` ở root project (Spring Boot tự động tìm)

### ❌ DON'T (Không nên)

- ❌ Commit `.env` lên Git
- ❌ Share `.env` qua chat/email
- ❌ Hardcode secrets trong code
- ❌ Dùng cùng secret cho dev và production
- ❌ Push `.env` lên public repository

## Troubleshooting

### Lỗi: "Could not resolve placeholder 'KEYCLOAK_CLIENT_SECRET'"

**Nguyên nhân**: Spring Boot không tìm thấy file `.env` hoặc biến không tồn tại

**Giải pháp**:

1. Kiểm tra file `.env` có tồn tại trong root project
2. Kiểm tra tên biến đúng (case-sensitive)
3. Restart application sau khi sửa `.env`

### Lỗi: "Invalid client credentials"

**Nguyên nhân**: Client secret sai hoặc đã expired

**Giải pháp**:

1. Vào Keycloak Admin Console
2. Clients → dental-clinic-api → Credentials
3. Copy lại Client Secret mới
4. Update vào file `.env`
5. Restart application

### File .env không được load

**Giải pháp**:

1. Đảm bảo file `.env` ở đúng vị trí (root project)
2. Check format file (không có BOM, UTF-8 encoding)
3. Verify Spring Boot version >= 2.4 (đang dùng 3.5.6 - OK)

## IDE Integration

### VS Code

1. Install extension: **DotENV**
2. File `.env` sẽ có syntax highlighting
3. Autocomplete cho environment variables

### IntelliJ IDEA

1. Install plugin: **EnvFile**
2. Run Configuration → EnvFile tab → Add `.env` file
3. Variables sẽ được load khi debug/run

## Sharing với Team

Khi onboard developer mới:

1. Clone project
2. Copy `.env.example` thành `.env`
3. Lấy client secret từ team lead hoặc Keycloak
4. Update vào `.env`
5. Run project: `.\mvnw spring-boot:run`

**Lưu ý**: Mỗi developer có thể dùng client secret khác nhau nếu cần (tạo nhiều clients trong Keycloak).

## Production Deployment

Với production, không dùng file `.env`, mà set trực tiếp environment variables:

### Docker

```dockerfile
ENV KEYCLOAK_CLIENT_SECRET=production-secret
ENV KEYCLOAK_AUTH_SERVER_URL=https://auth.dentalclinic.com
```

### Azure App Service

```bash
az webapp config appsettings set --name myapp --resource-group mygroup \
  --settings KEYCLOAK_CLIENT_SECRET=production-secret
```

### Kubernetes

```yaml
env:
  - name: KEYCLOAK_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: keycloak-secrets
        key: client-secret
```

---

**Cập nhật**: 2024  
**Spring Boot Version**: 3.5.6
