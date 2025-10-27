import 'package:flutter/material.dart';

class InvoicePage extends StatelessWidget {
  final Map<String, dynamic> invoiceData;

  const InvoicePage({Key? key, required this.invoiceData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = invoiceData['service'];
    final price = invoiceData['price'];
    final date = invoiceData['date'];
    final invoiceId = invoiceData['invoiceId'];

    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PHÒNG KHÁM NHA KHOA SMILE CARE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text('Mã hóa đơn: $invoiceId'),
                  Text('Ngày thanh toán: $date'),
                  const Divider(thickness: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dịch vụ:'),
                      Text(service, style: const TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền:'),
                      Text('$price VNĐ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green))
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.done),
                    label: const Text('Hoàn tất'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
