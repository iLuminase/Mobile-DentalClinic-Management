import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/services/menu_service.dart';
import 'package:flutter/material.dart';

/// Màn hình quản lý Menu với phân quyền
/// Admin có thể: Thêm/Sửa/Xóa menu, cấu hình roles cho từng menu
class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final MenuService _menuService = MenuService();
  late Future<Map<String, dynamic>> _dataFuture;
  List<MenuItem> _menus = [];
  List<String> _allRoles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  /// Refresh dữ liệu từ API
  void _refreshData() {
    setState(() {
      _dataFuture = _loadInitialData();
    });
  }

  /// Load menu và roles từ API
  Future<Map<String, dynamic>> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _menuService.getAllMenusForAdmin(),
        _menuService.getAllRoles(),
      ]);

      _menus = results[0] as List<MenuItem>;

      // Xử lý roles - loại bỏ ROLE_ prefix
      final rolesResult = results[1] as List<dynamic>;
      _allRoles = rolesResult.map((role) {
        if (role is String) {
          return role.replaceAll('ROLE_', '');
        } else if (role is Map<String, dynamic> && role.containsKey('name')) {
          return (role['name'] as String).replaceAll('ROLE_', '');
        }
        return role.toString().replaceAll('ROLE_', '');
      }).toList();

      return {'menus': _menus, 'roles': _allRoles};
    } catch (e) {
      debugPrint('❌ Lỗi load data: $e');
      return {'menus': <MenuItem>[], 'roles': <String>[]};
    }
  }

  /// Hiển thị dialog sửa roles cho menu
  void _showEditRolesDialog(MenuItem menu) {
    final Set<String> selectedRoles = menu.roles
        .map((r) => r.replaceAll('ROLE_', ''))
        .toSet();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.security, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phân quyền: ${menu.title}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: _allRoles.isEmpty
                  ? const Text('Không có roles nào trong hệ thống')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _allRoles.length,
                      itemBuilder: (context, index) {
                        final role = _allRoles[index];
                        final isSelected = selectedRoles.contains(role);

                        return CheckboxListTile(
                          title: Text(role),
                          subtitle: Text(_getRoleDescription(role)),
                          value: isSelected,
                          activeColor: _getRoleColor('ROLE_$role'),
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedRoles.add(role);
                              } else {
                                selectedRoles.remove(role);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Lưu'),
                onPressed: () async {
                  // Chuyển lại về format ROLE_XXX
                  final rolesToUpdate = selectedRoles
                      .map((r) => r.startsWith('ROLE_') ? r : 'ROLE_$r')
                      .toList();

                  setState(() => _isLoading = true);
                  final success = await _menuService.updateMenuRoles(
                    menu.id,
                    rolesToUpdate,
                  );
                  setState(() => _isLoading = false);

                  if (mounted) {
                    Navigator.of(context).pop();
                    _showSnackBar(
                      success
                          ? '✅ Cập nhật quyền thành công!'
                          : '❌ Cập nhật quyền thất bại',
                      success,
                    );
                    if (success) _refreshData();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Hiển thị form thêm/sửa menu
  void _showAddEditMenuDialog({MenuItem? menu}) {
    final isEdit = menu != null;
    final formKey = GlobalKey<FormState>();

    // Controllers
    final nameController = TextEditingController(text: menu?.name ?? '');
    final titleController = TextEditingController(text: menu?.title ?? '');
    final pathController = TextEditingController(text: menu?.path ?? '');
    final iconController = TextEditingController(text: menu?.icon ?? 'menu');
    final orderController = TextEditingController(
      text: menu?.orderIndex.toString() ?? '0',
    );

    bool active = menu?.active ?? true;
    int? selectedParentId = menu?.parentId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(isEdit ? Icons.edit : Icons.add_circle, color: Colors.blue),
                const SizedBox(width: 8),
                Text(isEdit ? 'Sửa Menu' : 'Thêm Menu Mới'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name (code)',
                          hintText: 'user_management',
                          prefixIcon: Icon(Icons.code),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề hiển thị',
                          hintText: 'Quản lý người dùng',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: pathController,
                        decoration: const InputDecoration(
                          labelText: 'Đường dẫn',
                          hintText: '/admin/users',
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: iconController,
                        decoration: const InputDecoration(
                          labelText: 'Icon',
                          hintText: 'people, dashboard, settings...',
                          prefixIcon: Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: orderController,
                        decoration: const InputDecoration(
                          labelText: 'Thứ tự',
                          prefixIcon: Icon(Icons.sort),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int?>(
                        value: selectedParentId,
                        decoration: const InputDecoration(
                          labelText: 'Menu cha (tùy chọn)',
                          prefixIcon: Icon(Icons.account_tree),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Không có (Root menu)')),
                          ..._menus
                              .where((m) => m.depth < 2 && m.id != menu?.id)
                              .map((m) => DropdownMenuItem(
                                    value: m.id,
                                    child: Text(m.displayTitle),
                                  )),
                        ],
                        onChanged: (val) {
                          setDialogState(() => selectedParentId = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Kích hoạt'),
                        value: active,
                        onChanged: (val) {
                          setDialogState(() => active = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton.icon(
                icon: Icon(isEdit ? Icons.save : Icons.add),
                label: Text(isEdit ? 'Cập nhật' : 'Tạo'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final menuData = {
                    'name': nameController.text.trim(),
                    'title': titleController.text.trim(),
                    'path': pathController.text.trim(),
                    'icon': iconController.text.trim(),
                    'orderIndex': int.tryParse(orderController.text) ?? 0,
                    'parentId': selectedParentId,
                    'active': active,
                  };

                  setState(() => _isLoading = true);
                  final result = isEdit
                      ? await _menuService.updateMenu(menu!.id, menuData)
                      : await _menuService.createMenu(menuData);
                  setState(() => _isLoading = false);

                  if (mounted) {
                    Navigator.of(context).pop();
                    _showSnackBar(
                      result != null
                          ? '✅ ${isEdit ? "Cập nhật" : "Tạo"} menu thành công!'
                          : '❌ ${isEdit ? "Cập nhật" : "Tạo"} menu thất bại',
                      result != null,
                    );
                    if (result != null) _refreshData();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Xóa menu
  void _deleteMenu(MenuItem menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn xóa menu "${menu.title}"?'),
            const SizedBox(height: 8),
            const Text(
              'Lưu ý: Không thể xóa menu có menu con.',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true);
      final success = await _menuService.deleteMenu(menu.id);
      setState(() => _isLoading = false);

      if (mounted) {
        _showSnackBar(
          success
              ? '✅ Xóa menu thành công!'
              : '❌ Xóa menu thất bại (có thể menu có con)',
          success,
        );
        if (success) _refreshData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Lỗi: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                        onPressed: _refreshData,
                      ),
                    ],
                  ),
                );
              }

              if (_menus.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_open, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Chưa có menu nào'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm menu đầu tiên'),
                        onPressed: () => _showAddEditMenuDialog(),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _refreshData(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _menus.length,
                  itemBuilder: (context, index) => _buildMenuTile(_menus[index]),
                ),
              );
            },
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditMenuDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm Menu'),
      ),
    );
  }

  /// Build menu tile (có thể có children)
  Widget _buildMenuTile(MenuItem menu) {
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge số lượng roles
        if (menu.roles.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${menu.roles.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: 8),

        // Menu actions
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showAddEditMenuDialog(menu: menu);
                break;
              case 'roles':
                _showEditRolesDialog(menu);
                break;
              case 'toggle':
                _toggleActive(menu);
                break;
              case 'delete':
                _deleteMenu(menu);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Sửa thông tin'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'roles',
              child: Row(
                children: [
                  Icon(Icons.security, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Phân quyền'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    menu.active ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(menu.active ? 'Ẩn' : 'Hiện'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    final leading = Icon(
      _getIconData(menu.icon),
      color: menu.active ? Colors.blue : Colors.grey,
    );

    final title = Row(
      children: [
        Expanded(
          child: Text(
            menu.title,
            style: TextStyle(
              color: menu.active ? null : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (!menu.active)
          const Chip(
            label: Text('Ẩn', style: TextStyle(fontSize: 10)),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );

    final subtitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${menu.name} • ${menu.path}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        _buildRoleChips(menu.roles),
      ],
    );

    if (!menu.hasChildren || menu.children.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        children: menu.children.map((child) {
          return Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: _buildMenuTile(child),
          );
        }).toList(),
      ),
    );
  }

  /// Build role chips
  Widget _buildRoleChips(List<String> roles) {
    if (roles.isEmpty) {
      return const Text(
        'Chưa phân quyền',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
          fontSize: 11,
        ),
      );
    }

    return Wrap(
      spacing: 4.0,
      runSpacing: 2.0,
      children: roles.map((role) {
        final displayRole = role.replaceAll('ROLE_', '');
        return Chip(
          label: Text(
            displayRole,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: _getRoleColor(role),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  /// Lấy màu theo role
  Color _getRoleColor(String role) {
    final roleUpper = role.toUpperCase();
    if (roleUpper.contains('ADMIN')) return Colors.red;
    if (roleUpper.contains('DOCTOR')) return Colors.blue.shade700;
    if (roleUpper.contains('RECEPTIONIST')) return Colors.green.shade700;
    if (roleUpper.contains('USER')) return Colors.purple.shade700;
    return Colors.grey.shade600;
  }

  /// Lấy description của role
  String _getRoleDescription(String role) {
    final roleUpper = role.toUpperCase();
    if (roleUpper.contains('ADMIN')) return 'Quản trị viên';
    if (roleUpper.contains('DOCTOR')) return 'Bác sĩ';
    if (roleUpper.contains('RECEPTIONIST')) return 'Lễ tân';
    if (roleUpper.contains('USER')) return 'Người dùng';
    return 'Vai trò tùy chỉnh';
  }

  /// Lấy IconData từ tên icon
  IconData _getIconData(String iconName) {
    const icons = {
      'dashboard': Icons.dashboard,
      'people': Icons.people,
      'person_add': Icons.person_add,
      'manage_accounts': Icons.manage_accounts,
      'rule': Icons.rule_folder,
      'calendar_today': Icons.calendar_today,
      'assessment': Icons.assessment,
      'settings': Icons.settings,
      'medical_services': Icons.medical_services,
      'local_hospital': Icons.local_hospital,
      'menu': Icons.menu,
    };
    return icons[iconName] ?? Icons.menu;
  }

  /// Toggle active/inactive menu
  void _toggleActive(MenuItem menu) async {
    setState(() => _isLoading = true);
    final success = await _menuService.toggleMenuActive(menu.id);
    setState(() => _isLoading = false);

    if (mounted) {
      _showSnackBar(
        success
            ? '✅ Cập nhật trạng thái thành công'
            : '❌ Cập nhật trạng thái thất bại',
        success,
      );
      if (success) _refreshData();
    }
  }

  /// Show snackbar
  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

