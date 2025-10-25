# Keycloak Configuration for Flutter App

## Tổng quan

Flutter app có thể chạy trên nhiều platform (Android, iOS, Web), mỗi platform cần cấu hình redirect URIs khác nhau.

## Cấu hình Client trong Keycloak

### 1. Client Settings

Vào **Clients** → `dental-clinic-api` → **Settings**

#### Root URL

```
http://localhost:8081
```

**Giải thích**: URL của backend API (Spring Boot), không phải Flutter app

#### Home URL

```
http://localhost:8081
```

**Giải thích**: Tương tự Root URL, trỏ về backend API

### 2. Valid Redirect URIs

**Quan trọng**: Đây là nơi Keycloak sẽ redirect sau khi login thành công

```
http://localhost:8081/*
http://localhost:3000/*
http://localhost/*
com.dentalclinic.app:/oauth2redirect
com.dentalclinic.app://callback
myapp://callback
```

**Giải thích từng URI**:

| URI                                    | Platform    | Mục đích                                   |
| -------------------------------------- | ----------- | ------------------------------------------ |
| `http://localhost:8081/*`              | Backend API | Cho Spring Boot test                       |
| `http://localhost:3000/*`              | Flutter Web | Flutter web dev server (default port 3000) |
| `http://localhost/*`                   | Flutter Web | Alternative port                           |
| `com.dentalclinic.app:/oauth2redirect` | Android/iOS | Deep link cho mobile app                   |
| `com.dentalclinic.app://callback`      | Android/iOS | Alternative callback                       |
| `myapp://callback`                     | Android/iOS | Custom scheme (nếu dùng)                   |

#### Deep Link cho Flutter Mobile

**Format**: `<scheme>://<path>`

- **Scheme**: Tên unique cho app (ví dụ: `com.dentalclinic.app`)
- **Path**: Đường dẫn callback (ví dụ: `/oauth2redirect`, `//callback`)

**Ví dụ thực tế**:

```
com.dentalclinic.app:/oauth2redirect
com.dentalclinic.app://login-callback
```

### 3. Valid Post Logout Redirect URIs

```
http://localhost:8081/*
http://localhost:3000/*
http://localhost/*
com.dentalclinic.app:/
com.dentalclinic.app://logout
```

**Giải thích**: Nơi redirect sau khi logout thành công

### 4. Web Origins

```
http://localhost:8081
http://localhost:3000
http://localhost
```

**Giải thích**: Cho phép CORS từ các origins này. Chỉ dùng cho Flutter Web, không cần cho mobile app.

**Lưu ý**:

- Không cần thêm `/*` ở cuối
- Không cần deep link scheme ở đây
- Chỉ cần HTTP/HTTPS origins

## Cấu hình Chi tiết theo Platform

### Flutter Web (Development)

```yaml
# Valid Redirect URIs
http://localhost:3000/*
http://localhost/*

# Valid Post Logout Redirect URIs
http://localhost:3000/*
http://localhost/*

# Web Origins
http://localhost:3000
http://localhost
```

**Flutter Web Port**: Thường là 3000, 8080, hoặc port tự chọn khi chạy:

```bash
flutter run -d chrome --web-port 3000
```

### Flutter Android

```yaml
# Valid Redirect URIs
com.dentalclinic.app:/oauth2redirect
com.dentalclinic.app://callback

# Valid Post Logout Redirect URIs
com.dentalclinic.app:/
com.dentalclinic.app://logout

# Web Origins
# Không cần (mobile không dùng CORS)
```

**Android App Configuration**:

File `android/app/src/main/AndroidManifest.xml`:

```xml
<activity android:name=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />

        <!-- Deep link cho OAuth callback -->
        <data
            android:scheme="com.dentalclinic.app"
            android:host="oauth2redirect" />
    </intent-filter>
</activity>
```

### Flutter iOS

```yaml
# Valid Redirect URIs
com.dentalclinic.app:/oauth2redirect
com.dentalclinic.app://callback

# Valid Post Logout Redirect URIs
com.dentalclinic.app:/
com.dentalclinic.app://logout

# Web Origins
# Không cần
```

**iOS App Configuration**:

File `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.dentalclinic.app</string>
        </array>
    </dict>
</array>
```

## Cấu hình Tổng hợp (All Platforms)

### Screenshot cấu hình trong Keycloak:

```
Root URL:                    http://localhost:8081
Home URL:                    http://localhost:8081

Valid redirect URIs:         http://localhost:8081/*
                            http://localhost:3000/*
                            http://localhost/*
                            com.dentalclinic.app:/oauth2redirect
                            com.dentalclinic.app://callback

Valid post logout redirect:  http://localhost:8081/*
                            http://localhost:3000/*
                            http://localhost/*
                            com.dentalclinic.app:/
                            com.dentalclinic.app://logout

Web origins:                 http://localhost:8081
                            http://localhost:3000
                            http://localhost
```

## Flutter App Implementation

### 1. Cài đặt Package

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  flutter_appauth: ^7.0.0
  flutter_secure_storage: ^9.0.0
  http: ^1.2.0
```

### 2. Flutter Code Example

```dart
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeycloakAuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Keycloak configuration
  static const String _keycloakIssuer = 'http://localhost:8080/realms/dental-clinic';
  static const String _clientId = 'dental-clinic-api';
  static const String _redirectUri = 'com.dentalclinic.app:/oauth2redirect';
  static const String _postLogoutRedirectUri = 'com.dentalclinic.app:/';

  Future<String?> login() async {
    try {
      final AuthorizationTokenResponse? result =
        await _appAuth.authorizeAndExchangeCode(
          AuthorizationTokenRequest(
            _clientId,
            _redirectUri,
            issuer: _keycloakIssuer,
            scopes: ['openid', 'profile', 'email'],
            promptValues: ['login'],
          ),
        );

      if (result != null) {
        // Lưu tokens
        await _storage.write(key: 'access_token', value: result.accessToken);
        await _storage.write(key: 'refresh_token', value: result.refreshToken);
        await _storage.write(key: 'id_token', value: result.idToken);

        return result.accessToken;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    final String? idToken = await _storage.read(key: 'id_token');

    if (idToken != null) {
      await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: _postLogoutRedirectUri,
          issuer: _keycloakIssuer,
        ),
      );
    }

    // Xóa tokens
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> refreshToken() async {
    final String? refreshToken = await _storage.read(key: 'refresh_token');

    if (refreshToken != null) {
      try {
        final TokenResponse? result = await _appAuth.token(
          TokenRequest(
            _clientId,
            _redirectUri,
            issuer: _keycloakIssuer,
            refreshToken: refreshToken,
          ),
        );

        if (result != null) {
          await _storage.write(key: 'access_token', value: result.accessToken);
          await _storage.write(key: 'refresh_token', value: result.refreshToken);
          return result.accessToken;
        }
      } catch (e) {
        print('Refresh token error: $e');
      }
    }
    return null;
  }
}
```

### 3. API Call với Token

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final KeycloakAuthService _authService = KeycloakAuthService();
  static const String _baseUrl = 'http://localhost:8081/api';

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final String? token = await _authService.getAccessToken();

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, try refresh
      final newToken = await _authService.refreshToken();
      if (newToken != null) {
        return getCurrentUser(); // Retry
      }
    }

    return null;
  }
}
```

## Production Configuration

### Flutter Web Production

```yaml
# Valid Redirect URIs
https://dentalclinic.com/*
https://app.dentalclinic.com/*

# Valid Post Logout Redirect URIs
https://dentalclinic.com/*
https://app.dentalclinic.com/*

# Web Origins
https://dentalclinic.com
https://app.dentalclinic.com
```

### Flutter Mobile Production

```yaml
# Valid Redirect URIs
com.dentalclinic.app:/oauth2redirect
com.dentalclinic.app://callback

# Hoặc dùng HTTPS Universal Links (iOS)
https://app.dentalclinic.com/oauth2redirect

# Hoặc App Links (Android)
https://app.dentalclinic.com/oauth2redirect

# Valid Post Logout Redirect URIs
com.dentalclinic.app:/
https://app.dentalclinic.com/
```

**Khuyến nghị Production**:

- iOS: Dùng Universal Links (`https://app.dentalclinic.com/oauth2redirect`)
- Android: Dùng App Links (`https://app.dentalclinic.com/oauth2redirect`)
- Lý do: Secure hơn custom scheme, không bị app khác hijack

## Testing

### Test Flutter Web

```bash
flutter run -d chrome --web-port 3000
# App sẽ chạy tại: http://localhost:3000
```

### Test Flutter Android

```bash
flutter run -d android
# Deep link: com.dentalclinic.app:/oauth2redirect
```

### Test Flutter iOS

```bash
flutter run -d ios
# Deep link: com.dentalclinic.app:/oauth2redirect
```

## Troubleshooting

### 1. "Invalid redirect_uri"

**Lỗi**: Keycloak không chấp nhận redirect URI

**Giải pháp**:

- Check chính xác URI trong Keycloak client settings
- Đảm bảo có `/*` ở cuối cho web URIs
- Đảm bảo scheme chính xác cho mobile (case-sensitive)

### 2. Deep Link không hoạt động (Android)

**Giải pháp**:

- Check `AndroidManifest.xml` có đúng intent-filter
- Test deep link: `adb shell am start -a android.intent.action.VIEW -d "com.dentalclinic.app:/oauth2redirect"`
- Verify package name trong `android/app/build.gradle`

### 3. Deep Link không hoạt động (iOS)

**Giải pháp**:

- Check `Info.plist` có đúng `CFBundleURLSchemes`
- Verify bundle identifier trong Xcode
- Clean build: `flutter clean && flutter pub get`

### 4. CORS Error (Flutter Web)

**Giải pháp**:

- Check "Web origins" trong Keycloak có đúng origin
- Không có dấu `/` ở cuối
- Restart Keycloak sau khi thay đổi

### 5. Token không lưu được (Mobile)

**Giải pháp**:

- iOS: Enable Keychain Sharing trong Xcode capabilities
- Android: Check permissions trong `AndroidManifest.xml`

## Best Practices

### 1. Scheme Naming

- ✅ `com.dentalclinic.app:/oauth2redirect` (dùng reverse domain)
- ❌ `myapp:/callback` (tránh generic names)

### 2. Security

- Luôn dùng HTTPS trong production
- Dùng Universal Links/App Links thay vì custom scheme
- Lưu tokens trong secure storage (flutter_secure_storage)
- Implement refresh token để renew expired tokens

### 3. Testing

- Test trên cả 3 platforms: Web, Android, iOS
- Test logout flow
- Test token expiration handling

## Tài liệu tham khảo

- [Flutter AppAuth Package](https://pub.dev/packages/flutter_appauth)
- [Keycloak Client Configuration](https://www.keycloak.org/docs/latest/server_admin/#_clients)
- [Android Deep Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)

---

**Cập nhật**: 2024  
**Flutter Version**: 3.x  
**Keycloak Version**: 23.0.7
