# Hướng dẫn tạo Keycloak Client với Client Secret

## Các bước tạo Client đúng cách

### 1. Xóa Client cũ (nếu cần)

1. Vào **Clients** → chọn `dental-clinic-api`
2. Click tab **Settings**
3. Scroll xuống cuối → Click **"Delete"**
4. Confirm xóa

### 2. Tạo Client mới

#### Step 1: General Settings

1. Vào **Clients** → Click **"Create client"**
2. Điền thông tin:
   - **Client type**: OpenID Connect
   - **Client ID**: `dental-clinic-api`
3. Click **"Next"**

#### Step 2: Capability config ⚠️ QUAN TRỌNG

1. **Client authentication**: ON ← Bật cái này để có Client Secret!
2. **Authorization**: OFF
3. **Authentication flow**:
   - ☑ Standard flow
   - ☑ Direct access grants
   - ☑ Service accounts roles (optional)
4. Click **"Next"**

#### Step 3: Login settings

1. **Root URL**: `http://localhost:8081`
2. **Home URL**: `http://localhost:8081`
3. **Valid redirect URIs**:
   ```
   http://localhost:8081/*
   http://localhost:3000/*
   com.dentalclinic.app:/oauth2redirect
   ```
4. **Valid post logout redirect URIs**:
   ```
   http://localhost:8081/*
   http://localhost:3000/*
   com.dentalclinic.app:/
   ```
5. **Web origins**:
   ```
   http://localhost:8081
   http://localhost:3000
   ```
6. Click **"Save"**

### 3. Lấy Client Secret

Sau khi tạo xong:

1. Sẽ tự động hiển thị tab **"Credentials"** bên cạnh tab "Settings"
2. Click vào tab **"Credentials"**
3. Bạn sẽ thấy:
   - **Client Authenticator**: Client Id and Secret
   - **Client Secret**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
4. Click **Copy** để copy secret

### 4. Update vào application.yml

```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          keycloak:
            client-id: dental-clinic-api
            client-secret: PASTE_YOUR_SECRET_HERE
            authorization-grant-type: authorization_code
            scope: openid,profile,email

keycloak:
  credentials:
    secret: PASTE_YOUR_SECRET_HERE
```

## Tại sao không thấy Client Secret?

❌ **Client authentication = OFF** → Public client (không có secret)
✅ **Client authentication = ON** → Confidential client (có secret)

Client của bạn hiện đang là **Public client**, cần chuyển sang **Confidential client** bằng cách bật "Client authentication" lên.

## Screenshot để tham khảo

Khi tạo client đúng, bạn sẽ thấy:

- Tab **Settings** có section "Access settings" với option "Client authentication: ON"
- Tab **Credentials** xuất hiện và có Client Secret để copy

## Nếu vẫn không thấy option "Client authentication"

Có thể do phiên bản Keycloak khác nhau. Hãy tìm các option tương tự:

- "Access Type" = Confidential (phiên bản cũ)
- "Client authentication" = ON (phiên bản mới)
- "Public client" = OFF

Nếu không tìm thấy, hãy xóa client và tạo lại từ đầu theo hướng dẫn trên!
