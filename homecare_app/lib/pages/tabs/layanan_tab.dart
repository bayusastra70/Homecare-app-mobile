import 'package:flutter/material.dart';
import '../../models/layanan_model.dart';
import '../../models/cart_model.dart';
import '../../services/layanan_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/cart_bottom_sheet.dart';

class LayananTab extends StatefulWidget {
  const LayananTab({super.key});

  @override
  State<LayananTab> createState() => _LayananTabState();
}

class _LayananTabState extends State<LayananTab> {
  final LayananService _layananService = LayananService();
  final CartService _cartService = CartService();

  List<Layanan> _layananList = [];
  List<Layanan> _filteredLayananList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  static const Color greenPrimary = Color(0xFF2E7D32);
  static const Color greenLight = Color(0xFF66BB6A);

  @override
  void initState() {
    super.initState();
    fetchLayanan();
  }

  Future<void> fetchLayanan() async {
    try {
      final layanan = await _layananService.getAllLayanan();
      setState(() {
        _layananList = layanan;
        _filteredLayananList = layanan;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading layanan: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void addToCart(Layanan layanan) {
    final cartItem = CartItem(idCart: 0, jumlah: 1, layanan: layanan);
    _cartService.addToCart(cartItem);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CartBottomSheet(),
    );
  }

  void _filterLayanan(String query) {
    final filtered =
        _layananList.where((layanan) {
          return layanan.jenisLayanan.toLowerCase().contains(
            query.toLowerCase(),
          );
        }).toList();

    setState(() {
      _searchQuery = query;
      _filteredLayananList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari layanan...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF66BB6A),
                  ), // hijau muda
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 2,
                  ),
                ),
              ),
              onChanged: _filterLayanan,
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  _filteredLayananList.isEmpty
                      ? const Center(child: Text('Layanan tidak ditemukan'))
                      : ListView.builder(
                        itemCount: _filteredLayananList.length,
                        itemBuilder: (context, index) {
                          final layanan = _filteredLayananList[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    layanan.jenisLayanan,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    layanan.keterangan,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Rp ${layanan.harga}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2E7D32,
                                          ), // hijau utama
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => addToCart(layanan),
                                        child: const Text(
                                          'Tambah ke Keranjang',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
