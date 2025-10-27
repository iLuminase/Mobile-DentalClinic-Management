import 'package:doanmobile/src/widgets/appoiment/appointment_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  final List<Map<String, dynamic>> _appointments = [];

  void _addAppointment(Map<String, dynamic> newAppt) {
    setState(() {
      _appointments.add(newAppt);
    });
  }

  void _editAppointment(int index, Map<String, dynamic> updated) {
    setState(() {
      _appointments[index] = updated;
    });
  }

  void _deleteAppointment(int index) {
    setState(() {
      _appointments.removeAt(index);
    });
  }

  void _openForm({Map<String, dynamic>? appointment, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppointmentForm(
        selectedDate: appointment?['date'] ?? DateTime.now(),
        initialData: appointment,
        onSave: (data) {
          if (index == null) {
            _addAppointment(data);
          } else {
            _editAppointment(index, data);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách lịch hẹn')),
      body: _appointments.isEmpty
          ? const Center(child: Text('Chưa có lịch hẹn nào'))
          : ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appt = _appointments[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(appt['name']),
              subtitle: Text(
                '${DateFormat('dd/MM/yyyy').format(appt['date'])} • ${appt['time']}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _openForm(appointment: appt, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAppointment(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
