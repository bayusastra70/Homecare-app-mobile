import 'package:flutter/material.dart';
import 'package:homecare_app/pages/login_page.dart';
import 'package:homecare_app/pages/edit_profile_page.dart';
import 'package:homecare_app/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:homecare_app/pages/edit_address_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<Map<String, dynamic>> _profile;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _profile = UserService.getProfile();
  }

  void _updateProfile() async {
    final updatedProfile = await UserService.getProfile();
    setState(() {
      _profile = Future.value(updatedProfile);
    });
  }

  void _logout(BuildContext context) async {
    await _storage.delete(key: 'access_token');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    ).then((_) {
      setState(() {
        _profile = UserService.getProfile();
      });
    });
  }

  void _navigateToEditAddress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditAddressPage()),
    ).then((_) {
      setState(() {
        _profile = UserService.getProfile();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!['data'] == null) {
          return const Center(child: Text('Gagal memuat data profil'));
        }

        final user = snapshot.data!['data']['user'];
        final address = snapshot.data!['data']['address'];
        const greenLogo = Color(0xFF2E7D32); // Hijau seperti logo

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: greenLogo,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user['name'] ?? '-',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user['email'] ?? '-',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _navigateToEditProfile(context),
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Profil"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenLogo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            elevation: 5,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                "Informasi Kontak",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone, color: greenLogo),
                  title: const Text("Nomor Telepon"),
                  subtitle: Text(
                    (user['phone'] != null &&
                            user['phone'].toString().trim().isNotEmpty)
                        ? user['phone']
                        : '-',
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.transgender, color: greenLogo),
                  title: const Text("Jenis Kelamin"),
                  subtitle: Text(
                    user['gender'] == 1
                        ? 'Laki-laki'
                        : user['gender'] == 2
                        ? 'Perempuan'
                        : '-',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Alamat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: greenLogo),
                  title: const Text("Alamat Lengkap"),
                  subtitle: Text(
                    address != null
                        ? '${address['alamat']}, ${address['desa']}, ${address['kecamatan']}, ${address['kabupaten']}'
                        : 'Belum ada alamat',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToEditAddress(context),
                    color: greenLogo,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
