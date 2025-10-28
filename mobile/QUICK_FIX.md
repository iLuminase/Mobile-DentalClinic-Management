# 🔧 Quick Fix: Flutter Menu Type Cast Error

## Lỗi

```
type '_Map<String, dynamic>' is not a subtype of type 'String' in type cast
```

## Nguyên nhân

- Flutter code dùng API `/api/roles` (trả về objects)
- Nhưng expect `List<String>`
- Type cast crash

## Đã Fix

### File 1: `menu_service.dart`

```dart
// TRƯỚC (❌ SAI)
final url = Uri.parse('$_baseUrl/roles');

// SAU (✅ ĐÚNG)
final url = Uri.parse('$_baseUrl/roles/names');
```

### File 2: `menu_management_screen.dart`

```dart
// TRƯỚC (❌ Unsafe)
_allRoles = (results[1] as List<String>)...

// SAU (✅ Type-safe)
final rolesResult = results[1] as List<dynamic>;
_allRoles = rolesResult.map((role) {
  if (role is String) return role.replaceAll('ROLE_', '');
  else if (role is Map) return (role['name'] as String).replaceAll('ROLE_', '');
  return role.toString().replaceAll('ROLE_', '');
}).toList();
```

## Test

1. Stop Flutter app
2. Hot restart: `r` trong terminal
3. Navigate to Menu tab
4. ✅ Không crash nữa

## Nếu vẫn lỗi

```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

## Chi tiết

Xem: `docs/FLUTTER_MENU_BUGFIX.md`
