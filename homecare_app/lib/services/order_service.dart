import 'dart:convert';
import 'package:homecare_app/models/order_model.dart';
import 'package:http/http.dart' as http;
import '../models/order_response.dart';
import 'auth_service.dart';

class OrderService {
  static const String createOrderUrl =
      'https://ganeshahomecare.com/api_mobile/homecare_api/public/api/v1/private/order';
  static const String getOrdersUrl =
      'https://ganeshahomecare.com/api_mobile/homecare_api/public/api/v1/private/orders';

  static Future<OrderResponse?> createOrder({
    required int idLayanan,
    required String namaLayanan,
    required int jumlah,
    required double harga,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse(createOrderUrl);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_layanan': idLayanan,
          'nama_layanan': namaLayanan,
          'jumlah': jumlah,
          'harga': harga,
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic> && json.containsKey('data')) {
          return OrderResponse.fromJson(json);
        } else {
          print('⚠️ Format response tidak sesuai atau data kosong');
          return null;
        }
      } else {
        print('❌ Failed to create order: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      return null;
    }
  }

  static Future<List<OrderModel>> getAllOrders() async {
    final token = await AuthService.getToken();
    final uri = Uri.parse(getOrdersUrl); // ✅ Ubah ke URL GET yg benar

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        print('❌ Failed to get orders: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching orders: $e');
      return [];
    }
  }

  static Future<List<OrderModel>> getDetailOrder(int idInvoice) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse(
      'https://ganeshahomecare.com/api_mobile/homecare_api/public/api/v1/private/order/$idInvoice',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        print('❌ Failed to get detail order: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching detail order: $e');
      return [];
    }
  }

  static Future<bool> cancelOrder(int idInvoice) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse(
      'https://ganeshahomecare.com/api_mobile/homecare_api/public/api/v1/private/order/$idInvoice',
    );

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Pesanan berhasil dibatalkan');
        return true;
      } else {
        print('❌ Gagal membatalkan pesanan: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error cancelling order: $e');
      return false;
    }
  }
}
