import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UserService {
  static const String _baseUrl =
      'https://ganeshahomecare.com/api_mobile/homecare_api/public/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    int? gender,
  }) async {
    try {
      final token = await _storage.read(key: 'access_token');

      final url = Uri.parse('$_baseUrl/private/user/profile/edit');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e.toString(), 'update profil');
    }
  }

  static Future<Map<String, dynamic>> updateAddress({
    required String alamat,
    required String desa,
    required String kecamatan,
    required String kabupaten,
  }) async {
    try {
      final token = await _storage.read(key: 'access_token');

      final url = Uri.parse('$_baseUrl/private/user/profile/address');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'alamat': alamat,
          'id_desa': desa,
          'id_kecamatan': kecamatan,
          'id_kabupaten': kabupaten,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e.toString(), 'update alamat');
    }
  }

  /// 🌍 Ambil daftar kabupaten
  static Future<Map<String, dynamic>> fetchKabupaten() async {
    try {
      final url = Uri.parse('$_baseUrl/public/kabupaten');
      final response = await http.get(url);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e.toString(), 'mengambil kabupaten');
    }
  }

  /// 🌍 Ambil daftar kecamatan berdasarkan kabupaten
  static Future<Map<String, dynamic>> fetchKecamatan(String kabupatenId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/public/kabupaten/$kabupatenId/kecamatan',
      );
      final response = await http.get(url);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e.toString(), 'mengambil kecamatan');
    }
  }

  /// 🌍 Ambil daftar desa berdasarkan kecamatan
  static Future<Map<String, dynamic>> fetchDesa(String kecamatanId) async {
    try {
      final url = Uri.parse('$_baseUrl/public/kecamatan/$kecamatanId/desa');
      final response = await http.get(url);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e.toString(), 'mengambil desa');
    }
  }

  /// 🔐 Ambil profil lengkap pengguna
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final url = Uri.parse('$_baseUrl/private/user/profile');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e.toString(), 'mengambil profil');
    }
  }

  /// ✅ Menangani respons umum
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Terjadi kesalahan',
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memproses respons dari server',
      };
    }
  }

  static Map<String, dynamic> _handleError(String error, String action) {
    return {
      'success': false,
      'message': 'Terjadi kesalahan saat $action: $error',
    };
  }
}
