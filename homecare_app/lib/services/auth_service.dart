import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final baseUrl =
      'https://ganeshahomecare.com/api_mobile/homecare_api/public/api/v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel?> login(String email, String password) async {
    try {
      print('Login request: $email / $password');

      final response = await http.post(
        Uri.parse('$baseUrl/public/auth/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      return _handleAuthResponse(response);
    } catch (e, stacktrace) {
      print('Login error: $e');
      print(stacktrace);
      rethrow;
    }
  }

  Future<UserModel?> register(
    String name,
    String email,
    String password,
    String confirmPassword,
    int gender,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/public/auth/register'),
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
          'gender': gender.toString(),
        },
      );

      return await _handleRegisterResponse(response);
    } catch (e, stacktrace) {
      print('Register error: $e');
      print(stacktrace);
      rethrow;
    }
  }

  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        throw Exception('Refresh token tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/public/auth/refresh-token'),
        headers: {'Accept': 'application/json'},
        body: {'refresh_token': refreshToken},
      );

      return _handleRefreshTokenResponse(response);
    } catch (e, stacktrace) {
      print('Refresh token error: $e');
      print(stacktrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/public/auth/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Logout gagal');
      }
    } catch (e, stacktrace) {
      print('Logout error: $e');
      print(stacktrace);
      rethrow;
    }
  }

  Future<UserModel?> _handleAuthResponse(http.Response response) async {
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['data'] != null && data['data']['access_token'] != null) {
        await _storage.write(
          key: 'access_token',
          value: data['data']['access_token']['token'],
        );
        await _storage.write(
          key: 'refresh_token',
          value: data['data']['refresh_token']['token'],
        );
        return UserModel.fromJson(data['data']);
      } else {}
    } else {}
  }

  Future<String?> _handleRefreshTokenResponse(http.Response response) async {
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['data']['access_token']['token'];
    } else {
      throw Exception(data['message'] ?? 'Refresh token gagal');
    }
  }

  Future<UserModel?> _handleRegisterResponse(http.Response response) async {
    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return UserModel.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
  }

  static Future<String?> getToken() async {
    final FlutterSecureStorage _storage = FlutterSecureStorage();
    return await _storage.read(key: 'access_token');
  }
}
