import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../order_detail_page.dart';

class PesananTab extends StatefulWidget {
  final bool showSuccess;

  const PesananTab({super.key, this.showSuccess = false});

  @override
  State<PesananTab> createState() => _PesananTabState();
}

class _PesananTabState extends State<PesananTab> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final result = await OrderService.getAllOrders();
    setState(() {
      _orders = result;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'paying':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _confirmCancel(int invoiceId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Batalkan Pesanan'),
            content: const Text('Yakin ingin membatalkan pesanan ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await OrderService.cancelOrder(invoiceId);
                  if (success) {
                    setState(() {
                      _orders.removeWhere(
                        (order) => order.idInvoice == invoiceId,
                      );
                    });
                    _showDialog('Pesanan berhasil dibatalkan');
                  } else {
                    _showDialog('Gagal membatalkan pesanan');
                  }
                },
                child: const Text('Ya, Batalkan'),
              ),
            ],
          ),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? const Center(child: Text('Belum ada pesanan.'))
              : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final status = order.status?.toLowerCase() ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#INV-${order.idInvoice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Status: ',
                                style: TextStyle(fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Layanan: ${order.namaLayanan}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Jumlah: ${order.jumlah}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (status == 'pending' ||
                                  status == 'accepted') ...[
                                OutlinedButton(
                                  onPressed:
                                      () => _confirmCancel(order.idInvoice),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text('Batalkan'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => OrderDetailPage(
                                              invoiceId: order.idInvoice,
                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                  ),
                                  child: const Text('Lihat Detail'),
                                ),
                              ] else if (status == 'paying') ...[
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Arahkan ke halaman tagihan
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Navigasi ke halaman tagihan',
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                  ),
                                  child: const Text('Lihat Tagihan'),
                                ),
                              ],
                            ],
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
