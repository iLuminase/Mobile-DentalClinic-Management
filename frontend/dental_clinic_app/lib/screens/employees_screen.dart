import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../services/api_service.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<Employee> employees = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final apiService = Provider.of<ApiService>(context, listen: false);
      final fetchedEmployees = await apiService.getEmployees();

      setState(() {
        employees = fetchedEmployees;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Employees',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEmployeeDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Employee'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading employees',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmployees,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Add your first employee to get started'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddEmployeeDialog(),
              child: const Text('Add Employee'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return _EmployeeCard(
            employee: employee,
            onEdit: () => _showEditEmployeeDialog(employee),
            onDelete: () => _deleteEmployee(employee),
          );
        },
      ),
    );
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => _EmployeeFormDialog(
        onSave: _createEmployee,
      ),
    );
  }

  void _showEditEmployeeDialog(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => _EmployeeFormDialog(
        employee: employee,
        onSave: (updatedEmployee) => _updateEmployee(employee.id!, updatedEmployee),
      ),
    );
  }

  Future<void> _createEmployee(Map<String, dynamic> employeeData) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.createEmployee(employeeData);
      _loadEmployees();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating employee: $e')),
        );
      }
    }
  }

  Future<void> _updateEmployee(int id, Employee employee) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.updateEmployee(id, employee);
      _loadEmployees();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating employee: $e')),
        );
      }
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        await apiService.deleteEmployee(employee.id!);
        _loadEmployees();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting employee: $e')),
          );
        }
      }
    }
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(employee.role),
          child: Text(
            employee.firstName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          employee.fullName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.email),
            Text(
              _getRoleDisplay(employee.role),
              style: TextStyle(
                color: _getRoleColor(employee.role),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getRoleColor(EmployeeRole role) {
    switch (role) {
      case EmployeeRole.admin:
        return Colors.red;
      case EmployeeRole.dentist:
        return Colors.blue;
      case EmployeeRole.receptionist:
        return Colors.green;
      case EmployeeRole.assistant:
        return Colors.orange;
    }
  }

  String _getRoleDisplay(EmployeeRole role) {
    return role.toString().split('.').last.toUpperCase();
  }
}

class _EmployeeFormDialog extends StatefulWidget {
  final Employee? employee;
  final Function(dynamic) onSave;

  const _EmployeeFormDialog({
    this.employee,
    required this.onSave,
  });

  @override
  State<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _specializationController;
  late TextEditingController _licenseController;
  
  EmployeeRole _selectedRole = EmployeeRole.receptionist;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.employee?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.employee?.lastName ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _phoneController = TextEditingController(text: widget.employee?.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _specializationController = TextEditingController(text: widget.employee?.specialization ?? '');
    _licenseController = TextEditingController(text: widget.employee?.licenseNumber ?? '');
    
    if (widget.employee != null) {
      _selectedRole = widget.employee!.role;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _specializationController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;
    
    return AlertDialog(
      title: Text(isEdit ? 'Edit Employee' : 'Add Employee'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Required';
                    if (!value!.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Required';
                      if (value!.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<EmployeeRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: EmployeeRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specializationController,
                  decoration: const InputDecoration(labelText: 'Specialization'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseController,
                  decoration: const InputDecoration(labelText: 'License Number'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (widget.employee != null) {
        // Update existing employee
        final updatedEmployee = Employee(
          id: widget.employee!.id,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          role: _selectedRole,
          specialization: _specializationController.text.isEmpty ? null : _specializationController.text,
          licenseNumber: _licenseController.text.isEmpty ? null : _licenseController.text,
        );
        widget.onSave(updatedEmployee);
      } else {
        // Create new employee
        final employeeData = {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
          'password': _passwordController.text,
          'role': _selectedRole.toString().split('.').last.toUpperCase(),
          'specialization': _specializationController.text.isEmpty ? null : _specializationController.text,
          'licenseNumber': _licenseController.text.isEmpty ? null : _licenseController.text,
        };
        widget.onSave(employeeData);
      }
      Navigator.pop(context);
    }
  }
}