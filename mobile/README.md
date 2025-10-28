# Gemini Flutter Development Instructions

## Project Overview
You are helping to build the **Dental Clinic Management Mobile App** using **Flutter 3.35.3 + Dart 3.9.2**. This is a mobile frontend that connects to a Spring Boot backend API.

---

## 🎯 Your Role
- Write Flutter/Dart code for mobile app screens and features
- Integrate with REST API endpoints (documented below)
- Follow Material Design 3 guidelines
- Use Provider/Bloc for state management
- Write clean, maintainable, and well-documented code

---

## 📁 Project Structure

```
mobile/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── src/
│   │   ├── models/                  # Data models (User, Menu, Patient, etc.)
│   │   ├── services/                # API services (AuthService, MenuService, etc.)
│   │   ├── providers/               # State management (Provider/Bloc)
│   │   ├── screens/                 # UI screens
│   │   │   ├── auth/               # Login, Register screens
│   │   │   ├── dashboard/          # Dashboard screen
│   │   │   ├── users/              # User management screens
│   │   │   ├── patients/           # Patient management screens
│   │   │   └── appointments/       # Appointment screens
│   │   ├── widgets/                # Reusable widgets
│   │   ├── utils/                  # Utilities, constants, helpers
│   │   └── config/                 # App configuration
│   └── test/                        # Unit tests
├── pubspec.yaml                     # Dependencies
└── README.md
```

---

## 🔌 Backend API Information

### Base URL
```
Local: http://localhost:8080/api
Production: https://your-domain.com/api
```

### Authentication
All requests (except login/register) require JWT Bearer token:
```dart
headers: {
  'Authorization': 'Bearer $accessToken',
  'Content-Type': 'application/json',
}
```

### Token Storage
```dart
// Use flutter_secure_storage for tokens
final storage = FlutterSecureStorage();
await storage.write(key: 'access_token', value: token);
await storage.write(key: 'refresh_token', value: refreshToken);
```

---

## 📚 API Endpoints Reference

### 1. Authentication API

#### Login
```
POST /api/auth/login
Body: {
  "username": "string",
  "password": "string"
}
Response: {
  "accessToken": "string",
  "refreshToken": "string",
  "tokenType": "Bearer",
  "expiresIn": 86400,
  "userId": 1,
  "username": "admin",
  "roles": ["ROLE_ADMIN"]
}
```

#### Register
```
POST /api/auth/register
Body: {
  "username": "string",
  "password": "string",
  "email": "string",
  "fullName": "string"
}
Response: Same as login
Note: Auto-assigns ROLE_PENDING_USER (needs admin approval)
```

#### Refresh Token
```
POST /api/auth/refresh
Body: {
  "refreshToken": "string"
}
Response: Same as login
```

---

### 2. Menu API (For Navigation)

#### Get My Menus (Hierarchy)
```
GET /api/menus/me
Response: [
  {
    "id": 1,
    "name": "dashboard",
    "title": "Tổng quan",
    "path": "/dashboard",
    "icon": "dashboard",
    "iconType": "material",
    "componentName": "DashboardScreen",
    "orderIndex": 1,
    "depth": 0,
    "hasChildren": false,
    "children": [],
    "roles": ["ROLE_ADMIN"],
    "canView": true,
    "canEdit": true,
    "canDelete": true,
    "tooltip": "Dashboard"
  }
]
```

#### Get Flat Menu List (For Search)
```
GET /api/menus/flat
Response: Array of menu items (no hierarchy)
```

#### Get Breadcrumb
```
GET /api/menus/breadcrumb/{menuId}
Response: [
  { /* parent menu */ },
  { /* current menu */ }
]
```

#### Get Menu Statistics
```
GET /api/menus/stats
Response: {
  "totalMenus": 15,
  "parentMenus": 5,
  "childMenus": 10,
  "byDepth": { "0": 5, "1": 8 },
  "roles": ["ROLE_ADMIN"]
}
```

**Full Menu API Documentation**: See `docs/MENU-API-FOR-MOBILE.md`

---

### 3. User Management API

#### Get All Users (Admin)
```
GET /api/users
Response: [
  {
    "id": 1,
    "username": "admin",
    "email": "admin@clinic.com",
    "fullName": "Administrator",
    "active": true,
    "roles": ["ROLE_ADMIN"],
    "createdAt": "2025-10-28T12:00:00",
    "updatedAt": "2025-10-28T12:00:00"
  }
]
```

#### Get Current User
```
GET /api/users/me
Response: User object
```

#### Create User (Admin)
```
POST /api/users
Body: {
  "username": "string",
  "password": "string",
  "email": "string",
  "fullName": "string",
  "roleNames": ["ROLE_DOCTOR"]
}
```

#### Update User
```
PUT /api/users/{id}
Body: Same as create (password optional)
```

#### Deactivate/Activate User
```
PATCH /api/users/{id}/deactivate
PATCH /api/users/{id}/activate
```

---

## 🎨 Design Guidelines

### Theme
```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  // Use Vietnamese locale
  locale: Locale('vi', 'VN'),
)
```

### Colors
- Primary: Blue (#1976D2)
- Secondary: Light Blue (#64B5F6)
- Success: Green (#4CAF50)
- Warning: Orange (#FF9800)
- Error: Red (#F44336)

### Typography
- Use Google Fonts: Roboto
- Support Vietnamese characters (UTF-8)
- Readable font sizes (body: 14-16sp, title: 18-20sp)

---

## 📦 Required Packages

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.2
  
  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.1.0
  
  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # Navigation
  go_router: ^13.0.0
  
  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  flutter_spinkit: ^5.2.0
  
  # Utils
  intl: ^0.19.0
  json_annotation: ^4.8.1
  
dev_dependencies:
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  retrofit_generator: ^8.1.0
```

---

## 🏗️ Code Templates

### 1. Model Class Template
```dart
import 'package:json_annotation/json_annotation.dart';

part 'menu_item.g.dart';

@JsonSerializable()
class MenuItem {
  final int id;
  final String name;
  final String title;
  final String path;
  final String icon;
  final String? iconType;
  final int orderIndex;
  final int? parentId;
  final bool active;
  final int depth;
  final bool hasChildren;
  final List<MenuItem> children;
  final List<String> roles;
  final bool canView;
  final bool canEdit;
  final bool canDelete;
  final String? componentName;
  final String? tooltip;

  MenuItem({
    required this.id,
    required this.name,
    required this.title,
    required this.path,
    required this.icon,
    this.iconType,
    required this.orderIndex,
    this.parentId,
    required this.active,
    required this.depth,
    required this.hasChildren,
    this.children = const [],
    this.roles = const [],
    required this.canView,
    required this.canEdit,
    required this.canDelete,
    this.componentName,
    this.tooltip,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}
```

Run: `flutter pub run build_runner build`

---

### 2. API Service Template
```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'menu_service.g.dart';

@RestApi(baseUrl: "http://localhost:8080/api")
abstract class MenuService {
  factory MenuService(Dio dio, {String baseUrl}) = _MenuService;

  @GET("/menus/me")
  Future<List<MenuItem>> getMyMenus();

  @GET("/menus/flat")
  Future<List<MenuItem>> getMyMenusFlat();

  @GET("/menus/breadcrumb/{id}")
  Future<List<MenuItem>> getBreadcrumb(@Path("id") int id);

  @GET("/menus/stats")
  Future<Map<String, dynamic>> getMenuStats();
}

// Usage
final dio = Dio();
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));

final menuService = MenuService(dio);
```

---

### 3. Screen Template
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load data from API
      // await provider.fetchData();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: $_error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Your UI here
          ],
        ),
      ),
    );
  }
}
```

---

### 4. Provider Template
```dart
import 'package:flutter/foundation.dart';

class MenuProvider with ChangeNotifier {
  List<MenuItem> _menus = [];
  bool _isLoading = false;
  String? _error;

  List<MenuItem> get menus => _menus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final MenuService _menuService;

  MenuProvider(this._menuService);

  Future<void> fetchMenus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menus = await _menuService.getMyMenus();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

### 5. Sidebar Menu Widget
```dart
class SidebarMenu extends StatelessWidget {
  final List<MenuItem> menus;

  const SidebarMenu({Key? key, required this.menus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services, size: 64, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Dental Clinic',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: menus.map((menu) => _buildMenuItem(context, menu)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem menu) {
    if (!menu.hasChildren) {
      return ListTile(
        leading: Icon(_getIconData(menu.icon)),
        title: Text(menu.title),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, menu.path);
        },
      );
    }

    return ExpansionTile(
      leading: Icon(_getIconData(menu.icon)),
      title: Text(menu.title),
      children: menu.children
          .map((child) => Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _buildMenuItem(context, child),
              ))
          .toList(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dashboard': return Icons.dashboard;
      case 'people': return Icons.people;
      case 'person': return Icons.person;
      case 'calendar_today': return Icons.calendar_today;
      case 'description': return Icons.description;
      case 'medical_services': return Icons.medical_services;
      case 'receipt': return Icons.receipt;
      case 'assessment': return Icons.assessment;
      case 'settings': return Icons.settings;
      default: return Icons.menu;
    }
  }
}
```

---

## 🔒 Security Best Practices

### 1. Token Management
```dart
class AuthService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }
  
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
  
  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
```

### 2. Error Handling
```dart
try {
  final response = await menuService.getMyMenus();
  // Handle success
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Token expired, refresh or logout
    await authService.refreshToken();
  } else if (e.response?.statusCode == 403) {
    // Access denied
    showSnackBar('Bạn không có quyền truy cập');
  } else {
    // Other errors
    showSnackBar('Lỗi: ${e.message}');
  }
}
```

### 3. Input Validation
```dart
final _formKey = GlobalKey<FormState>();

TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập username';
    }
    if (value.length < 3) {
      return 'Username phải có ít nhất 3 ký tự';
    }
    return null;
  },
)
```

---

## 🌐 Localization (Vietnamese)

### Date Formatting
```dart
import 'package:intl/intl.dart';

// Format date
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
}

// Format datetime
String formatDateTime(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date);
}
```

### Vietnamese Messages
```dart
const messages = {
  'login': 'Đăng nhập',
  'logout': 'Đăng xuất',
  'username': 'Tên đăng nhập',
  'password': 'Mật khẩu',
  'email': 'Email',
  'fullName': 'Họ và tên',
  'save': 'Lưu',
  'cancel': 'Hủy',
  'delete': 'Xóa',
  'edit': 'Sửa',
  'add': 'Thêm',
  'search': 'Tìm kiếm',
  'loading': 'Đang tải...',
  'error': 'Lỗi',
  'success': 'Thành công',
};
```

---

## 🧪 Testing

### Unit Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('MenuProvider Tests', () {
    late MenuProvider provider;
    late MockMenuService mockService;

    setUp(() {
      mockService = MockMenuService();
      provider = MenuProvider(mockService);
    });

    test('fetchMenus updates menus list', () async {
      final testMenus = [MenuItem(/* ... */)];
      when(mockService.getMyMenus()).thenAnswer((_) async => testMenus);

      await provider.fetchMenus();

      expect(provider.menus, equals(testMenus));
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });
  });
}
```

---

## 📝 Coding Standards

### 1. Naming Conventions
- Classes: PascalCase (`MenuService`, `DashboardScreen`)
- Variables: camelCase (`menuList`, `isLoading`)
- Constants: lowerCamelCase (`kDefaultPadding`)
- Files: snake_case (`menu_service.dart`, `dashboard_screen.dart`)

### 2. Comments
```dart
/// Fetches menu items for the current user.
/// 
/// Returns a list of [MenuItem] objects representing the menu hierarchy.
/// Throws [DioException] if the API request fails.
Future<List<MenuItem>> getMyMenus() async {
  // Implementation
}
```

### 3. Formatting
- Use `flutter format .` before committing
- Max line length: 80 characters
- Use trailing commas for better formatting

---

## 🚀 Getting Started Checklist

When starting a new feature, follow these steps:

1. **Understand the API**
    - [ ] Read API documentation
    - [ ] Test endpoints with Postman/curl
    - [ ] Verify authentication requirements

2. **Create Models**
    - [ ] Define data models with json_serializable
    - [ ] Run build_runner to generate code
    - [ ] Add unit tests for models

3. **Create Service**
    - [ ] Define API service with Retrofit
    - [ ] Add authentication interceptor
    - [ ] Handle errors properly

4. **Create Provider**
    - [ ] Set up state management
    - [ ] Implement loading/error states
    - [ ] Add unit tests

5. **Create UI**
    - [ ] Build screen layout
    - [ ] Connect to provider
    - [ ] Add loading/error states
    - [ ] Test on different screen sizes

6. **Test & Polish**
    - [ ] Test all user flows
    - [ ] Add input validation
    - [ ] Improve error messages
    - [ ] Optimize performance

---

## 📚 Additional Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Material Design 3**: https://m3.material.io/
- **Dio Package**: https://pub.dev/packages/dio
- **Provider Package**: https://pub.dev/packages/provider
- **Backend API Docs**: See `/docs` folder in backend repo

---

## 🐛 Common Issues & Solutions

### Issue: Token expired
```dart
dio.interceptors.add(InterceptorsWrapper(
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Try to refresh token
      try {
        await authService.refreshToken();
        // Retry original request
        final opts = Options(
          method: error.requestOptions.method,
          headers: {'Authorization': 'Bearer ${await getToken()}'},
        );
        final response = await dio.request(
          error.requestOptions.path,
          options: opts,
        );
        return handler.resolve(response);
      } catch (e) {
        // Refresh failed, logout
        await authService.logout();
        return handler.next(error);
      }
    }
    return handler.next(error);
  },
));
```

### Issue: Circular progress showing forever
Always wrap async operations in try-catch and set loading state in finally:
```dart
Future<void> loadData() async {
  setState(() => _isLoading = true);
  try {
    // API call
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);  // Always executed
  }
}
```

---

## 💬 Communication Tips

When asking for help:
1. Specify which screen/feature you're working on
2. Provide error messages (full stack trace)
3. Share relevant code snippets
4. Mention what you've already tried

Example: "I'm working on the Login screen. Getting a 401 error when calling POST /api/auth/login. Here's my code: [snippet]. I've verified the credentials are correct in Postman."

---

## 🎉 Summary

- **Base URL**: http://localhost:8080/api
- **Auth**: JWT Bearer tokens (stored securely)
- **State**: Use Provider or Bloc
- **HTTP**: Use Dio + Retrofit
- **UI**: Material Design 3 with Vietnamese locale
- **Docs**: Check `/docs` folder for API details

**Happy Coding! 🚀**

---

**Last Updated**: 2025-10-28  
**Backend Version**: Spring Boot 3.5.6  
**Flutter Version**: 3.35.3  
**Target**: Android & iOS
