
import 'package:doanmobile/src/core/models/menu_item_model.dart';
import 'package:doanmobile/src/core/services/menu_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _pathController;
  late TextEditingController _iconController;
  late TextEditingController _orderIndexController;

  // State
  int? _selectedParentId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final menu = widget.menu;
    _nameController = TextEditingController(text: menu?.name ?? '');
    _titleController = TextEditingController(text: menu?.title ?? '');
    _pathController = TextEditingController(text: menu?.path ?? '');
    _iconController = TextEditingController(text: menu?.icon ?? '');
    _orderIndexController = TextEditingController(text: menu?.orderIndex.toString() ?? '0');
    _selectedParentId = menu?.parentId;
    _isActive = menu?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _pathController.dispose();
    _iconController.dispose();
    _orderIndexController.dispose();
    super.dispose();
  }

  void _saveMenu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final menuData = {
      'name': _nameController.text,
      'title': _titleController.text,
      'path': _pathController.text,
      'icon': _iconController.text,
      'orderIndex': int.tryParse(_orderIndexController.text) ?? 0,
      'parentId': _selectedParentId,
      'active': _isActive,
      // 'roleIds' sẽ được quản lý ở màn hình phân quyền, không gửi ở đây
    };

    final isEditMode = widget.menu != null;
    MenuItem? result;

    if (isEditMode) {
      result = await _menuService.updateMenu(widget.menu!.id, menuData);
    } else {
      result = await _menuService.createMenu(menuData);
    }

    if (mounted) {
      _showSnackBar(result != null ? 'Lưu thành công!' : 'Thao tác thất bại.', result != null);
      if (result != null) {
        Navigator.of(context).pop(true); // Trả về true để báo hiệu cần làm mới
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.menu != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa Menu' : 'Thêm Menu mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề (*)', hintText: 'Ví dụ: Quản lý Bệnh nhân'),
                validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên định danh (name) (*)', hintText: 'Ví dụ: patient_management'),
                validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pathController,
                decoration: const InputDecoration(labelText: 'Đường dẫn (path) (*)', hintText: 'Ví dụ: /patients'),
                validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _iconController,
                decoration: const InputDecoration(labelText: 'Tên Icon (*)', hintText: 'Ví dụ: people'),
                validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
              ),
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
              SwitchListTile(
                title: const Text('Kích hoạt'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Lưu lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParentMenuDropdown() {
    // Tạo danh sách phẳng từ cây menu
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
      // Thêm một item cho "Không có" (menu gốc)
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('-- Là menu gốc --')),
        ...flatList.map((menu) {
          return DropdownMenuItem<int?>(
            value: menu.id,
            // Hiển thị thụt vào cho đẹp
            child: Text('${ '--' * menu.depth } ${menu.title}'),
          );
        })
      ],
      onChanged: (newValue) {
        setState(() => _selectedParentId = newValue);
      },
    );
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: success ? Colors.green : Colors.red),
    );
  }
}
