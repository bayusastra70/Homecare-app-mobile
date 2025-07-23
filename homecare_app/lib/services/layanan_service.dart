import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/layanan_model.dart';

class LayananService {
  final String baseUrl =
      'https://ganeshahomecare.com/api_mobile/homecare_api/public/api/v1';

  Future<List<Layanan>> getAllLayanan() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public/layanan'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> layananJson = data['data'];
        return layananJson.map((json) => Layanan.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data layanan');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Gagal memuat data layanan');
    }
  }

  Future<Layanan> getLayananById(int id) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/v1/public/layanan/$id'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Layanan.fromJson(data['data']);
    } else {
      throw Exception('Gagal memuat detail layanan');
    }
  }
}
