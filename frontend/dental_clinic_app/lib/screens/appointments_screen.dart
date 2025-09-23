import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> appointments = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final apiService = Provider.of<ApiService>(context, listen: false);
      final fetchedAppointments = await apiService.getAppointments();

      setState(() {
        appointments = fetchedAppointments;
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
                  'Appointments',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddAppointmentDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Book Appointment'),
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
              'Error loading appointments',
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
              onPressed: _loadAppointments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Book your first appointment to get started'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddAppointmentDialog(),
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _AppointmentCard(
            appointment: appointment,
            onEdit: () => _showEditAppointmentDialog(appointment),
            onDelete: () => _deleteAppointment(appointment),
            onStatusChange: (status) => _updateAppointmentStatus(appointment, status),
          );
        },
      ),
    );
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => _AppointmentFormDialog(
        onSave: _createAppointment,
      ),
    );
  }

  void _showEditAppointmentDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => _AppointmentFormDialog(
        appointment: appointment,
        onSave: (updatedAppointment) => _updateAppointment(appointment.id!, updatedAppointment),
      ),
    );
  }

  Future<void> _createAppointment(Appointment appointment) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.createAppointment(appointment);
      _loadAppointments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating appointment: $e')),
        );
      }
    }
  }

  Future<void> _updateAppointment(int id, Appointment appointment) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.updateAppointment(id, appointment);
      _loadAppointments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating appointment: $e')),
        );
      }
    }
  }

  Future<void> _updateAppointmentStatus(Appointment appointment, AppointmentStatus status) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final updatedAppointment = Appointment(
        id: appointment.id,
        customerId: appointment.customerId,
        employeeId: appointment.employeeId,
        appointmentDateTime: appointment.appointmentDateTime,
        serviceType: appointment.serviceType,
        status: status,
        durationMinutes: appointment.durationMinutes,
        description: appointment.description,
        notes: appointment.notes,
        cost: appointment.cost,
      );
      
      await apiService.updateAppointment(appointment.id!, updatedAppointment);
      _loadAppointments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment status updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text('Are you sure you want to delete this appointment with ${appointment.customerName}?'),
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
        await apiService.deleteAppointment(appointment.id!);
        _loadAppointments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting appointment: $e')),
          );
        }
      }
    }
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(AppointmentStatus) onStatusChange;

  const _AppointmentCard({
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.customerName ?? 'Unknown Customer',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'with ${appointment.employeeName ?? 'Unknown Doctor'}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
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
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(dateFormat.format(appointment.appointmentDateTime)),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text('${timeFormat.format(appointment.appointmentDateTime)} - ${timeFormat.format(appointment.endTime)}'),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.medical_services, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(appointment.serviceType),
              ],
            ),
            
            if (appointment.description != null) ...[
              const SizedBox(height: 8),
              Text(
                appointment.description!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(appointment.status)),
                  ),
                  child: Text(
                    _getStatusDisplay(appointment.status),
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                DropdownButton<AppointmentStatus>(
                  value: appointment.status,
                  underline: const SizedBox(),
                  items: AppointmentStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusDisplay(status)),
                    );
                  }).toList(),
                  onChanged: (status) {
                    if (status != null && status != appointment.status) {
                      onStatusChange(status);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.inProgress:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.purple;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }

  String _getStatusDisplay(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }
}

class _AppointmentFormDialog extends StatefulWidget {
  final Appointment? appointment;
  final Function(Appointment) onSave;

  const _AppointmentFormDialog({
    this.appointment,
    required this.onSave,
  });

  @override
  State<_AppointmentFormDialog> createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<_AppointmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serviceTypeController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;
  
  DateTime? _selectedDateTime;
  int _durationMinutes = 60;
  int? _selectedCustomerId;
  int? _selectedEmployeeId;
  
  List<Customer> customers = [];
  List<Employee> employees = [];
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _serviceTypeController = TextEditingController(text: widget.appointment?.serviceType ?? '');
    _descriptionController = TextEditingController(text: widget.appointment?.description ?? '');
    _costController = TextEditingController(text: widget.appointment?.cost?.toString() ?? '');
    
    if (widget.appointment != null) {
      _selectedDateTime = widget.appointment!.appointmentDateTime;
      _durationMinutes = widget.appointment!.durationMinutes;
      _selectedCustomerId = widget.appointment!.customerId;
      _selectedEmployeeId = widget.appointment!.employeeId;
    }
    
    _loadData();
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final fetchedCustomers = await apiService.getCustomers();
      final fetchedEmployees = await apiService.getEmployees();
      
      setState(() {
        customers = fetchedCustomers;
        employees = fetchedEmployees;
        _loadingData = false;
      });
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.appointment != null;
    
    return AlertDialog(
      title: Text(isEdit ? 'Edit Appointment' : 'Book Appointment'),
      content: _loadingData
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedCustomerId,
                        decoration: const InputDecoration(labelText: 'Customer'),
                        items: customers.map((customer) {
                          return DropdownMenuItem(
                            value: customer.id,
                            child: Text(customer.fullName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCustomerId = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a customer' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<int>(
                        value: _selectedEmployeeId,
                        decoration: const InputDecoration(labelText: 'Doctor/Staff'),
                        items: employees.map((employee) {
                          return DropdownMenuItem(
                            value: employee.id,
                            child: Text('${employee.fullName} (${employee.role.toString().split('.').last})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEmployeeId = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a doctor/staff' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      ListTile(
                        title: Text(_selectedDateTime != null 
                            ? 'Date & Time: ${DateFormat('MMM dd, yyyy HH:mm').format(_selectedDateTime!)}'
                            : 'Select Date & Time'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectDateTime,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<int>(
                        value: _durationMinutes,
                        decoration: const InputDecoration(labelText: 'Duration'),
                        items: [30, 60, 90, 120].map((minutes) {
                          return DropdownMenuItem(
                            value: minutes,
                            child: Text('$minutes minutes'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _durationMinutes = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _serviceTypeController,
                        decoration: const InputDecoration(labelText: 'Service Type'),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(labelText: 'Cost (\$)'),
                        keyboardType: TextInputType.number,
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
          onPressed: _loadingData ? null : _handleSave,
          child: Text(isEdit ? 'Update' : 'Book'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate() && _selectedDateTime != null) {
      final appointment = Appointment(
        id: widget.appointment?.id,
        customerId: _selectedCustomerId!,
        employeeId: _selectedEmployeeId!,
        appointmentDateTime: _selectedDateTime!,
        durationMinutes: _durationMinutes,
        serviceType: _serviceTypeController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        cost: _costController.text.isEmpty ? null : double.tryParse(_costController.text),
      );
      
      widget.onSave(appointment);
      Navigator.pop(context);
    } else if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
    }
  }
}