# Account Status Management (Enable/Disable Accounts)

## Overview

This feature allows administrators to enable or disable user accounts. When an account is disabled:

- User cannot login (authentication is blocked)
- User cannot refresh access tokens
- Clear error message is returned to the frontend
- Existing sessions remain valid until token expires

## Backend Changes

### 1. New Exception: `AccountDisabledException`

**File:** `src/main/java/com/dentalclinic/dentalclinic_api/exception/AccountDisabledException.java`

Custom exception thrown when a disabled account attempts to login or refresh token.

```java
public class AccountDisabledException extends RuntimeException {
    public AccountDisabledException(String message) { }
    public AccountDisabledException(String username, String reason) { }
}
```

### 2. Global Exception Handler Updated

**File:** `src/main/java/com/dentalclinic/dentalclinic_api/exception/GlobalExceptionHandler.java`

Added handler for disabled account exceptions:

```java
@ExceptionHandler({DisabledException.class, AccountDisabledException.class})
public ResponseEntity<Map<String, Object>> handleAccountDisabledErrors(Exception ex) {
    // Returns HTTP 403 FORBIDDEN with errorCode: "ACCOUNT_DISABLED"
}
```

**Response Format:**

```json
{
  "timestamp": "2025-10-28T14:00:00",
  "status": 403,
  "error": "Account Disabled",
  "errorCode": "ACCOUNT_DISABLED",
  "message": "Tài khoản 'username' đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên để được hỗ trợ."
}
```

### 3. CustomUserDetailsService Updated

**File:** `src/main/java/com/dentalclinic/dentalclinic_api/security/CustomUserDetailsService.java`

Changed exception from `UsernameNotFoundException` to `DisabledException` when account is inactive:

```java
if (!user.getActive()) {
    throw new DisabledException("Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên để được hỗ trợ.");
}
```

### 4. AuthService Updated

**File:** `src/main/java/com/dentalclinic/dentalclinic_api/service/AuthService.java`

**Login Method:**

- Checks if account is active BEFORE authentication
- Throws `AccountDisabledException` if account is disabled
- Catches `DisabledException` from Spring Security

**Refresh Token Method:**

- Checks if account is active BEFORE refreshing token
- Throws `AccountDisabledException` if account is disabled

### 5. UserService - Existing Method

**File:** `src/main/java/com/dentalclinic/dentalclinic_api/service/UserService.java`

Method `updateUserStatus(Long id, Boolean isActive)` already exists for changing account status.

### 6. DataInitializer - Log Messages

**File:** `src/main/java/com/dentalclinic/dentalclinic_api/config/DataInitializer.java`

All log messages changed from Vietnamese to English:

- "Initializing default data..."
- "Created admin user: username=admin, password=admin123"
- "Created doctor user: username=doctor1, password=doctor123"
- "Created receptionist user: username=receptionist1, password=receptionist123"
- "Created role: {roleName}"
- "Menus already exist, skipping menu initialization"
- "Creating default menus..."
- "Created {count} default menus successfully"
- "Data initialization completed successfully"

## API Endpoints

### Update User Status (Already Exists)

```http
PUT /api/users/{id}/status
Content-Type: application/json
Authorization: Bearer {token}

{
  "isActive": false
}
```

**Response:**

```json
{
  "id": 123,
  "username": "doctor1",
  "email": "doctor1@dentalclinic.com",
  "fullName": "Dr. Nguyen Van A",
  "active": false,
  "roles": [...],
  ...
}
```

## Frontend Integration

### 1. Detect Account Disabled Error

Check for HTTP status 403 with errorCode "ACCOUNT_DISABLED":

```dart
try {
  final response = await dio.post('/api/auth/login', data: {...});
  // Handle success
} on DioException catch (e) {
  if (e.response?.statusCode == 403) {
    final data = e.response?.data;
    if (data['errorCode'] == 'ACCOUNT_DISABLED') {
      // Show account disabled dialog
      showAccountDisabledDialog(data['message']);
      return;
    }
  }
  // Handle other errors
}
```

### 2. Show User-Friendly Message

**Vietnamese Message:**

```
"Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên để được hỗ trợ."
```

**English Message:**

```
"Your account has been disabled. Please contact the administrator for support."
```

### 3. Handle in Login Flow

```dart
Future<void> login(String username, String password) async {
  try {
    final response = await _authService.login(username, password);
    // Save tokens and navigate to home
  } on AccountDisabledException catch (e) {
    // Show alert dialog with message
    Get.dialog(
      AlertDialog(
        title: Text('Tài khoản bị vô hiệu hóa'),
        content: Text(e.message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  } catch (e) {
    // Handle other errors
  }
}
```

### 4. Handle in Token Refresh

```dart
Future<String> refreshAccessToken(String refreshToken) async {
  try {
    final response = await _authService.refreshToken(refreshToken);
    return response.accessToken;
  } on AccountDisabledException {
    // Account disabled - force logout
    await clearTokens();
    navigateToLogin();
    showMessage('Tài khoản đã bị vô hiệu hóa');
    rethrow;
  }
}
```

### 5. Create Custom Exception (Optional)

```dart
class AccountDisabledException implements Exception {
  final String message;
  final String errorCode;

  AccountDisabledException({
    required this.message,
    this.errorCode = 'ACCOUNT_DISABLED',
  });

  @override
  String toString() => message;
}
```

### 6. HTTP Interceptor

```dart
dio.interceptors.add(
  InterceptorsWrapper(
    onError: (error, handler) {
      if (error.response?.statusCode == 403) {
        final data = error.response?.data;
        if (data['errorCode'] == 'ACCOUNT_DISABLED') {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: AccountDisabledException(message: data['message']),
            ),
          );
        }
      }
      handler.next(error);
    },
  ),
);
```

## Testing

### Test Disable Account Flow

1. **Login with active account:**

   ```bash
   curl -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"doctor1","password":"doctor123"}'
   ```

   ✅ Expected: 200 OK with tokens

2. **Disable account:**

   ```bash
   curl -X PUT http://localhost:8080/api/users/2/status \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer {admin_token}" \
     -d '{"isActive":false}'
   ```

   ✅ Expected: 200 OK with `"active": false`

3. **Try to login with disabled account:**

   ```bash
   curl -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"doctor1","password":"doctor123"}'
   ```

   ✅ Expected: 403 FORBIDDEN with errorCode "ACCOUNT_DISABLED"

4. **Try to refresh token with disabled account:**

   ```bash
   curl -X POST http://localhost:8080/api/auth/refresh \
     -H "Content-Type: application/json" \
     -d '{"refreshToken":"{valid_refresh_token}"}'
   ```

   ✅ Expected: 403 FORBIDDEN with errorCode "ACCOUNT_DISABLED"

5. **Re-enable account:**

   ```bash
   curl -X PUT http://localhost:8080/api/users/2/status \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer {admin_token}" \
     -d '{"isActive":true}'
   ```

   ✅ Expected: 200 OK with `"active": true`

6. **Login again with enabled account:**
   ```bash
   curl -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"doctor1","password":"doctor123"}'
   ```
   ✅ Expected: 200 OK with tokens

## Security Considerations

1. **Existing Sessions:** Disabling an account does NOT invalidate existing JWT tokens. Tokens remain valid until they expire.

2. **Force Logout:** To immediately block access, consider implementing token blacklist or reducing token expiration time.

3. **Admin Protection:** Prevent admins from disabling their own accounts to avoid lockout.

4. **Audit Log:** Consider logging account status changes for security audit.

## Error Codes Summary

| Error Code         | HTTP Status | Description                                        |
| ------------------ | ----------- | -------------------------------------------------- |
| `ACCOUNT_DISABLED` | 403         | Account is disabled, cannot login or refresh token |
| `Unauthorized`     | 401         | Invalid credentials (wrong username/password)      |
| `Bad Request`      | 400         | Validation errors or other client errors           |

## Next Steps

1. ✅ Backend implementation complete
2. ⏳ Frontend Flutter implementation needed
3. ⏳ Add admin UI to enable/disable accounts
4. ⏳ Add confirmation dialog before disabling account
5. ⏳ Consider adding "disabled reason" field
6. ⏳ Add audit log for account status changes
