
import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/providers/auth_provider.dart';
import 'package:doanmobile/src/core/services/menu_service.dart';
import 'package:doanmobile/src/widgets/icon_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddEditMenuScreen extends StatefulWidget {
  final MenuItem? menu;
  final List<MenuItem> allMenus;

  const AddEditMenuScreen({super.key, this.menu, required this.allMenus});

  @override
  State<AddEditMenuScreen> createState() => _AddEditMenuScreenState();
}

class _AddEditMenuScreenState extends State<AddEditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _menuService = MenuService();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _pathController;
  late TextEditingController _orderIndexController;

  // State
  String _selectedIcon = 'menu';
  int? _selectedParentId;
  bool _isActive = true;
  bool _isNameManuallyChanged = false;
  Set<int> _selectedRoleIds = {}; // Set để lưu các ID của role được chọn

  @override
  void initState() {
    super.initState();
    final menu = widget.menu;
    _titleController = TextEditingController(text: menu?.title ?? '');
    _nameController = TextEditingController(text: menu?.name ?? '');
    _pathController = TextEditingController(text: menu?.path ?? '');
    _orderIndexController = TextEditingController(text: menu?.orderIndex.toString() ?? '0');
    _selectedIcon = menu?.icon ?? 'menu';
    _selectedParentId = menu?.parentId;
    _isActive = menu?.active ?? true;
    
    // Khởi tạo các role đã được chọn nếu ở chế độ sửa
    if (menu != null) {
      final allRoles = Provider.of<AuthProvider>(context, listen: false).allRoles;
      _selectedRoleIds = allRoles.entries
        .where((entry) => menu.roles.contains(entry.value))
        .map((entry) => entry.key)
        .toSet();
    }

    _titleController.addListener(_onTitleChanged);
  }

  void _onTitleChanged() {
    if (widget.menu == null && !_isNameManuallyChanged) {
      final slug = _slugify(_titleController.text);
      _nameController.text = slug.replaceAll('-', '_');
      _pathController.text = '/$slug';
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _nameController.dispose();
    _pathController.dispose();
    _orderIndexController.dispose();
    super.dispose();
  }

  void _saveMenu() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoleIds.isEmpty) {
      _showSnackBar('Phải chọn ít nhất một vai trò được phép truy cập.', false);
      return;
    }

    setState(() => _isLoading = true);

    final menuData = {
      'title': _titleController.text,
      'name': _nameController.text,
      'path': _pathController.text,
      'icon': _selectedIcon,
      'orderIndex': int.tryParse(_orderIndexController.text) ?? 0,
      'parentId': _selectedParentId,
      'active': _isActive,
      'roleIds': _selectedRoleIds.toList(), // Gửi danh sách ID của role
    };

    final isEditMode = widget.menu != null;
    final result = isEditMode
        ? await _menuService.updateMenu(widget.menu!.id, menuData)
        : await _menuService.createMenu(menuData);

    if (mounted) {
      _showSnackBar(result != null ? 'Lưu thành công!' : 'Thao tác thất bại.', result != null);
      if (result != null) Navigator.of(context).pop(true);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.menu != null ? 'Chỉnh sửa Menu' : 'Thêm Menu mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề (*)', helperText: 'Tên sẽ hiển thị cho người dùng.'),
                validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              _buildRolePicker(), // Widget chọn Role
              const SizedBox(height: 16),
              _buildIconPicker(),
              const SizedBox(height: 16),
              _buildParentMenuDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderIndexController,
                decoration: const InputDecoration(labelText: 'Thứ tự hiển thị (*)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(title: const Text('Kích hoạt'), value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Cài đặt nâng cao', style: TextStyle(fontSize: 14)),
                tilePadding: EdgeInsets.zero,
                children: [
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Mã định danh (name)'), onChanged: (_) => _isNameManuallyChanged = true),
                  const SizedBox(height: 16),
                  TextFormField(controller: _pathController, decoration: const InputDecoration(labelText: 'Đường dẫn (path)'), onChanged: (_) => _isNameManuallyChanged = true),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveMenu,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Lưu lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRolePicker() {
    final allRoles = context.watch<AuthProvider>().allRoles;
    if (allRoles.isEmpty) return const SizedBox.shrink();

    return InputDecorator(
       decoration: const InputDecoration(
        labelText: 'Phân quyền truy cập (*)',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: allRoles.entries.map((entry) {
          final roleId = entry.key;
          final roleName = entry.value.replaceAll('ROLE_', '');
          final isSelected = _selectedRoleIds.contains(roleId);
          return FilterChip(
            label: Text(roleName),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _selectedRoleIds.add(roleId);
                } else {
                  _selectedRoleIds.remove(roleId);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIconPicker() {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Icon hiển thị (*)', border: OutlineInputBorder()),
      child: InkWell(
        onTap: () async {
          final String? iconName = await showDialog(context: context, builder: (context) => const IconPickerDialog());
          if (iconName != null) setState(() => _selectedIcon = iconName);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [Icon(availableIcons[_selectedIcon], color: Theme.of(context).primaryColor), const SizedBox(width: 12), Text(_selectedIcon)]),
            const Text('Chọn', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildParentMenuDropdown() {
     List<MenuItem> flatList = [];
    void flatten(List<MenuItem> menus) {
      for (var menu in menus) {
        flatList.add(menu);
        if (menu.hasChildren) flatten(menu.children);
      }
    }
    flatten(widget.allMenus);

    return DropdownButtonFormField<int?>(
      value: _selectedParentId,
      decoration: const InputDecoration(labelText: 'Menu cha'),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('-- Là menu gốc --')),
        ...flatList.map((menu) {
          if (widget.menu != null && widget.menu!.id == menu.id) return null;
          return DropdownMenuItem<int?>(value: menu.id, child: Text('${ '--' * menu.depth } ${menu.title}'));
        }).whereType<DropdownMenuItem<int?>>(),
      ],
      onChanged: (newValue) => setState(() => _selectedParentId = newValue),
    );
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: success ? Colors.green : Colors.red),
    );
  }

  String _slugify(String text) {
    text = text.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    text = text.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    text = text.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    text = text.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    text = text.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    text = text.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    text = text.replaceAll(RegExp(r'[đ]'), 'd');
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 -]'), '').replaceAll(RegExp(r'\s+'), '-');
  }
}
