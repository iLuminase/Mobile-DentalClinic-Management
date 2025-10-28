import 'package:flutter/material.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final TextEditingController _customerController = TextEditingController();

  // Danh sách dịch vụ có sẵn
  final List<Map<String, dynamic>> _services = [
    {'name': 'Khám và chữa bệnh tổng quát', 'price': 200000, 'selected': false},
    {'name': 'Khám chuyên khoa sâu', 'price': 300000, 'selected': false},
    {'name': 'Khám tại nhà', 'price': 500000, 'selected': false},
    {'name': 'Xét nghiệm', 'price': 150000, 'selected': false},
    {'name': 'Chẩn đoán hình ảnh', 'price': 250000, 'selected': false},
    {'name': 'Tiêm truyền, cấp cứu, tư vấn sức khỏe', 'price': 180000, 'selected': false},
  ];

  // Danh sách hóa đơn đã tạo
  final List<Map<String, dynamic>> _invoices = [];

  // ✅ Tạo hóa đơn mới
  void _createInvoice() {
    String customer = _customerController.text.trim();
    if (customer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên khách hàng')),
      );
      return;
    }

    final selectedServices = _services.where((s) => s['selected'] == true).toList();
    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một dịch vụ')),
      );
      return;
    }

    int total = selectedServices.fold(0, (sum, item) => sum + (item['price'] as int));

    setState(() {
      _invoices.add({
        'id': 'HD${_invoices.length + 1}'.padLeft(6, '0'),
        'customer': customer,
        'services': List<Map<String, dynamic>>.from(selectedServices),
        'total': total,
        'date': DateTime.now(),
        'isPaid': false,
      });

      _customerController.clear();
      for (var s in _services) {
        s['selected'] = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã tạo hóa đơn mới')),
    );
  }

  // ✅ Thanh toán hóa đơn
  void _confirmPayment(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thanh toán'),
        content: Text('Bạn có chắc muốn thanh toán hóa đơn ${invoice['id']} không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                invoice['isPaid'] = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Đã thanh toán hóa đơn ${invoice['id']}')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  // ✅ Xem chi tiết hóa đơn
  void _showInvoiceDetail(Map<String, dynamic> invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            Text('🧾 Hóa đơn #${invoice['id']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Khách hàng: ${invoice['customer']}'),
            Text('Ngày: ${invoice['date'].toString().split(".").first}'),
            const SizedBox(height: 10),
            const Text('Dịch vụ:'),
            ...invoice['services']
                .map<Widget>((s) => Text('- ${s['name']} (${s['price']}đ)'))
                .toList(),
            const SizedBox(height: 10),
            Text('Tổng cộng: ${invoice['total']}đ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 10),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice['isPaid'] ? 'Trạng thái: ĐÃ THANH TOÁN' : 'Trạng thái: CHƯA THANH TOÁN',
                  style: TextStyle(
                    color: invoice['isPaid'] ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!invoice['isPaid'])
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmPayment(invoice);
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Thanh toán'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý hóa đơn')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tạo hóa đơn mới',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),
              TextField(
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: 'Tên khách hàng',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Chọn dịch vụ:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              Column(
                children: _services.map((service) {
                  return CheckboxListTile(
                    title: Text('${service['name']} (${service['price']} VNĐ)'),
                    value: service['selected'] as bool,
                    onChanged: (bool? value) {
                      setState(() {
                        service['selected'] = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _createInvoice,
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Tạo hóa đơn'),
                ),
              ),

              const Divider(height: 32),
              const Text('Danh sách hóa đơn:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),
              if (_invoices.isEmpty)
                const Text('Chưa có hóa đơn nào được tạo.'),
              ..._invoices.map((invoice) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      invoice['isPaid'] ? Icons.check_circle : Icons.receipt_long,
                      color: invoice['isPaid'] ? Colors.green : Colors.blueAccent,
                    ),
                    title: Text(invoice['customer']),
                    subtitle: Text('Tổng: ${invoice['total']}đ'),
                    trailing: Text(
                      invoice['isPaid'] ? 'Đã TT' : 'Chưa TT',
                      style: TextStyle(
                        color: invoice['isPaid'] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _showInvoiceDetail(invoice),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
