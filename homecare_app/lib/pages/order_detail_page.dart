import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderDetailPage extends StatefulWidget {
  final int invoiceId;

  const OrderDetailPage({super.key, required this.invoiceId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<List<OrderModel>> _detailOrders;

  @override
  void initState() {
    super.initState();
    _detailOrders = OrderService.getDetailOrder(widget.invoiceId);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _detailOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Pesanan tidak ditemukan.'));
          }

          final orders = snapshot.data!;
          final invoice = orders.first.invoice;
          final status = invoice?.status ?? '-';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice #${orders.first.idInvoice}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Status: '),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  'Layanan Dipesan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = orders[index];
                      final subtotal = item.harga * item.jumlah;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.namaLayanan,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jumlah: ${item.jumlah}'),
                            Text('Subtotal: Rp ${subtotal.toStringAsFixed(0)}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(thickness: 1),
                Text(
                  'Biaya Obat: Rp ${invoice?.biayaObat.toStringAsFixed(0) ?? "0"}',
                ),
                Text(
                  'Biaya Lainnya: Rp ${invoice?.biayaLain.toStringAsFixed(0) ?? "0"}',
                ),
                Text(
                  'Biaya Jalan: Rp ${invoice?.biayaJalan.toStringAsFixed(0) ?? "0"}',
                ),
                const Divider(thickness: 1),
                Text(
                  'Grand Total: Rp ${invoice?.total.toStringAsFixed(0) ?? "0"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                if (invoice?.namaMedis != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Nama Medis: ${invoice!.namaMedis}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),

                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    child: const Text('Kembali'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
