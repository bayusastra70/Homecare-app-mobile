import 'package:flutter/material.dart';
import 'package:homecare_app/services/auth_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  int _gender = 1;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = AuthService();

    try {
      final response = await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _confirmPasswordController.text.trim(),
        _gender,
      );

      setState(() => _isLoading = false);

      if (response != null) {
        SmartDialog.show(
          alignment: Alignment.center,
          backDismiss: false,
          clickMaskDismiss: false,
          builder:
              (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Registrasi Berhasil',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'Akun Anda berhasil dibuat.\nSilakan login.',
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.center, // Tombol di tengah
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      SmartDialog.dismiss();
                      Navigator.pop(context); // kembali ke halaman login
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        );
      } else {
        setState(() {
          _errorMessage = 'Pendaftaran gagal';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Daftar untuk GaneshaHomecare',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  const emailPattern =
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                  final regExp = RegExp(emailPattern);
                  if (!regExp.hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Password tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender Selection
              Row(
                children: [
                  const Text('Gender:'),
                  Radio<int>(
                    value: 1,
                    groupValue: _gender,
                    onChanged: (int? value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const Text('Laki-laki'),
                  Radio<int>(
                    value: 2,
                    groupValue: _gender,
                    onChanged: (int? value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const Text('Perempuan'),
                ],
              ),

              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 8),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
