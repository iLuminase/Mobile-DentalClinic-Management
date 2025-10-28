# 🦷 Dental Clinic Management System# Dental Clinic Management System - Backend API

Hệ thống quản lý phòng khám nha khoa với phân quyền người dùng, quản lý lịch hẹn, bệnh nhân và menu động.## 📋 Mô tả dự án

---Hệ thống quản lý phòng khám nha khoa với JWT Authentication, hỗ trợ quản lý lịch hẹn, bệnh nhân, và phân quyền người dùng.

## 📋 Tính năng## 🛠 Công nghệ sử dụng

### ✅ Đã hoàn thiện- **Backend**: Java 21, Spring Boot 3.5.6

- **Authentication & Authorization**- **Security**: JWT (JSON Web Token)

  - Đăng ký, đăng nhập với JWT- **Database**: MSSQL Server

  - Phân quyền: Admin, Doctor, Receptionist, Viewer- **Build Tool**: Maven

  - Refresh token mechanism- **ORM**: Hibernate/JPA

- **Quản lý người dùng**## 👥 Các vai trò trong hệ thống

  - CRUD người dùng

  - Phân quyền động- **ADMIN**: Quản trị viên - toàn quyền truy cập

  - Kích hoạt/vô hiệu hóa tài khoản- **DOCTOR**: Bác sĩ - xem lịch khám, tạo hồ sơ khám

  - Quản lý thông tin cá nhân- **RECEPTIONIST**: Lễ tân - quản lý lịch hẹn, bệnh nhân, hóa đơn

- **VIEWER**: Người dùng chỉ xem - role mặc định khi đăng ký

- **Quản lý menu động**- **PATIENT**: Bệnh nhân - chỉ là dữ liệu, không có quyền đăng nhập

  - Menu phân cấp (hierarchy)

  - Phân quyền menu theo role## 🚀 Cài đặt và chạy

  - CRUD menu items

  - Mobile navigation drawer### Yêu cầu

- **Quản lý lịch hẹn**- Java 21 trở lên

  - Tạo, xem, cập nhật lịch hẹn- Maven 3.6+

  - Trạng thái: Pending, Confirmed, Completed, Cancelled- **SQL Server 2019+** (Express, Developer, hoặc Standard)

  - Filter theo trạng thái

### Setup Database MSSQL

- **Quản lý bệnh nhân**

  - CRUD thông tin bệnh nhân#### Bước 1: Tạo Database

  - Lưu trữ: Họ tên, SĐT, email, địa chỉ, ngày sinh

**Cách nhanh nhất:** Chạy file SQL script có sẵn

### 🚧 Đang phát triển

- Hồ sơ bệnh án chi tiết1. Mở **SQL Server Management Studio (SSMS)**

- Quản lý dịch vụ nha khoa2. Connect vào SQL Server (server: `localhost` hoặc `.`)

- Quản lý hóa đơn3. Mở file `setup-database.sql` trong project

- Báo cáo thống kê4. Nhấn **F5** để chạy script

- Lịch làm việc của bác sĩ

- Thông báo real-timeScript sẽ tự động:

---- ✅ Tạo database `DentalClinicDB`

- ✅ Tạo/reset login `sa` với password `admin123`

## 🛠 Công nghệ- ✅ Gán quyền đầy đủ cho user

### Backend**Chi tiết:** Xem file [DATABASE_SETUP.md](./DATABASE_SETUP.md) để biết thêm cách setup chi tiết, Windows Authentication, troubleshooting, v.v.

- **Java 21**

- **Spring Boot 3.5.6**#### Bước 2: Kiểm tra Connection

  - Spring Security

  - Spring Data JPASau khi chạy script, kiểm tra:

  - Spring Validation

- **JWT Authentication**```sql

- **MSSQL Server 2019+**USE DentalClinicDB;

- **Maven 3.6+**GO

### Frontend (Mobile)-- Kiểm tra database đã tạo

- **Flutter 3.x**SELECT name FROM sys.databases WHERE name = 'DentalClinicDB';

- **Dart**```

- **HTTP Client** (dio)

- **State Management** (Provider)### Chạy ứng dụng

- **Material Design 3**

```bash

---mvn spring-boot:run

```

## 🚀 Cài đặt và Chạy

Ứng dụng sẽ chạy tại: **http://localhost:8080**

### Yêu cầu

- Java JDK 21+Khi chạy lần đầu, application sẽ **tự động**:

- Maven 3.6+

- SQL Server 2019+ (Express/Developer/Standard)- ✅ Tạo tất cả tables (users, roles, patients, appointments, menus, v.v.)

- Flutter 3.x (cho mobile app)- ✅ Insert 4 roles (ADMIN, DOCTOR, RECEPTIONIST, VIEWER)

- IDE: IntelliJ IDEA / VS Code- ✅ Tạo admin user (username: `admin`, password: `admin123`)

- ✅ Tạo menu phân quyền (chạy script `insert-menus.sql` trong SSMS)

---

## 🔐 Tài khoản mặc định

### 1. Setup Database

### Admin

**Bước 1:** Mở SQL Server Management Studio (SSMS)

- **Username**: `admin`

**Bước 2:** Connect vào SQL Server (`localhost` hoặc `.`)- **Password**: `admin123`

**Bước 3:** Mở và chạy file `database.sql` (nhấn F5)### Doctor (Demo)

Script sẽ tự động:- **Username**: `doctor1`

- ✅ Tạo database `DentalClinicDB`- **Password**: `doctor123`

- ✅ Tạo login `sa` / password `admin123`

- ✅ Gán quyền đầy đủ### Receptionist (Demo)

**Kiểm tra:**- **Username**: `receptionist1`

sql- **Password**: `receptionist123`

USE DentalClinicDB;

SELECT name FROM sys.databases WHERE name = 'DentalClinicDB';## 📡 API Endpoints

### Authentication

---

#### Register New Account

### 2. Cấu hình Backend

````
```http

**File:** `src/main/resources/application.yml`POST /api/auth/register

Content-Type: application/json

```yaml

spring:{

  datasource:  "username": "newuser",

    url: jdbc:sqlserver://localhost:1433;databaseName=DentalClinicDB;encrypt=false;trustServerCertificate=true  "password": "password123",

    username: sa  "email": "newuser@example.com",

    password: admin123  "fullName": "Nguyễn Văn A",

```  "phoneNumber": "0912345678"

}

> **Lưu ý:** Nếu SQL Server dùng port khác, thay `1433` bằng port của bạn.```



---**Response:**



### 3. Chạy Backend```json

{

```bash  "accessToken": "eyJhbGc...",

# Build và chạy  "refreshToken": "eyJhbGc...",

mvn clean install  "tokenType": "Bearer",

mvn spring-boot:run  "expiresIn": 86400,

  "user": {

# Hoặc dùng script có sẵn (Windows)    "id": 4,

.\run-api.bat    "username": "newuser",

```    "email": "newuser@example.com",

    "fullName": "Nguyễn Văn A",

**Backend sẽ chạy tại:** http://localhost:8080    "roles": ["ROLE_VIEWER"]

  }

**Lần chạy đầu tiên, application tự động:**}

- ✅ Tạo tất cả tables (Hibernate auto-ddl)```

- ✅ Insert 5 roles (ADMIN, DOCTOR, RECEPTIONIST, VIEWER, PENDING_USER)

- ✅ Tạo admin user (username: `admin`, password: `admin123`)> **Lưu ý**: Người dùng đăng ký mới mặc định được gán role **ROLE_VIEWER** (chỉ có quyền xem). Admin có thể nâng cấp quyền sau.

- ✅ Tạo menu phân quyền

#### Login

---

```http

### 4. Chạy Mobile AppPOST /api/auth/login

Content-Type: application/json

```bash

# Di chuyển vào thư mục mobile{

cd mobile  "username": "admin",

  "password": "admin123"

# Cài đặt dependencies}

flutter pub get```



# Chạy app (Android Emulator hoặc iOS Simulator)**Response:**

flutter run

```json

# Hoặc chạy trên device cụ thể{

flutter run -d <device_id>  "accessToken": "eyJhbGc...",

```  "refreshToken": "eyJhbGc...",

  "tokenType": "Bearer",

**Cấu hình API Endpoint:**  "expiresIn": 86400,

  "user": {

File: `mobile/lib/src/core/services/menu_service.dart`    "id": 1,

```dart    "username": "admin",

static const String _baseUrl = 'http://10.0.2.2:8080/api'; // Android Emulator    "email": "admin@dentalclinic.com",

// Hoặc 'http://localhost:8080/api' cho iOS Simulator    "fullName": "Administrator",

```    "roles": ["ROLE_ADMIN"]

  }

---}

````

## 🔐 Tài khoản mặc định

#### Refresh Token

| Username | Password | Role | Mô tả |

|----------|----------|------|-------|```http

| `admin` | `admin123` | ADMIN | Quản trị viên (full quyền) |POST /api/auth/refresh

| `doctor1` | `doctor123` | DOCTOR | Bác sĩ (xem demo) |Content-Type: application/json

| `receptionist1` | `receptionist123` | RECEPTIONIST | Lễ tân (xem demo) |

{

--- "refreshToken": "eyJhbGc..."

}

## 📡 API Endpoints```

### Authentication#### Test Authentication

````

POST   /api/auth/register   - Đăng ký tài khoản mới```http

POST   /api/auth/login      - Đăng nhậpGET /api/auth/me

POST   /api/auth/refresh    - Refresh tokenAuthorization: Bearer {accessToken}

````

### Users### User Management (ADMIN only)

````

GET    /api/users           - Lấy danh sách users (Admin)#### Get All Users

GET    /api/users/{id}      - Chi tiết user

POST   /api/users           - Tạo user mới (Admin)```http

PUT    /api/users/{id}      - Cập nhật userGET /api/users

DELETE /api/users/{id}      - Xóa user (Admin)Authorization: Bearer {accessToken}

PUT    /api/users/{id}/status - Kích hoạt/vô hiệu hóa```

````

#### Get All Doctors (ADMIN, RECEPTIONIST)

### Menus

```````http

GET    /api/menus                    - Menu của user (có phân quyền)GET /api/users/doctors

GET    /api/menus/all-for-management - Tất cả menu (Admin)Authorization: Bearer {accessToken}

POST   /api/menus                    - Tạo menu mới (Admin)```

PUT    /api/menus/{id}               - Cập nhật menu (Admin)

PUT    /api/menus/{id}/roles         - Cập nhật roles cho menu (Admin)#### Get User by ID

DELETE /api/menus/{id}               - Xóa menu (Admin)

``````http

GET /api/users/{id}

### RolesAuthorization: Bearer {accessToken}

```````

GET /api/roles - Tất cả roles với metadata

GET /api/roles/names - Chỉ tên roles (List<String>)#### Create User

GET /api/roles/{id} - Chi tiết role

````http

POST /api/users

### PatientsAuthorization: Bearer {accessToken}

```Content-Type: application/json

GET    /api/patients     - Danh sách bệnh nhân

GET    /api/patients/{id} - Chi tiết bệnh nhân{

POST   /api/patients     - Thêm bệnh nhân mới  "username": "doctor2",

PUT    /api/patients/{id} - Cập nhật thông tin  "password": "password123",

DELETE /api/patients/{id} - Xóa bệnh nhân  "email": "doctor2@dentalclinic.com",

```  "fullName": "Bác sĩ Trần Văn B",

  "phoneNumber": "0987654321",

### Appointments  "roleNames": ["ROLE_DOCTOR"],

```  "active": true

GET    /api/appointments              - Danh sách lịch hẹn}

GET    /api/appointments/{id}         - Chi tiết lịch hẹn```

POST   /api/appointments              - Tạo lịch hẹn mới

PUT    /api/appointments/{id}         - Cập nhật lịch hẹn#### Update User

PUT    /api/appointments/{id}/status  - Cập nhật trạng thái

DELETE /api/appointments/{id}         - Hủy lịch hẹn```http

```PUT /api/users/{id}

Authorization: Bearer {accessToken}

**Authentication:** Tất cả endpoints yêu cầu `Authorization: Bearer <token>` (trừ register/login)Content-Type: application/json



---{

  "username": "doctor2",

## 📂 Cấu trúc thư mục  "email": "doctor2@dentalclinic.com",

  "fullName": "Bác sĩ Trần Văn B Updated",

```  "phoneNumber": "0987654321",

Mobile-DentalClinic-Management/  "roleNames": ["ROLE_DOCTOR", "ROLE_ADMIN"],

├── src/                             # Backend Spring Boot source code  "active": true

│   ├── main/}

│   │   ├── java/.../dentalclinic_api/```

│   │   │   ├── config/             # Configuration, Security

│   │   │   ├── controller/         # REST Controllers#### Delete User

│   │   │   ├── dto/                # Data Transfer Objects

│   │   │   ├── entity/             # JPA Entities```http

│   │   │   ├── enums/              # EnumerationsDELETE /api/users/{id}

│   │   │   ├── exception/          # Exception HandlersAuthorization: Bearer {accessToken}

│   │   │   ├── repository/         # JPA Repositories```

│   │   │   ├── security/           # JWT, UserDetails

│   │   │   └── service/            # Business Logic#### Assign Roles to User

│   │   └── resources/

│   │       ├── application.yml     # Configuration```http

│   │       └── logback-spring.xml  # Logging configPUT /api/users/{id}/roles

│   └── test/                       # Unit testsAuthorization: Bearer {accessToken}

│Content-Type: application/json

├── mobile/                          # Flutter Mobile App

│   ├── lib/["ROLE_DOCTOR", "ROLE_ADMIN"]

│   │   ├── main.dart               # Entry point```

│   │   └── src/

│   │       ├── core/## 📊 Database Schema

│   │       │   ├── models/         # Data models

│   │       │   └── services/       # API services### Tables

│   │       ├── screens/            # UI screens

│   │       │   ├── admin/          # Admin screens- **users**: Thông tin người dùng (ADMIN, DOCTOR, RECEPTIONIST)

│   │       │   └── auth/           # Login, Register- **roles**: Các vai trò trong hệ thống

│   │       └── widgets/            # Reusable widgets- **user_roles**: Bảng liên kết nhiều-nhiều giữa users và roles

│   ├── pubspec.yaml                # Flutter dependencies- **patients**: Thông tin bệnh nhân (không có quyền đăng nhập)

│   └── android/ ios/ web/          # Platform-specific- **appointments**: Lịch hẹn khám

│

├── database.sql                     # Database setup script### Entity Relationships

├── pom.xml                          # Maven configuration

├── README.md                        # This file```

├── .gitignore                       # Git ignore rulesUser (1) ----< (N) User_Roles (N) >---- (1) Role

└── Dental_Clinic_API.postman_collection.json  # API testsUser (1) ----< (N) Appointments (Doctor)

```User (1) ----< (N) Patients (Created By)

Patient (1) ----< (N) Appointments

---```



## 🧪 Testing## 🔒 JWT Configuration



### Backend API với Postman### Cấu hình trong application.yml



1. Import file `Dental_Clinic_API.postman_collection.json` vào Postman```yaml

2. Đăng nhập để lấy JWT tokenjwt:

3. Set token vào environment variable  secret: MyVerySecureSecretKeyForDentalClinicManagementSystemAtLeast256BitsLong12345

4. Test các endpoints  expiration: 86400000 # 24 hours

  refresh-expiration: 604800000 # 7 days

### Mobile App```



```bash### Sử dụng JWT Token

# Run tests

cd mobileTất cả các endpoints (trừ `/api/auth/**`) yêu cầu JWT token trong header:

flutter test

```

# Run integration testsAuthorization: Bearer {your-jwt-token}

flutter test integration_test```

```

## ⚙️ Business Rules

---

### Lịch hẹn (Appointments)

## 📦 Build Production

- Mỗi lịch hẹn mặc định 30 phút

### Backend- Kiểm tra trùng giờ bác sĩ khi đặt lịch

- Bệnh nhân phải hoàn thành lịch cũ mới đặt tiếp

```bash- Bác sĩ/Lễ tân có thể kết thúc lịch hẹn sớm

mvn clean package -DskipTests

### Bệnh nhân (Patients)

# JAR file sẽ được tạo trong target/

java -jar target/dentalclinic-api-1.0.0.jar- Không có quyền đăng nhập

```- Được tạo bởi RECEPTIONIST hoặc ADMIN

- Lưu trữ thông tin y tế, dị ứng, tiền sử bệnh

### Mobile

### Phân quyền

```bash

cd mobile- User có thể có nhiều roles

- Mỗi endpoint có yêu cầu role riêng

# Android APK- Sử dụng `@PreAuthorize` để kiểm tra quyền

flutter build apk --release

## 🧪 Testing với cURL

# Android App Bundle

flutter build appbundle --release### 1. Login



# iOS```bash

flutter build ios --releasecurl -X POST http://localhost:8080/api/auth/login \

```  -H "Content-Type: application/json" \

  -d '{"username":"admin","password":"admin123"}'

---```



## 🐛 Troubleshooting### 2. Get All Users (với token)



### Backend không connect được database```bash

```curl -X GET http://localhost:8080/api/users \

✗ Error: Login failed for user 'sa'  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

````

**Fix:**

1. Kiểm tra SQL Server đang chạy### 3. Create New Doctor

2. Verify username/password trong `application.yml`

3. Kiểm tra SQL Server Authentication mode (phải enable SQL Server Authentication)```bash

curl -X POST http://localhost:8080/api/users \

### Mobile không gọi được API -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \

````-H "Content-Type: application/json" \

✗ Error: Connection refused  -d '{

```    "username": "doctor3",

**Fix:**    "password": "password123",

- Android Emulator: Dùng `http://10.0.2.2:8080`    "email": "doctor3@dentalclinic.com",

- iOS Simulator: Dùng `http://localhost:8080`    "fullName": "Bác sĩ Nguyễn C",

- Real device: Dùng IP thật của máy (VD: `http://192.168.1.100:8080`)    "roleNames": ["ROLE_DOCTOR"],

    "active": true

### Port 8080 bị chiếm  }'

**Fix:** Thay đổi port trong `application.yml`:```

```yaml

server:## 🔧 Troubleshooting

  port: 8081

```### ❌ Lỗi: "Cannot connect to SQL Server"



---**Nguyên nhân:** SQL Server không chạy hoặc TCP/IP chưa bật



## 📝 License**Giải pháp:**



This project is licensed under the MIT License.1. Kiểm tra SQL Server service đang chạy:



---   - Mở **Services** (Win + R → `services.msc`)

   - Tìm "SQL Server" → phải ở trạng thái "Running"

## 👥 Team

2. Bật TCP/IP trong SQL Server Configuration Manager:

**Đồ án môn Lập trình Mobile**

- Backend: Spring Boot + MSSQL   - Mở **SQL Server Configuration Manager**

- Frontend: Flutter   - SQL Server Network Configuration → Protocols for [Instance]

- University: [Tên trường]   - TCP/IP → Right-click → Enable

- Year: 2025   - Restart SQL Server service



---3. Check port 1433 trong Windows Firewall:

   ```bash

## 📞 Contact   netstat -an | findstr 1433

````

- **Email:** your.email@example.com

- **GitHub:** https://github.com/iLuminase/Mobile-DentalClinic-Management### ❌ Lỗi: "Login failed for user 'sa'"

---**Nguyên nhân:** SQL Authentication chưa bật hoặc password sai

## 📌 Version**Giải pháp:**

**Current Version:** 1.0.01. Bật SQL Server Authentication:

### Changelog - Mở SSMS → Connect vào server

- Right-click vào Server → Properties

#### v1.0.0 (2025-10-28) - Security → chọn "SQL Server and Windows Authentication mode"

- ✅ JWT Authentication & Authorization - Restart SQL Server service

- ✅ User Management (CRUD + Role assignment)

- ✅ Dynamic Menu Management với phân quyền2. Reset password cho 'sa':

- ✅ Patient Management - Chạy lại file `setup-database.sql`

- ✅ Appointment Management - Hoặc chạy manual:

- ✅ Mobile App với Navigation Drawer ```sql

- ✅ API Documentation ALTER LOGIN sa WITH PASSWORD = 'admin123';

- ✅ Database setup script ALTER LOGIN sa ENABLE;

  ```

  ```

---

### ❌ Lỗi: "Cannot open database 'DentalClinicDB'"

**Happy Coding! 🚀**

**Nguyên nhân:** Database chưa được tạo

**Giải pháp:**

1. Chạy file `setup-database.sql` trong SSMS
2. Hoặc tạo manual:
   ```sql
   CREATE DATABASE DentalClinicDB;
   ```

### ❌ Lỗi: "Table 'users' doesn't exist"

**Nguyên nhân:** Application chưa tự động tạo tables

**Giải pháp:**

1. Kiểm tra `ddl-auto` trong `application.yml`:

   ```yaml
   jpa:
     hibernate:
       ddl-auto: update # Phải là 'update' hoặc 'create'
   ```

2. Restart application

3. Check logs để xem lỗi chi tiết

### ❌ Lỗi: "HikariPool - Connection is not available"

**Nguyên nhân:** Connection pool hết kết nối

**Giải pháp:**

1. Tăng connection pool size trong `application-prod.yml`:

   ```yaml
   datasource:
     hikari:
       maximum-pool-size: 20
       minimum-idle: 10
   ```

2. Check có connection leaks không (không close connection sau khi dùng)

### 💡 Tips

- **Check application logs:** Luôn xem logs khi có lỗi
- **Verify connection:** Dùng SSMS để test connection trước
- **Check credentials:** Username/password trong `application.yml` phải khớp với SQL Server

## 📚 Tài liệu tham khảo

- [DATABASE_SETUP.md](./DATABASE_SETUP.md) - Hướng dẫn chi tiết setup MSSQL
- [setup-database.sql](./setup-database.sql) - SQL script tự động setup database

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
