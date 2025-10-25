# Keycloak Authentication Integration

## Tổng quan

Dự án Dental Clinic Management đã được tích hợp với **Keycloak** để xác thực OAuth2/OpenID Connect thay cho authentication cơ bản.

## Các thay đổi đã thực hiện

### 1. Dependencies (pom.xml)

Đã thêm các dependencies sau:

```xml
<!-- OAuth2 Resource Server for JWT validation -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>

<!-- OAuth2 Client for Keycloak integration -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-client</artifactId>
</dependency>
```

### 2. Configuration (application.yml)

Cấu hình Keycloak OAuth2:

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
            client-secret: <YOUR_CLIENT_SECRET>
            authorization-grant-type: authorization_code
            scope: openid, profile, email
        provider:
          keycloak:
            issuer-uri: http://localhost:8080/realms/dental-clinic
```

**Lưu ý**: Bạn cần thay `<YOUR_CLIENT_SECRET>` bằng client secret thực tế từ Keycloak sau khi setup.

### 3. Security Configuration

#### KeycloakSecurityConfig.java

File cấu hình Spring Security mới với:

- **JWT Authentication**: Validate JWT token từ Keycloak
- **Role Mapping**: Map roles từ `realm_access.roles` với prefix `ROLE_`
- **CORS Configuration**: Cho phép Flutter app (localhost:3000) gọi API
- **Stateless Session**: Không sử dụng session, chỉ JWT token
- **Role-based Authorization**:
  - `/api/auth/**` - Public (không cần authentication)
  - `/api/admin/**` - Chỉ ADMIN
  - `/api/doctor/**` - ADMIN hoặc DOCTOR
  - `/api/patient/**` - Authenticated users

### 4. New Controllers

#### KeycloakAuthController.java

Cung cấp các endpoints để làm việc với Keycloak:

| Endpoint             | Method | Description                  | Auth Required |
| -------------------- | ------ | ---------------------------- | ------------- |
| `/api/auth/info`     | GET    | Lấy thông tin Keycloak URLs  | No            |
| `/api/auth/me`       | GET    | Lấy thông tin user hiện tại  | Yes           |
| `/api/auth/validate` | GET    | Validate JWT token           | Yes           |
| `/api/auth/roles`    | GET    | Lấy danh sách roles của user | Yes           |
| `/api/auth/health`   | GET    | Health check                 | No            |

**Ví dụ sử dụng**:

```bash
# Get Keycloak info
curl http://localhost:8081/api/auth/info

# Get current user (với token)
curl -H "Authorization: Bearer <ACCESS_TOKEN>" \
     http://localhost:8081/api/auth/me

# Get user roles
curl -H "Authorization: Bearer <ACCESS_TOKEN>" \
     http://localhost:8081/api/auth/roles
```

### 5. User Synchronization Service

#### KeycloakUserSyncService.java

Service để đồng bộ users từ Keycloak xuống MSSQL database:

**Chức năng chính**:

- `syncUserFromToken(Jwt jwt)`: Tự động tạo/update user khi login
- `getUserFromToken(Jwt jwt)`: Lấy User entity từ JWT token
- `hasRole(Jwt jwt, String role)`: Kiểm tra user có role không
- `getRoles(Jwt jwt)`: Lấy tất cả roles của user

**Logic hoạt động**:

1. User login vào Keycloak → nhận JWT token
2. Frontend gửi request với Bearer token
3. Spring Security validate token với Keycloak
4. `KeycloakUserSyncService` tự động sync user vào database:
   - Nếu user chưa tồn tại → tạo mới
   - Nếu user đã tồn tại → update thông tin

### 6. User Model Update

Đã thêm field `keycloakId` vào User entity:

```java
@Column(name = "keycloak_id", unique = true, length = 100)
private String keycloakId;
```

Field này lưu Keycloak user ID (subject claim từ JWT) để mapping giữa Keycloak và local database.

### 7. Docker Compose Setup

File `docker-compose.yml` để chạy Keycloak + PostgreSQL:

```bash
# Start Keycloak
docker-compose up -d

# Stop Keycloak
docker-compose down

# View logs
docker-compose logs -f keycloak
```

Keycloak Admin Console: http://localhost:8080

- Username: `admin`
- Password: `admin123`

## Quy trình Authentication

### Flow cơ bản

```
┌──────────┐      1. Login Request       ┌──────────┐
│          │ ─────────────────────────> │          │
│  Flutter │                             │ Keycloak │
│   App    │ <───────────────────────── │  Server  │
│          │      2. Access Token        │          │
└──────────┘      (JWT)                  └──────────┘
     │
     │ 3. API Request
     │    Authorization: Bearer <token>
     ▼
┌──────────┐      4. Validate Token      ┌──────────┐
│          │ ─────────────────────────> │          │
│  Spring  │                             │ Keycloak │
│   Boot   │ <───────────────────────── │   JWK    │
│   API    │      5. Token Valid         │          │
└──────────┘                             └──────────┘
     │
     │ 6. Extract User Info
     │    Sync to Database
     ▼
┌──────────┐
│  MSSQL   │
│ Database │
└──────────┘
```

### Chi tiết từng bước

1. **User Login**:

   - Flutter app redirect đến Keycloak login page
   - User nhập username/password
   - Keycloak xác thực và trả về JWT access token

2. **API Request**:

   - Flutter app gửi request với header: `Authorization: Bearer <token>`
   - Spring Security intercept request

3. **Token Validation**:

   - Spring Security validate JWT signature với Keycloak JWK endpoint
   - Kiểm tra token expiration, issuer, audience

4. **User Sync**:
   - Extract user info từ JWT claims
   - `KeycloakUserSyncService` tự động tạo/update user trong database
   - Trả về response cho Flutter app

## Keycloak Setup

Xem hướng dẫn chi tiết tại: [docs/keycloak-setup.md](./docs/keycloak-setup.md)

### Quick Start

1. **Start Keycloak**:

```bash
docker-compose up -d
```

2. **Access Admin Console**: http://localhost:8080

   - Login: admin / admin123

3. **Create Realm**: `dental-clinic`

4. **Create Client**: `dental-clinic-api`

   - Client authentication: ON
   - Standard flow: ON
   - Direct access grants: ON

5. **Create Roles**:

   - ADMIN
   - DIRECTOR
   - DOCTOR
   - RECEPTIONIST
   - ACCOUNTANT
   - TECHNICIAN
   - PATIENT

6. **Create Test User**:

   - Username: admin
   - Password: Admin@123
   - Email: admin@dentalclinic.com
   - Assign role: ADMIN

7. **Copy Client Secret**:
   - Vào Clients → dental-clinic-api → Credentials
   - Copy Client Secret
   - Update vào `application.yml`

## Testing

### 1. Get Access Token

```bash
curl -X POST http://localhost:8080/realms/dental-clinic/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=dental-clinic-api" \
  -d "client_secret=<YOUR_CLIENT_SECRET>" \
  -d "username=admin" \
  -d "password=Admin@123"
```

Response:

```json
{
  "access_token": "eyJhbGci...",
  "expires_in": 1800,
  "refresh_token": "eyJhbGci...",
  "token_type": "Bearer"
}
```

### 2. Call API with Token

```bash
# Get current user
curl -H "Authorization: Bearer <ACCESS_TOKEN>" \
     http://localhost:8081/api/auth/me

# Test admin endpoint
curl -H "Authorization: Bearer <ACCESS_TOKEN>" \
     http://localhost:8081/api/admin/test
```

### 3. Postman Collection

Import Postman collection từ: [postman/Keycloak-Auth.postman_collection.json](./postman/Keycloak-Auth.postman_collection.json) (sẽ tạo sau)

## Migration từ Basic Auth

### Old Code (SecurityConfig.java - deprecated)

```java
// Old basic authentication
http.httpBasic();
http.sessionManagement().sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED);
```

### New Code (KeycloakSecurityConfig.java)

```java
// New JWT authentication
http.oauth2ResourceServer(oauth2 ->
    oauth2.jwt(jwt ->
        jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())
    )
);
http.sessionManagement(session ->
    session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
);
```

### Breaking Changes

1. **Authentication Header**:

   - Old: `Authorization: Basic <base64>`
   - New: `Authorization: Bearer <jwt_token>`

2. **User Principal**:

   - Old: `@AuthenticationPrincipal User user`
   - New: `@AuthenticationPrincipal Jwt jwt`

3. **Role Format**:
   - Old: `@PreAuthorize("hasRole('ADMIN')")`
   - New: `@PreAuthorize("hasRole('ADMIN')")` (vẫn giữ nguyên nhờ JwtAuthenticationConverter)

## Troubleshooting

### 1. Token Invalid

**Error**: `Invalid JWT signature` hoặc `JWT token is expired`

**Solutions**:

- Kiểm tra `issuer-uri` trong application.yml
- Verify Keycloak đang chạy: `docker-compose ps`
- Get token mới (token có expiration time)

### 2. Role Not Working

**Error**: `Access Denied` khi gọi API với role đúng

**Solutions**:

- Kiểm tra role trong Keycloak: http://localhost:8080
- Verify role mapping trong JwtAuthenticationConverter
- Check realm_access.roles trong JWT token (dùng https://jwt.io)

### 3. CORS Error

**Error**: `CORS policy: No 'Access-Control-Allow-Origin' header`

**Solutions**:

- Add origin vào Valid Redirect URIs trong Keycloak client
- Check CORS config trong KeycloakSecurityConfig.java

### 4. User Not Synced

**Error**: User login thành công nhưng không có trong database

**Solutions**:

- Check logs: `KeycloakUserSyncService`
- Verify database connection
- Test sync service: `/api/auth/me`

## Next Steps

### Immediate Tasks

1. ✅ Setup Keycloak server (docker-compose)
2. ✅ Create realm và client
3. ✅ Create test users với roles
4. ✅ Update client secret trong application.yml
5. ✅ Test authentication flow

### Future Enhancements

1. **Refresh Token Handling**: Implement refresh token rotation
2. **Role Hierarchy**: Setup composite roles trong Keycloak
3. **Branch-based Permissions**: Map UserRole entity với Keycloak groups
4. **Social Login**: Enable Google/Facebook login
5. **2FA**: Enable Two-Factor Authentication
6. **Audit Logging**: Log user actions với Keycloak events

## Tài liệu tham khảo

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Spring Security OAuth2 Resource Server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/index.html)
- [JWT.io - JWT Debugger](https://jwt.io/)
- [OAuth 2.0 Flow](https://oauth.net/2/)

## Team

Nếu có thắc mắc hoặc gặp issue, vui lòng:

1. Check [docs/keycloak-setup.md](./docs/keycloak-setup.md)
2. Search existing issues
3. Create new issue với log details

---

**Last Updated**: 2024
**Version**: 1.0.0
