# 📁 Project Structure Guide

## Cấu trúc thư mục hiện tại

```
Mobile-DentalClinic-Management/
│
├── 📂 src/                          # Backend Spring Boot Source Code
│   ├── main/
│   │   ├── java/                   # Java source files
│   │   │   └── com/dentalclinic/dentalclinic_api/
│   │   │       ├── config/         # Configurations (Security, Data Init)
│   │   │       ├── controller/     # REST API Controllers
│   │   │       ├── dto/            # Data Transfer Objects
│   │   │       ├── entity/         # JPA Entities (Database models)
│   │   │       ├── enums/          # Enumerations (RoleEnum, etc.)
│   │   │       ├── exception/      # Custom exceptions & handlers
│   │   │       ├── repository/     # JPA Repositories
│   │   │       ├── security/       # JWT & Security configs
│   │   │       └── service/        # Business logic
│   │   └── resources/
│   │       ├── application.yml     # Application configuration
│   │       └── logback-spring.xml  # Logging configuration
│   └── test/                       # Unit tests
│
├── 📂 mobile/                       # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart              # Entry point
│   │   └── src/
│   │       ├── core/
│   │       │   ├── models/        # Data models (MenuItem, User, etc.)
│   │       │   └── services/      # API services (HTTP clients)
│   │       ├── screens/           # UI Screens
│   │       │   ├── admin/         # Admin-only screens
│   │       │   ├── auth/          # Login, Register screens
│   │       │   └── ...
│   │       └── widgets/           # Reusable UI components
│   ├── android/                   # Android-specific code
│   ├── ios/                       # iOS-specific code
│   ├── pubspec.yaml               # Flutter dependencies
│   └── QUICK_FIX.md              # Bug fix documentation
│
├── 📄 database.sql                 # Complete database setup script
├── 📄 pom.xml                      # Maven configuration (Backend)
├── 📄 README.md                    # Main documentation
├── 📄 .gitignore                   # Git ignore rules
├── 📄 Dental_Clinic_API.postman_collection.json  # API testing
│
├── 🚫 .idea/                       # IntelliJ IDEA (gitignored)
├── 🚫 .vscode/                     # VS Code settings (gitignored)
├── 🚫 target/                      # Maven build output (gitignored)
└── 🚫 logs/                        # Application logs (gitignored)
```

---

## 📋 Files đã xóa (cleanup)

### Xóa hoàn toàn:

- ❌ `docs/` - Documentation cũ (không cần)
- ❌ `database/` - Thư mục database cũ
- ❌ `insert-menus.sql` - Gộp vào `database.sql`
- ❌ `API_MENU.md` - Documentation cũ
- ❌ `keycloak-*/` - Keycloak (không dùng)

### Gitignored (sẽ không push lên GitHub):

- 🚫 `target/` - Maven build files
- 🚫 `logs/` - Log files
- 🚫 `.idea/` - IntelliJ settings
- 🚫 `.vscode/` - VS Code settings
- 🚫 `mobile/build/` - Flutter build files
- 🚫 `mobile/.dart_tool/` - Dart tools

---

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/iLuminase/Mobile-DentalClinic-Management.git
cd Mobile-DentalClinic-Management
```

### 2. Setup Database

```sql
-- Mở SSMS và chạy file này
database.sql
```

### 3. Run Backend

```bash
mvn spring-boot:run
# Backend: http://localhost:8080
```

### 4. Run Mobile

```bash
cd mobile
flutter pub get
flutter run
```

---

## 📦 Files quan trọng

### Backend Configuration

| File                  | Purpose                         | Location                    |
| --------------------- | ------------------------------- | --------------------------- |
| `application.yml`     | Database connection, JWT config | `src/main/resources/`       |
| `pom.xml`             | Maven dependencies              | Root                        |
| `SecurityConfig.java` | Security & JWT setup            | `src/main/java/.../config/` |

### Mobile Configuration

| File                | Purpose              | Location                        |
| ------------------- | -------------------- | ------------------------------- |
| `pubspec.yaml`      | Flutter dependencies | `mobile/`                       |
| `menu_service.dart` | API base URL config  | `mobile/lib/src/core/services/` |
| `main.dart`         | App entry point      | `mobile/lib/`                   |

### Database

| File           | Purpose                  | Location |
| -------------- | ------------------------ | -------- |
| `database.sql` | Complete DB setup script | Root     |

---

## 🔧 Maintenance

### Build Backend

```bash
mvn clean install
mvn package
# Output: target/dentalclinic-api-1.0.0.jar
```

### Build Mobile

```bash
cd mobile
flutter build apk --release          # Android
flutter build appbundle --release    # Android (Play Store)
flutter build ios --release          # iOS
```

### Clean Project

```bash
# Backend
mvn clean

# Mobile
cd mobile
flutter clean
```

---

## 📝 Thay đổi quan trọng

### So với version cũ:

1. ✅ Gộp tất cả SQL scripts vào `database.sql`
2. ✅ Xóa thư mục `docs/` và `database/`
3. ✅ README.md ngắn gọn, chỉ giữ tính năng và cách chạy
4. ✅ `.gitignore` hoàn chỉnh cho cả BE & FE
5. ✅ Folder structure rõ ràng: `src/` (Backend), `mobile/` (Flutter)

### Chuẩn bị push lên GitHub:

```bash
git add .
git commit -m "docs: cleanup project structure and documentation"
git push origin main
```

---

## 📞 Support

Xem chi tiết trong [README.md](../README.md)
