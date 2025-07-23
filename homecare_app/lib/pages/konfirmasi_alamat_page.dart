import 'package:flutter/material.dart';
import 'package:homecare_app/models/cart_model.dart';
import '../../models/user_model.dart';
import '../../models/address_model.dart';
import '../../services/user_service.dart';
import 'edit_address_page.dart';
import '../../services/order_service.dart';
import '../pages/dashboard_page.dart';

class KonfirmasiAlamatPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const KonfirmasiAlamatPage({super.key, required this.cartItems});

  @override
  State<KonfirmasiAlamatPage> createState() => _KonfirmasiAlamatPageState();
}

class _KonfirmasiAlamatPageState extends State<KonfirmasiAlamatPage> {
  UserModel? _user;
  AddressModel? _address;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await UserService.getProfile();
      if (response['success']) {
        final data = response['data'];
        setState(() {
          _user = UserModel.fromJson(data['user']);
          _address = AddressModel.fromJson(data['address']);
        });
      } else {
        debugPrint('Gagal mengambil data user: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Exception mengambil data user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditAddressPage()),
    );

    if (result == true) {
      await _fetchUserData();
      setState(() {});
    }
  }

  Future<void> _checkout() async {
    if (_user == null || _address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pengguna atau alamat tidak lengkap'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    bool semuaBerhasil = true;

    for (var item in widget.cartItems) {
      final result = await OrderService.createOrder(
        idLayanan: item.layanan.idLayanan,
        namaLayanan: item.layanan.jenisLayanan,
        jumlah: item.jumlah,
        harga: item.layanan.harga.toDouble(),
      );

      if (result == null) {
        semuaBerhasil = false;
        break;
      }
    }

    Navigator.pop(context); // Tutup loading dialog

    if (semuaBerhasil) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (_) => const DashboardPage(initialIndex: 1, showSuccess: true),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal melakukan checkout')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Alamat'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _user == null
              ? const Center(child: Text('Data pengguna tidak tersedia'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Pasien: ${_user!.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Desa: ${_address?.desa ?? '-'}'),
                            Text('Kecamatan: ${_address?.kecamatan ?? '-'}'),
                            Text('Kabupaten: ${_address?.kabupaten ?? '-'}'),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _navigateToEditPage,
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF2E7D32),
                                ),
                                label: const Text('Edit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
