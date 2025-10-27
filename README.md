# Dental Clinic Management System - Backend API

## 📋 Mô tả dự án

Hệ thống quản lý phòng khám nha khoa với JWT Authentication, hỗ trợ quản lý lịch hẹn, bệnh nhân, và phân quyền người dùng.

## 🛠 Công nghệ sử dụng

- **Backend**: Java 21, Spring Boot 3.5.6
- **Security**: JWT (JSON Web Token)
- **Database**: H2 (development), MSSQL (production)
- **Build Tool**: Maven
- **ORM**: Hibernate/JPA

## 👥 Các vai trò trong hệ thống

- **ADMIN**: Quản trị viên - toàn quyền truy cập
- **DOCTOR**: Bác sĩ - xem lịch khám, tạo hồ sơ khám
- **RECEPTIONIST**: Lễ tân - quản lý lịch hẹn, bệnh nhân, hóa đơn
- **VIEWER**: Người dùng chỉ xem - role mặc định khi đăng ký
- **PATIENT**: Bệnh nhân - chỉ là dữ liệu, không có quyền đăng nhập

## 🚀 Cài đặt và chạy

### Yêu cầu

- Java 21 trở lên
- Maven 3.6+

### Chạy ứng dụng

```bash
mvn spring-boot:run
```

Ứng dụng sẽ chạy tại: **http://localhost:8080**

### H2 Console (Development)

- URL: **http://localhost:8080/h2-console**
- JDBC URL: `jdbc:h2:mem:dentalclinic`
- Username: `sa`
- Password: (để trống)

## 🔐 Tài khoản mặc định

### Admin

- **Username**: `admin`
- **Password**: `admin123`

### Doctor (Demo)

- **Username**: `doctor1`
- **Password**: `doctor123`

### Receptionist (Demo)

- **Username**: `receptionist1`
- **Password**: `receptionist123`

## 📡 API Endpoints

### Authentication

#### Register New Account

```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "newuser",
  "password": "password123",
  "email": "newuser@example.com",
  "fullName": "Nguyễn Văn A",
  "phoneNumber": "0912345678"
}
```

**Response:**

```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "tokenType": "Bearer",
  "expiresIn": 86400,
  "user": {
    "id": 4,
    "username": "newuser",
    "email": "newuser@example.com",
    "fullName": "Nguyễn Văn A",
    "roles": ["ROLE_VIEWER"]
  }
}
```

> **Lưu ý**: Người dùng đăng ký mới mặc định được gán role **ROLE_VIEWER** (chỉ có quyền xem). Admin có thể nâng cấp quyền sau.

#### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

**Response:**

```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "tokenType": "Bearer",
  "expiresIn": 86400,
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@dentalclinic.com",
    "fullName": "Administrator",
    "roles": ["ROLE_ADMIN"]
  }
}
```

#### Refresh Token

```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGc..."
}
```

#### Test Authentication

```http
GET /api/auth/me
Authorization: Bearer {accessToken}
```

### User Management (ADMIN only)

#### Get All Users

```http
GET /api/users
Authorization: Bearer {accessToken}
```

#### Get All Doctors (ADMIN, RECEPTIONIST)

```http
GET /api/users/doctors
Authorization: Bearer {accessToken}
```

#### Get User by ID

```http
GET /api/users/{id}
Authorization: Bearer {accessToken}
```

#### Create User

```http
POST /api/users
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "username": "doctor2",
  "password": "password123",
  "email": "doctor2@dentalclinic.com",
  "fullName": "Bác sĩ Trần Văn B",
  "phoneNumber": "0987654321",
  "roleNames": ["ROLE_DOCTOR"],
  "active": true
}
```

#### Update User

```http
PUT /api/users/{id}
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "username": "doctor2",
  "email": "doctor2@dentalclinic.com",
  "fullName": "Bác sĩ Trần Văn B Updated",
  "phoneNumber": "0987654321",
  "roleNames": ["ROLE_DOCTOR", "ROLE_ADMIN"],
  "active": true
}
```

#### Delete User

```http
DELETE /api/users/{id}
Authorization: Bearer {accessToken}
```

#### Assign Roles to User

```http
PUT /api/users/{id}/roles
Authorization: Bearer {accessToken}
Content-Type: application/json

["ROLE_DOCTOR", "ROLE_ADMIN"]
```

## 📊 Database Schema

### Tables

- **users**: Thông tin người dùng (ADMIN, DOCTOR, RECEPTIONIST)
- **roles**: Các vai trò trong hệ thống
- **user_roles**: Bảng liên kết nhiều-nhiều giữa users và roles
- **patients**: Thông tin bệnh nhân (không có quyền đăng nhập)
- **appointments**: Lịch hẹn khám

### Entity Relationships

```
User (1) ----< (N) User_Roles (N) >---- (1) Role
User (1) ----< (N) Appointments (Doctor)
User (1) ----< (N) Patients (Created By)
Patient (1) ----< (N) Appointments
```

## 🔒 JWT Configuration

### Cấu hình trong application.yml

```yaml
jwt:
  secret: MyVerySecureSecretKeyForDentalClinicManagementSystemAtLeast256BitsLong12345
  expiration: 86400000 # 24 hours
  refresh-expiration: 604800000 # 7 days
```

### Sử dụng JWT Token

Tất cả các endpoints (trừ `/api/auth/**`) yêu cầu JWT token trong header:

```
Authorization: Bearer {your-jwt-token}
```

## ⚙️ Business Rules

### Lịch hẹn (Appointments)

- Mỗi lịch hẹn mặc định 30 phút
- Kiểm tra trùng giờ bác sĩ khi đặt lịch
- Bệnh nhân phải hoàn thành lịch cũ mới đặt tiếp
- Bác sĩ/Lễ tân có thể kết thúc lịch hẹn sớm

### Bệnh nhân (Patients)

- Không có quyền đăng nhập
- Được tạo bởi RECEPTIONIST hoặc ADMIN
- Lưu trữ thông tin y tế, dị ứng, tiền sử bệnh

### Phân quyền

- User có thể có nhiều roles
- Mỗi endpoint có yêu cầu role riêng
- Sử dụng `@PreAuthorize` để kiểm tra quyền

## 🧪 Testing với cURL

### 1. Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 2. Get All Users (với token)

```bash
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 3. Create New Doctor

```bash
curl -X POST http://localhost:8080/api/users \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "doctor3",
    "password": "password123",
    "email": "doctor3@dentalclinic.com",
    "fullName": "Bác sĩ Nguyễn C",
    "roleNames": ["ROLE_DOCTOR"],
    "active": true
  }'
```

## 📝 Next Steps (Phase 2-4)

### Phase 2: Patient & Appointment Management

- [ ] CRUD APIs cho Patient
- [ ] CRUD APIs cho Appointment
- [ ] Business logic: check trùng giờ bác sĩ
- [ ] Business logic: check bệnh nhân hoàn thành lịch cũ

### Phase 3: Medical Records & Services

- [ ] Entity và APIs cho Medical Records
- [ ] Entity và APIs cho Services (dịch vụ nha khoa)
- [ ] Tự động tạo Medical Record khi appointment COMPLETED

### Phase 4: Invoices & Payments

- [ ] Entity và APIs cho Invoices
- [ ] Hỗ trợ thanh toán một phần
- [ ] Tự động tạo invoice sau appointment

## 📄 License

MIT License

## 👨‍💻 Author

Dental Clinic Management Team
