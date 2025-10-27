import 'package:flutter/material.dart';
import 'invoice_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final List<Map<String, dynamic>> _services = [
    {'name': 'Khám răng tổng quát', 'price': 100000},
    {'name': 'Làm trắng răng', 'price': 500000},
    {'name': 'Trám răng', 'price': 300000},
    {'name': 'Cạo vôi răng', 'price': 200000},
  ];

  int? _selectedIndex;

  void _confirmPayment() {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một dịch vụ để thanh toán')),
      );
      return;
    }

    final selectedService = _services[_selectedIndex!];
    final invoiceData = {
      'service': selectedService['name'],
      'price': selectedService['price'],
      'date': DateTime.now().toString(),
      'invoiceId': 'HD${DateTime.now().millisecondsSinceEpoch}'
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePage(invoiceData: invoiceData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán dịch vụ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn dịch vụ bạn muốn thanh toán:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final isSelected = _selectedIndex == index;
                  return Card(
                    color: isSelected ? Colors.green[100] : null,
                    child: ListTile(
                      title: Text(service['name']),
                      subtitle: Text('${service['price']} VNĐ'),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () => setState(() => _selectedIndex = index),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _confirmPayment,
                icon: const Icon(Icons.payment),
                label: const Text('Thanh toán'),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  backgroundColor: Colors.green,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
