import 'dart:convert';
import 'package:http/http.dart' as http;
import 'supabase_service.dart';

/// Service untuk transaksi / pesanan.
/// Catatan: token yang dikirim ke backend HARUS access token (JWT) dari session,
/// bukan user id — AuthGuard di backend memverifikasi via supabase.auth.getUser(token).
class OrderService {
  static const String baseUrl = 'http://localhost:4000/api';

  static String? get _token => auth.currentSession?.accessToken;

  /// Buat satu pesanan. [data] harus berisi field sesuai model Order backend:
  /// productId, productName, productImageUrl, farmerName, farmerId,
  /// quantity, unit, pricePerUnit, shippingCost, deliveryMethod, (estimatedDelivery?)
  static Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> data) async {
    final token = _token;
    if (token == null) throw Exception('User tidak terautentikasi');

    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Gagal membuat pesanan: ${response.body}');
  }

  /// Pesanan milik konsumen yang sedang login.
  static Future<List<dynamic>> getMyOrders() async {
    final token = _token;
    if (token == null) throw Exception('User tidak terautentikasi');

    final response = await http.get(
      Uri.parse('$baseUrl/orders/my'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Gagal memuat pesanan: ${response.body}');
  }

  /// Pesanan yang masuk untuk petani yang sedang login.
  static Future<List<dynamic>> getFarmerOrders() async {
    final token = _token;
    if (token == null) throw Exception('User tidak terautentikasi');

    final response = await http.get(
      Uri.parse('$baseUrl/orders/farmer'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Gagal memuat pesanan: ${response.body}');
  }

  /// Ubah status pesanan (hanya petani pemilik order).
  /// [status] = 'pending'|'confirmed'|'harvesting'|'shipped'|'completed'|'cancelled'.
  static Future<void> updateOrderStatus(String id, String status) async {
    final token = _token;
    if (token == null) throw Exception('User tidak terautentikasi');

    final response = await http.patch(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal ubah status: ${response.body}');
    }
  }
}
