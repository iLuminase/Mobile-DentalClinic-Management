import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_screen.dart';

class Appointment {
  String id;
  String name;
  String phone;
  DateTime dateTime;
  String note;

  Appointment({
    required this.id,
    required this.name,
    required this.phone,
    required this.dateTime,
    required this.note,
  });
}

class BookingCalendarScreen extends StatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  final List<Appointment> _appointments = [];

  // Dữ liệu form
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDateTime;

  // 🗓️ Chọn ngày giờ
  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

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

  // ➕ Lưu hoặc cập nhật lịch hẹn
  void _saveAppointment({Appointment? editing}) {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ thông tin và chọn ngày giờ")),
      );
      return;
    }

    setState(() {
      if (editing != null) {
        // Cập nhật lịch hẹn
        editing.name = _nameController.text;
        editing.phone = _phoneController.text;
        editing.dateTime = _selectedDateTime!;
        editing.note = _noteController.text;
      } else {
        // Thêm mới
        _appointments.add(Appointment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          phone: _phoneController.text,
          dateTime: _selectedDateTime!,
          note: _noteController.text,
        ));
      }
    });

    Navigator.pop(context);
    _clearForm();
  }

  // ❌ Xóa lịch hẹn
  void _deleteAppointment(String id) {
    setState(() {
      _appointments.removeWhere((a) => a.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã xóa lịch hẹn")),
    );
  }

  // 🧹 Xóa dữ liệu form
  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _noteController.clear();
    _selectedDateTime = null;
  }

  // 📋 Mở form thêm/sửa lịch hẹn
  void _openForm({Appointment? editing}) {
    if (editing != null) {
      _nameController.text = editing.name;
      _phoneController.text = editing.phone;
      _noteController.text = editing.note;
      _selectedDateTime = editing.dateTime;
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                editing == null ? "Đặt lịch hẹn" : "Chỉnh sửa lịch hẹn",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),

              // Họ và tên
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Họ và tên",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Nhập họ và tên" : null,
              ),
              const SizedBox(height: 12),

              // Số điện thoại
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.isEmpty ? "Nhập số điện thoại" : null,
              ),
              const SizedBox(height: 12),

              // Ngày hẹn
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: Text(
                  _selectedDateTime == null
                      ? "Chọn ngày và giờ"
                      : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!),
                ),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 12),

              // Ghi chú
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Ghi chú",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => _saveAppointment(editing: editing),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: Text(editing == null ? "Xác nhận đặt lịch" : "Lưu thay đổi"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧱 Giao diện chính
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đặt lịch hẹn"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _appointments.isEmpty
          ? const Center(child: Text("Chưa có lịch hẹn nào"))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final a = _appointments[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_available, color: Colors.teal),
              title: Text("${a.name} - ${a.phone}"),
              subtitle: Text(
                "${DateFormat('dd/MM/yyyy HH:mm').format(a.dateTime)}\n${a.note}",
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _openForm(editing: a);
                  } else if (value == 'delete') {
                    _deleteAppointment(a.id);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
