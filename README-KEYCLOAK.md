# Keycloak Setup Guide - Standalone Version

## Yêu cầu hệ thống

- **Java 17 hoặc cao hơn** (Download tại: https://adoptium.net/)
- **Windows 10/11**
- **MSSQL Server** đang chạy

## Cấu trúc thư mục

```
Mobile-DentalClinic-Management/
├── keycloak/              # Thư mục chứa Keycloak
│   ├── bin/
│   │   ├── kc.bat        # Script chạy Keycloak trên Windows
│   │   └── kc.sh         # Script chạy Keycloak trên Linux/Mac
│   ├── conf/             # File cấu hình
│   ├── lib/              # Thư viện Java
│   ├── providers/        # Custom providers
│   └── data/             # Database và logs (không commit lên Git)
├── start-keycloak.bat    # Script khởi động nhanh (Windows)
└── README-KEYCLOAK.md    # File này
```

## Hướng dẫn cài đặt (Lần đầu tiên)

### Bước 1: Download Keycloak

1. Tải Keycloak phiên bản **23.0.7** từ trang chính thức:

   - Link: https://github.com/keycloak/keycloak/releases/download/23.0.7/keycloak-23.0.7.zip
   - Hoặc: https://www.keycloak.org/downloads

2. Giải nén file zip vào thư mục dự án với tên `keycloak`:
   ```
   Mobile-DentalClinic-Management/keycloak/
   ```

### Bước 2: Tạo file start-keycloak.bat

Tạo file `start-keycloak.bat` trong thư mục dự án với nội dung:

```batch
@echo off
echo Starting Keycloak Server...
echo Admin Console: http://localhost:8080
echo Username: admin
echo Password: admin
echo.
echo Press Ctrl+C to stop
echo ========================================

set KEYCLOAK_ADMIN=admin
set KEYCLOAK_ADMIN_PASSWORD=admin

cd keycloak\bin
call kc.bat start-dev --http-port=8080
```

### Bước 3: Commit Keycloak lên Git

```bash
git add keycloak/
git add start-keycloak.bat
git add README-KEYCLOAK.md
git commit -m "Add Keycloak standalone server"
git push
```

**Lưu ý**: Chỉ commit Keycloak binary, KHÔNG commit thư mục `keycloak/data/` (đã có trong .gitignore)

## Hướng dẫn sử dụng (Cho người clone project)

### Khởi động Keycloak

**Cách 1: Dùng file .bat**

```bash
.\start-keycloak.bat
```

**Cách 2: Chạy trực tiếp**

```bash
cd keycloak\bin
.\kc.bat start-dev --http-port=8080
```

**Cách 3: Dùng PowerShell**

```powershell
$env:KEYCLOAK_ADMIN="admin"
$env:KEYCLOAK_ADMIN_PASSWORD="admin"
cd keycloak\bin
.\kc.bat start-dev --http-port=8080
```

### Truy cập Keycloak Admin Console

- **URL**: http://localhost:8080
- **Username**: `admin`
- **Password**: `admin`

### Dừng Keycloak

Nhấn `Ctrl+C` trong terminal đang chạy Keycloak

## Cấu hình Realm (Lần đầu tiên sau khi clone)

### 1. Tạo Realm

1. Login vào Admin Console: http://localhost:8080
2. Click dropdown "master" → "Create Realm"
3. **Realm name**: `dental-clinic`
4. Click "Create"

### 2. Tạo Client

1. Vào **Clients** → Click "Create client"
2. **General Settings**:
   - Client ID: `dental-clinic-api`
   - Client authentication: ON
   - Click "Next"
3. **Capability config**:
   - ☑ Standard flow
   - ☑ Direct access grants
   - ☑ Service accounts roles
   - Click "Next"
4. **Login settings**:
   - Root URL: `http://localhost:8081`
   - Valid redirect URIs:
     - `http://localhost:8081/*`
     - `http://localhost:3000/*`
   - Web origins:
     - `http://localhost:8081`
     - `http://localhost:3000`
   - Click "Save"

### 3. Lấy Client Secret

1. Vào **Clients** → `dental-clinic-api` → tab **Credentials**
2. Copy **Client Secret**
3. Mở file `src/main/resources/application.yml`
4. Thay `<YOUR_CLIENT_SECRET>` bằng client secret vừa copy:
   ```yaml
   spring:
     security:
       oauth2:
         client:
           registration:
             keycloak:
               client-secret: <PASTE_SECRET_HERE>
   ```

### 4. Tạo Roles

Vào **Realm roles** → Click "Create role", tạo các roles sau:

- `ADMIN` - Quản trị viên hệ thống
- `DIRECTOR` - Giám đốc chi nhánh
- `DOCTOR` - Bác sĩ
- `RECEPTIONIST` - Lễ tân
- `ACCOUNTANT` - Kế toán
- `TECHNICIAN` - Kỹ thuật viên
- `PATIENT` - Bệnh nhân

### 5. Tạo Test User

1. Vào **Users** → Click "Add user"
2. Thông tin user:

   - Username: `admin`
   - Email: `admin@dentalclinic.com`
   - First name: `System`
   - Last name: `Administrator`
   - Email verified: ON
   - Click "Create"

3. Set password:

   - Vào tab **Credentials**
   - Click "Set password"
   - Password: `Admin@123`
   - Temporary: OFF
   - Click "Save"

4. Assign role:
   - Vào tab **Role mapping**
   - Click "Assign role"
   - Chọn `ADMIN`
   - Click "Assign"

## Testing

### 1. Get Access Token

```powershell
curl -X POST http://localhost:8080/realms/dental-clinic/protocol/openid-connect/token `
  -H "Content-Type: application/x-www-form-urlencoded" `
  -d "grant_type=password" `
  -d "client_id=dental-clinic-api" `
  -d "client_secret=YOUR_CLIENT_SECRET" `
  -d "username=admin" `
  -d "password=Admin@123"
```

### 2. Test API

```powershell
# Get current user info
curl -H "Authorization: Bearer ACCESS_TOKEN" http://localhost:8081/api/auth/me

# Get user roles
curl -H "Authorization: Bearer ACCESS_TOKEN" http://localhost:8081/api/auth/roles

# Health check
curl http://localhost:8081/api/auth/health
```

## Troubleshooting

### Lỗi: "Java not found"

**Giải pháp**: Cài đặt Java 17+

```powershell
# Kiểm tra Java
java -version

# Download tại: https://adoptium.net/
```

### Lỗi: "Port 8080 already in use"

**Giải pháp 1**: Dừng process đang dùng port 8080

```powershell
# Tìm process
netstat -ano | findstr :8080

# Kill process (thay PID)
taskkill /PID <PID> /F
```

**Giải pháp 2**: Đổi port Keycloak

```batch
.\kc.bat start-dev --http-port=8081
```

### Lỗi: "Cannot connect to Keycloak"

**Checklist**:

- [ ] Keycloak đang chạy? Check terminal có output logs
- [ ] URL đúng? http://localhost:8080 (không phải 8081)
- [ ] Realm "dental-clinic" đã tạo chưa?
- [ ] Client "dental-clinic-api" đã tạo chưa?

### Lỗi: "Invalid client secret"

**Giải pháp**:

1. Vào Keycloak Admin Console
2. Clients → dental-clinic-api → Credentials
3. Copy lại Client Secret
4. Update vào application.yml

## Export/Import Realm Configuration (Advanced)

### Export Realm để chia sẻ config

```bash
cd keycloak\bin
kc.bat export --dir ../data/export --realm dental-clinic
```

### Import Realm khi clone project

```bash
cd keycloak\bin
kc.bat import --dir ../data/import --realm dental-clinic
```

**Lưu ý**: Có thể commit file export để người khác import nhanh

## Tài liệu tham khảo

- [Keycloak Official Documentation](https://www.keycloak.org/documentation)
- [Getting Started Guide](https://www.keycloak.org/getting-started/getting-started-zip)
- [Server Installation Guide](https://www.keycloak.org/server/installation)

---

**Phiên bản Keycloak**: 23.0.7  
**Cập nhật lần cuối**: 2024
