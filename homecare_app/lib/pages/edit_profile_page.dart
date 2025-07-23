import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:homecare_app/services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  int? _selectedGender;
  bool _isLoading = false;

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      setState(() => _isLoading = true);
      SmartDialog.showLoading(msg: "Menyimpan...");

      final result = await UserService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        gender: _selectedGender,
      );

      SmartDialog.dismiss();
      setState(() => _isLoading = false);

      if (result['success']) {
        SmartDialog.show(
          alignment: Alignment.center,
          backDismiss: false,
          clickMaskDismiss: false,
          builder:
              (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text('Berhasil'),
                content: const Text('Profil berhasil diperbarui.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      SmartDialog.dismiss();
                      Navigator.pop(context, true); // kembali ke profile
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        final message = result['message'] ?? 'Gagal update profil';
        final errors = result['errors'] as Map<String, dynamic>?;

        String combinedErrors = message;
        if (errors != null && errors.isNotEmpty) {
          combinedErrors +=
              "\n" +
              errors.entries
                  .map((e) => "${e.key}: ${e.value.join(", ")}")
                  .join("\n");
        }

        SmartDialog.show(
          builder:
              (_) => AlertDialog(
                title: const Text("Gagal Menyimpan"),
                content: Text(combinedErrors),
                actions: [
                  TextButton(
                    onPressed: () => SmartDialog.dismiss(),
                    child: const Text("Tutup"),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Nama wajib diisi"
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email wajib diisi";
                  }
                  if (!value.contains('@')) {
                    return "Format email tidak valid";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Nomor Telepon"),
                validator:
                    (value) =>
                        value != null && value.length > 15
                            ? "Maksimal 15 karakter"
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Jenis Kelamin"),
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Laki-laki")),
                  DropdownMenuItem(value: 2, child: Text("Perempuan")),
                ],
                onChanged: (value) => setState(() => _selectedGender = value),
                validator:
                    (value) => value == null ? "Pilih jenis kelamin" : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
