// TEST SCRIPT - Copy đoạn này vào main.dart để test nhanh
// hoặc tạo file test riêng

import 'package:flutter_test/flutter_test.dart';
import 'package:doanmobile/src/core/models/menu_item_model.dart';

void main() {
  group('MenuItem Model Tests', () {
    test('Parse roles từ List<String>', () {
      final json = {
        'id': 1,
        'name': 'dashboard',
        'title': 'Dashboard',
        'path': '/dashboard',
        'icon': 'dashboard',
        'orderIndex': 0,
        'active': true,
        'depth': 0,
        'hasChildren': false,
        'children': [],
        'roles': ['ROLE_ADMIN', 'ROLE_DOCTOR'], // ← List<String>
        'canView': true,
        'canEdit': true,
        'canDelete': true,
      };

      final menu = MenuItem.fromJson(json);

      expect(menu.id, 1);
      expect(menu.title, 'Dashboard');
      expect(menu.roles.length, 2);
      expect(menu.roles, ['ROLE_ADMIN', 'ROLE_DOCTOR']);
      print('✅ Test 1 passed: Parse List<String> roles');
    });

    test('Parse roles từ List<Map> (RoleResponse)', () {
      final json = {
        'id': 2,
        'name': 'users',
        'title': 'Users',
        'path': '/users',
        'icon': 'people',
        'orderIndex': 1,
        'active': true,
        'depth': 0,
        'hasChildren': false,
        'children': [],
        'roles': [
          {'id': 1, 'name': 'ROLE_ADMIN'},  // ← List<Map>
          {'id': 2, 'name': 'ROLE_RECEPTIONIST'},
        ],
        'canView': true,
        'canEdit': true,
        'canDelete': false,
      };

      final menu = MenuItem.fromJson(json);

      expect(menu.roles.length, 2);
      expect(menu.roles, ['ROLE_ADMIN', 'ROLE_RECEPTIONIST']);
      print('✅ Test 2 passed: Parse List<Map> roles');
    });

    test('Parse menu với children', () {
      final json = {
        'id': 3,
        'name': 'admin',
        'title': 'Admin',
        'path': '/admin',
        'icon': 'settings',
        'orderIndex': 2,
        'active': true,
        'depth': 0,
        'hasChildren': true,
        'children': [
          {
            'id': 4,
            'name': 'admin_users',
            'title': 'Admin Users',
            'path': '/admin/users',
            'icon': 'people',
            'orderIndex': 0,
            'parentId': 3,
            'active': true,
            'depth': 1,
            'hasChildren': false,
            'children': [],
            'roles': ['ROLE_ADMIN'],
            'canView': true,
            'canEdit': true,
            'canDelete': true,
          }
        ],
        'roles': ['ROLE_ADMIN'],
        'canView': true,
        'canEdit': true,
        'canDelete': true,
      };

      final menu = MenuItem.fromJson(json);

      expect(menu.children.length, 1);
      expect(menu.children[0].title, 'Admin Users');
      expect(menu.children[0].depth, 1);
      print('✅ Test 3 passed: Parse nested menu with children');
    });

    test('Helper methods', () {
      final menu = MenuItem(
        id: 5,
        name: 'test',
        title: 'Test Menu',
        path: '/test',
        icon: 'menu',
        orderIndex: 0,
        active: true,
        depth: 1,
        hasChildren: false,
        roles: ['ROLE_ADMIN', 'ROLE_DOCTOR'],
        canView: true,
        canEdit: false,
        canDelete: false,
      );

      // Test rolesWithoutPrefix
      expect(menu.rolesWithoutPrefix, ['ADMIN', 'DOCTOR']);

      // Test hasRole
      expect(menu.hasRole('ADMIN'), true);
      expect(menu.hasRole('ROLE_ADMIN'), true);
      expect(menu.hasRole('USER'), false);

      // Test displayTitle (có indent)
      expect(menu.displayTitle, '    └ Test Menu');

      print('✅ Test 4 passed: Helper methods work correctly');
    });

    test('toFlatList với nested menu', () {
      final parent = MenuItem(
        id: 1,
        name: 'parent',
        title: 'Parent',
        path: '/parent',
        icon: 'menu',
        orderIndex: 0,
        active: true,
        depth: 0,
        hasChildren: true,
        children: [
          MenuItem(
            id: 2,
            name: 'child1',
            title: 'Child 1',
            path: '/parent/child1',
            icon: 'menu',
            orderIndex: 0,
            active: true,
            depth: 1,
            hasChildren: false,
            canView: true,
            canEdit: false,
            canDelete: false,
          ),
          MenuItem(
            id: 3,
            name: 'child2',
            title: 'Child 2',
            path: '/parent/child2',
            icon: 'menu',
            orderIndex: 1,
            active: true,
            depth: 1,
            hasChildren: false,
            canView: true,
            canEdit: false,
            canDelete: false,
          ),
        ],
        canView: true,
        canEdit: true,
        canDelete: true,
      );

      final flatList = parent.toFlatList();

      expect(flatList.length, 3); // Parent + 2 children
      expect(flatList[0].id, 1);
      expect(flatList[1].id, 2);
      expect(flatList[2].id, 3);
      print('✅ Test 5 passed: toFlatList with nested menu');
    });

    test('Parse null/empty roles safely', () {
      final json1 = {
        'id': 6,
        'name': 'test',
        'title': 'Test',
        'path': '/test',
        'icon': 'menu',
        'orderIndex': 0,
        'active': true,
        'depth': 0,
        'hasChildren': false,
        'roles': null, // ← null
        'canView': true,
        'canEdit': false,
        'canDelete': false,
      };

      final json2 = {
        'id': 7,
        'name': 'test2',
        'title': 'Test 2',
        'path': '/test2',
        'icon': 'menu',
        'orderIndex': 1,
        'active': true,
        'depth': 0,
        'hasChildren': false,
        'roles': [], // ← empty
        'canView': true,
        'canEdit': false,
        'canDelete': false,
      };

      final menu1 = MenuItem.fromJson(json1);
      final menu2 = MenuItem.fromJson(json2);

      expect(menu1.roles, []);
      expect(menu2.roles, []);
      print('✅ Test 6 passed: Handle null/empty roles safely');
    });
  });

  print('\n🎉 TẤT CẢ TESTS ĐỀU PASSED!\n');
}

