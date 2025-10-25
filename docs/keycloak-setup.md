# Keycloak Setup Guide for Dental Clinic Management

## Tổng quan

Hướng dẫn cài đặt và cấu hình Keycloak để xác thực OAuth2/OIDC cho hệ thống quản lý phòng khám nha khoa.

## 1. Cài đặt Keycloak với Docker Compose

### Tạo file docker-compose.yml

```yaml
version: "3.8"

services:
  postgres:
    image: postgres:15
    container_name: dental-keycloak-db
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: keycloak123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - keycloak-network
    ports:
      - "5433:5432" # Tránh conflict với MSSQL

  keycloak:
    image: quay.io/keycloak/keycloak:23.0
    container_name: dental-keycloak
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: keycloak123
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin123
      KC_HTTP_PORT: 8080
      KC_HOSTNAME_STRICT: false
      KC_HOSTNAME_STRICT_HTTPS: false
      KC_HTTP_ENABLED: true
    command:
      - start-dev
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    networks:
      - keycloak-network

volumes:
  postgres_data:

networks:
  keycloak-network:
    driver: bridge
```

### Khởi động Keycloak

```powershell
# Di chuyển đến thư mục dự án
cd d:\LapTrinhMobile\DoAn\Mobile-DentalClinic-Management

# Khởi động Docker Compose
docker-compose up -d

# Kiểm tra trạng thái
docker-compose ps

# Xem logs
docker-compose logs -f keycloak
```

Truy cập Keycloak Admin Console: http://localhost:8080

- Username: `admin`
- Password: `admin123`

## 2. Cấu hình Keycloak Realm

### Tạo Realm mới

1. Vào Admin Console: http://localhost:8080
2. Đăng nhập với admin/admin123
3. Click vào dropdown "master" (góc trên trái)
4. Click "Create Realm"
5. Nhập thông tin:
   - **Realm name**: `dental-clinic`
   - **Enabled**: ON
6. Click "Create"

### Cấu hình Realm Settings

1. Vào **Realm Settings** → **General**

   - Display name: `Dental Clinic Management`
   - Display name HTML: `<b>Dental Clinic</b> Management`
   - Enabled: ON

2. Vào **Realm Settings** → **Login**

   - User registration: OFF (tạo user thủ công)
   - Edit username: ON
   - Forgot password: ON
   - Remember me: ON
   - Email as username: OFF

3. Vào **Realm Settings** → **Tokens**
   - Access Token Lifespan: 30 Minutes
   - SSO Session Idle: 30 Minutes
   - SSO Session Max: 10 Hours

## 3. Tạo Client cho API

1. Vào **Clients** → Click "Create client"

2. **General Settings**:

   - Client type: `OpenID Connect`
   - Client ID: `dental-clinic-api`
   - Name: `Dental Clinic API`
   - Description: `Backend API for Dental Clinic Management`
   - Always display in console: ON

3. **Capability config**:

   - Client authentication: ON
   - Authorization: OFF
   - Authentication flow:
     - ☑ Standard flow
     - ☑ Direct access grants
     - ☐ Implicit flow (không nên dùng)
     - ☑ Service accounts roles

4. **Login settings**:

   - Root URL: `http://localhost:8081`
   - Home URL: `http://localhost:8081`
   - Valid redirect URIs:
     - `http://localhost:8081/*`
     - `http://localhost:3000/*` (Flutter web)
     - `com.dentalclinic.app:/oauth2redirect` (Mobile app)
   - Valid post logout redirect URIs: `http://localhost:8081/*`
   - Web origins:
     - `http://localhost:8081`
     - `http://localhost:3000`

5. Click "Save"

6. Vào tab **Credentials** → Copy **Client secret** (cần cho application.yml)

## 4. Tạo Roles

### Realm Roles (vai trò hệ thống)

1. Vào **Realm roles** → Click "Create role"

Tạo các roles sau:

| Role Name      | Description            |
| -------------- | ---------------------- |
| `ADMIN`        | Quản trị viên hệ thống |
| `DIRECTOR`     | Giám đốc chi nhánh     |
| `DOCTOR`       | Bác sĩ                 |
| `RECEPTIONIST` | Lễ tân                 |
| `ACCOUNTANT`   | Kế toán                |
| `TECHNICIAN`   | Kỹ thuật viên          |
| `PATIENT`      | Bệnh nhân              |

Cho mỗi role:

- **Role name**: Tên role (ví dụ: ADMIN)
- **Description**: Mô tả vai trò
- Click "Save"

### Composite Roles (kế thừa quyền)

Để ADMIN có tất cả quyền:

1. Chọn role **ADMIN**
2. Vào tab **Associated roles**
3. Click "Assign role"
4. Chọn tất cả các roles khác (DIRECTOR, DOCTOR, etc.)
5. Click "Assign"

## 5. Tạo Users

### Tạo Admin User

1. Vào **Users** → Click "Add user"

2. Thông tin user:

   - **Username**: `admin`
   - **Email**: `admin@dentalclinic.com`
   - **First name**: `System`
   - **Last name**: `Administrator`
   - **Email verified**: ON
   - **Enabled**: ON

3. Click "Create"

4. Vào tab **Credentials**:

   - Click "Set password"
   - Password: `Admin@123`
   - Temporary: OFF (không yêu cầu đổi password lần đầu)
   - Click "Save"

5. Vào tab **Role mapping**:
   - Click "Assign role"
   - Filter by realm roles
   - Chọn `ADMIN`
   - Click "Assign"

### Tạo Test Users khác

Tương tự, tạo thêm users để test:

| Username        | Email                          | Roles        | Password         |
| --------------- | ------------------------------ | ------------ | ---------------- |
| `director1`     | director1@dentalclinic.com     | DIRECTOR     | Director@123     |
| `doctor1`       | doctor1@dentalclinic.com       | DOCTOR       | Doctor@123       |
| `receptionist1` | receptionist1@dentalclinic.com | RECEPTIONIST | Receptionist@123 |

## 6. Cấu hình Client Scopes

### Tạo Custom Scope cho Branch Information

1. Vào **Client scopes** → Click "Create client scope"

   - Name: `branch-info`
   - Type: `Default`
   - Display on consent screen: OFF

2. Click "Save"

3. Vào tab **Mappers** → Click "Add mapper" → "By configuration" → "User Attribute"

   - Name: `branch-id`
   - User Attribute: `branch_id`
   - Token Claim Name: `branch_id`
   - Claim JSON Type: `long`
   - Add to ID token: ON
   - Add to access token: ON
   - Add to userinfo: ON

4. Quay lại **Clients** → `dental-clinic-api` → tab **Client scopes**
   - Vào "Add client scope"
   - Chọn `branch-info`
   - Chọn type "Default"

## 7. Cấu hình Application

### Update application.yml

Đã cấu hình sẵn trong file `src/main/resources/application.yml`:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8080/realms/dental-clinic
          jwk-set-uri: http://localhost:8080/realms/dental-clinic/protocol/openid-connect/certs
      client:
        registration:
          keycloak:
            client-id: dental-clinic-api
            client-secret: <YOUR_CLIENT_SECRET_FROM_STEP_3>
            authorization-grant-type: authorization_code
            scope: openid, profile, email
        provider:
          keycloak:
            issuer-uri: http://localhost:8080/realms/dental-clinic
```

**Lưu ý**: Thay `<YOUR_CLIENT_SECRET_FROM_STEP_3>` bằng client secret thực tế từ Keycloak.

## 8. Testing Authentication

### Test bằng Postman

#### 1. Get Access Token

```http
POST http://localhost:8080/realms/dental-clinic/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
&client_id=dental-clinic-api
&client_secret=<YOUR_CLIENT_SECRET>
&username=admin
&password=Admin@123
```

Response:

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 1800,
  "refresh_expires_in": 36000,
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer"
}
```

#### 2. Call API với Token

```http
GET http://localhost:8081/api/auth/me
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 3. Test Role-based Access

```http
GET http://localhost:8081/api/admin/test
Authorization: Bearer <ADMIN_TOKEN>
```

### Test API Endpoints

```powershell
# Get auth info
curl http://localhost:8081/api/auth/info

# Health check
curl http://localhost:8081/api/auth/health

# Get current user (cần token)
curl -H "Authorization: Bearer <ACCESS_TOKEN>" http://localhost:8081/api/auth/me

# Validate token
curl -H "Authorization: Bearer <ACCESS_TOKEN>" http://localhost:8081/api/auth/validate

# Get user roles
curl -H "Authorization: Bearer <ACCESS_TOKEN>" http://localhost:8081/api/auth/roles
```

## 9. User Synchronization

Để đồng bộ users từ Keycloak xuống MSSQL database:

### Option 1: Manual Sync (đơn giản)

Khi user đăng nhập lần đầu, tự động tạo record trong database:

```java
@Service
public class UserSyncService {

    @Transactional
    public User syncUserFromKeycloak(Jwt jwt) {
        String keycloakId = jwt.getSubject();
        String username = jwt.getClaim("preferred_username");
        String email = jwt.getClaim("email");

        return userRepository.findByKeycloakId(keycloakId)
            .orElseGet(() -> {
                User newUser = new User();
                newUser.setKeycloakId(keycloakId);
                newUser.setUsername(username);
                newUser.setEmail(email);
                newUser.setActive(true);
                return userRepository.save(newUser);
            });
    }
}
```

### Option 2: Webhook (tự động)

Cấu hình Keycloak gửi webhook khi có thay đổi user (nâng cao).

## 10. Troubleshooting

### Lỗi thường gặp

#### 1. Cannot connect to Keycloak

```
Error: Connection refused: localhost:8080
```

**Giải pháp**:

- Kiểm tra Docker đang chạy: `docker-compose ps`
- Xem logs: `docker-compose logs keycloak`
- Restart: `docker-compose restart keycloak`

#### 2. Invalid token

```
Error: JWT signature does not match
```

**Giải pháp**:

- Kiểm tra issuer-uri trong application.yml
- Verify realm name: `dental-clinic`
- Check client secret

#### 3. CORS Error

```
Access to XMLHttpRequest blocked by CORS policy
```

**Giải pháp**:

- Thêm origin vào Valid redirect URIs trong Keycloak client
- Kiểm tra CORS config trong KeycloakSecurityConfig.java

### Useful Commands

```powershell
# Stop Keycloak
docker-compose down

# Stop và xóa data
docker-compose down -v

# Restart Keycloak
docker-compose restart keycloak

# View logs
docker-compose logs -f keycloak

# Access Keycloak container
docker exec -it dental-keycloak bash
```

## 11. Production Deployment

### Cấu hình Production

1. **Sử dụng HTTPS**: Cấu hình SSL certificate
2. **External Database**: Sử dụng PostgreSQL/MSSQL riêng, không dùng container
3. **Environment Variables**: Không hardcode passwords
4. **Backup**: Backup Keycloak database định kỳ

### Environment Variables cho Production

```yaml
# application-prod.yml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${KEYCLOAK_ISSUER_URI}
      client:
        registration:
          keycloak:
            client-id: ${KEYCLOAK_CLIENT_ID}
            client-secret: ${KEYCLOAK_CLIENT_SECRET}
```

Set environment variables:

```powershell
$env:KEYCLOAK_ISSUER_URI="https://auth.dentalclinic.com/realms/dental-clinic"
$env:KEYCLOAK_CLIENT_ID="dental-clinic-api"
$env:KEYCLOAK_CLIENT_SECRET="<PRODUCTION_SECRET>"
```

## 12. Tài liệu tham khảo

- [Keycloak Official Documentation](https://www.keycloak.org/documentation)
- [Spring Security OAuth2 Resource Server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/index.html)
- [JWT Debugger](https://jwt.io/) - Debug JWT tokens

## Tiếp theo

Sau khi setup Keycloak xong:

1. ✅ Tạo các API endpoints với role-based authorization
2. ✅ Implement UserSyncService để đồng bộ users
3. ✅ Integrate với Flutter mobile app
4. ✅ Thêm refresh token handling
5. ✅ Setup logging và monitoring
