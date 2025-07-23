import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import '../pages/konfirmasi_alamat_page.dart';

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({Key? key}) : super(key: key);

  @override
  _CartBottomSheetState createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  List<CartItem> cartItems = [];
  double totalHarga = 0.0;

  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    cartItems = CartService().cartItems;
    totalHarga = CartService().getTotalHarga();
    setState(() {});
  }

  void _removeFromCart(int layananId) {
    CartService().removeFromCart(layananId);
    _loadCartItems();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item dihapus dari keranjang')),
    );
  }

  void _updateQuantity(int layananId, int newQuantity) {
    CartService().updateQuantity(layananId, newQuantity);
    _loadCartItems();
  }

  void _checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KonfirmasiAlamatPage(cartItems: cartItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              const Text(
                'Keranjang Belanja',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    cartItems.isEmpty
                        ? const Center(child: Text('Keranjang kosong'))
                        : ListView.builder(
                          controller: scrollController,
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.layanan.jenisLayanan,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          formatCurrency.format(
                                            item.layanan.harga,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          if (item.jumlah > 1) {
                                            _updateQuantity(
                                              item.layanan.idLayanan,
                                              item.jumlah - 1,
                                            );
                                          }
                                        },
                                      ),
                                      Text(item.jumlah.toString()),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          _updateQuantity(
                                            item.layanan.idLayanan,
                                            item.jumlah + 1,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _removeFromCart(
                                            item.layanan.idLayanan,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Harga:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency.format(totalHarga),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cartItems.isNotEmpty ? _checkout : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Checkout', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
