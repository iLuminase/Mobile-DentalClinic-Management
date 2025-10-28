import 'package:doanmobile/src/core/models/booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';

class BookingScreen extends StatefulWidget {
  final Function(Booking) onBookingCreated;

  const BookingScreen({super.key, required this.onBookingCreated});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _noteController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  void _confirmBooking() {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ hẹn')),
      );
      return;
    }

    final formattedTime =
        '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

    final booking = Booking(
      date: selectedDate!,
      time: formattedTime,
      note: _noteController.text,
    );

    widget.onBookingCreated(booking);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : 'Chưa chọn';
    final formattedTime = selectedTime != null
        ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
        : 'Chưa chọn';

    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch hẹn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.teal),
              title: Text('Ngày: $formattedDate'),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.teal),
              title: Text('Giờ: $formattedTime'),
              onTap: () => _selectTime(context),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tuỳ chọn)',
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _confirmBooking,
              icon: const Icon(Icons.check),
              label: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
  }
}
