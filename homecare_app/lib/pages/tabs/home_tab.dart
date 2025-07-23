import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Selamat datang di layanan Homecare!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            hintText: 'Cari layanan...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Kategori Populer",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCategoryTile(Icons.medical_services, "Dokter"),
            _buildCategoryTile(Icons.healing, "Perawat"),
            _buildCategoryTile(Icons.elderly, "Lansia"),
            _buildCategoryTile(Icons.baby_changing_station, "Bayi"),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTile(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 20),
      label: Text(label),
      backgroundColor: Colors.teal,
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
