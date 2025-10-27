import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentForm extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const AppointmentForm({
    super.key,
    required this.selectedDate,
    this.initialData,
    required this.onSave,
  });

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name']);
    _noteController = TextEditingController(text: widget.initialData?['note']);
    _selectedTime = widget.initialData != null
        ? _parseTime(widget.initialData!['time'])
        : null;
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        'name': _nameController.text,
        'note': _noteController.text,
        'date': widget.selectedDate,
        'time': _selectedTime?.format(context) ?? 'Chưa chọn',
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: controller,
            children: [
              Text(
                widget.initialData == null
                    ? '🗓️ Thêm lịch hẹn mới'
                    : '✏️ Sửa lịch hẹn',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // ✅ Trường nhập tên có kiểm tra ràng buộc ký tự
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên khách hàng',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Vui lòng nhập tên';
                  }

                  // Regex: chỉ cho phép chữ cái (có dấu tiếng Việt) và khoảng trắng
                  final nameRegExp = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$');
                  if (!nameRegExp.hasMatch(v)) {
                    return 'Tên chỉ được chứa chữ cái và khoảng trắng';
                  }

                  if (v.trim().length < 2) {
                    return 'Tên quá ngắn';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _selectTime,
                icon: const Icon(Icons.access_time),
                label: Text(_selectedTime == null
                    ? 'Chọn giờ'
                    : _selectedTime!.format(context)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Lưu', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
