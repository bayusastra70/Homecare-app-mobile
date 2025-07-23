import 'package:flutter/material.dart';
import 'package:homecare_app/services/user_service.dart';

class EditAddressPage extends StatefulWidget {
  final VoidCallback? onAddressUpdated;

  const EditAddressPage({Key? key, this.onAddressUpdated}) : super(key: key);

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _alamatController = TextEditingController();

  String? _selectedKabupaten;
  String? _selectedKecamatan;
  String? _selectedDesa;

  List<dynamic> _kabupatenList = [];
  List<dynamic> _kecamatanList = [];
  List<dynamic> _desaList = [];

  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final profile = await UserService.getProfile();
      if (profile['success']) {
        final data = profile['data'];
        final address = data['address'];

        if (address != null) {
          _alamatController.text = address['alamat'] ?? '';
          _selectedKabupaten = address['kabupaten_id']?.toString();
          _selectedKecamatan = address['kecamatan_id']?.toString();
          _selectedDesa = address['desa_id']?.toString();

          await _fetchKabupaten();

          if (_selectedKabupaten != null) {
            await _fetchKecamatan(_selectedKabupaten!);
          }
          if (_selectedKecamatan != null) {
            await _fetchDesa(_selectedKecamatan!);
          }
        } else {
          await _fetchKabupaten();
        }
      } else {
        print("Gagal mendapatkan profil: ${profile['message']}");
      }
    } catch (e, stack) {
      print("Exception saat load data awal: $e\n$stack");
    }

    setState(() {
      _isFetching = false;
    });
  }

  Future<void> _fetchKabupaten() async {
    try {
      final response = await UserService.fetchKabupaten();
      if (response['success']) {
        setState(() {
          _kabupatenList = (response['data'] as List);
        });
      } else {
        print("Fetch kabupaten gagal: ${response['message']}");
      }
    } catch (e) {
      print("Exception fetch kabupaten: $e");
    }
  }

  Future<void> _fetchKecamatan(String kabId) async {
    try {
      final response = await UserService.fetchKecamatan(kabId);
      if (response['success']) {
        setState(() {
          _kecamatanList = response['data'] ?? [];
        });
      } else {
        print("Fetch kecamatan gagal: ${response['message']}");
      }
    } catch (e) {
      print("Exception fetch kecamatan: $e");
    }
  }

  Future<void> _fetchDesa(String kecId) async {
    try {
      final response = await UserService.fetchDesa(kecId);
      if (response['success']) {
        setState(() {
          _desaList = response['data'] ?? [];
        });
      } else {
        print("Fetch desa gagal: ${response['message']}");
      }
    } catch (e) {
      print("Exception fetch desa: $e");
    }
  }

  Future<void> _updateProfile() async {
    final updatedProfile = await UserService.getProfile();
    setState(() {
      _alamatController.text = updatedProfile['data']['alamat'] ?? '';
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedKabupaten != null &&
        _selectedKecamatan != null &&
        _selectedDesa != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await UserService.updateAddress(
          alamat: _alamatController.text,
          desa: _selectedDesa!,
          kecamatan: _selectedKecamatan!,
          kabupaten: _selectedKabupaten!,
        );

        if (result['success']) {
          await _updateProfile();
          if (mounted) {
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text('Berhasil'),
                    content: const Text('Alamat berhasil diperbarui'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context, true);
                          widget.onAddressUpdated?.call();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
          }
        } else {
          _showErrorDialog(result['message'] ?? 'Gagal memperbarui alamat');
        }
      } catch (e) {
        _showErrorDialog('Terjadi kesalahan: $e');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Gagal'),
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
        title: const Text('Edit Alamat'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body:
          _isFetching
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _alamatController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Lengkap',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Alamat tidak boleh kosong'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value:
                            _selectedKabupaten == ''
                                ? null
                                : _selectedKabupaten,
                        decoration: const InputDecoration(
                          labelText: 'Kabupaten',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _kabupatenList.map<DropdownMenuItem<String>>((
                              item,
                            ) {
                              return DropdownMenuItem<String>(
                                value: item['id_kabupaten'].toString(),
                                child: Text(item['nama']),
                              );
                            }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedKabupaten = value;
                            _selectedKecamatan = null;
                            _selectedDesa = null;
                            _kecamatanList = [];
                            _desaList = [];
                          });
                          if (value != null) {
                            await _fetchKecamatan(value);
                          }
                        },
                        validator:
                            (value) => value == null ? 'Pilih kabupaten' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value:
                            _selectedKecamatan == ''
                                ? null
                                : _selectedKecamatan,
                        decoration: const InputDecoration(
                          labelText: 'Kecamatan',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _kecamatanList.map<DropdownMenuItem<String>>((
                              item,
                            ) {
                              return DropdownMenuItem<String>(
                                value: item['id_kecamatan'].toString(),
                                child: Text(item['nama']),
                              );
                            }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedKecamatan = value;
                            _selectedDesa = null;
                            _desaList = [];
                          });
                          if (value != null) {
                            await _fetchDesa(value);
                          }
                        },
                        validator:
                            (value) => value == null ? 'Pilih kecamatan' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDesa == '' ? null : _selectedDesa,
                        decoration: const InputDecoration(
                          labelText: 'Desa',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _desaList.map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem<String>(
                                value: item['id_desa'].toString(),
                                child: Text(item['nama']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDesa = value;
                          });
                        },
                        validator:
                            (value) => value == null ? 'Pilih desa' : null,
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('Simpan'),
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}
