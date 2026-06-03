import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/product_model.dart';
import 'auth_service.dart';

class ProductService {
  static const String baseUrl =
      'http://localhost:4000/api'; // Sesuaikan dengan base URL backend Anda

  /// Dapatkan semua produk dengan filter dan pagination
  static Future<List<ProductModel>> getAllProducts({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (category != null && category.isNotEmpty) {
        params['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      final uri =
          Uri.parse('$baseUrl/products').replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat produk: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Dapatkan produk berdasarkan ID
  static Future<ProductModel> getProductById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Produk tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Dapatkan semua produk milik farmer yang login
  static Future<List<ProductModel>> getFarmerProducts() async {
    try {
      final token = AuthService.accessToken;
      if (token == null) throw Exception('User tidak terautentikasi');

      final uri = Uri.parse('$baseUrl/products/farmer/me');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat produk: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Buat produk baru
  static Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) throw Exception('User tidak terautentikasi');

      final uri = Uri.parse('$baseUrl/products');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ProductModel.fromJson(responseData);
      } else {
        throw Exception('Gagal membuat produk: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Update produk
  static Future<ProductModel> updateProduct(
      String id, Map<String, dynamic> data) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) throw Exception('User tidak terautentikasi');

      final uri = Uri.parse('$baseUrl/products/$id');
      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ProductModel.fromJson(responseData);
      } else {
        throw Exception('Gagal update produk: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Hapus produk
  static Future<void> deleteProduct(String id) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) throw Exception('User tidak terautentikasi');

      final uri = Uri.parse('$baseUrl/products/$id');
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal hapus produk: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Duplicate produk (copy dari produk existing)
  static Future<ProductModel> duplicateProduct(String sourceProductId) async {
    try {
      // Ambil produk original
      final original = await getProductById(sourceProductId);

      // Buat copy dengan nama yang berbeda
      final newData = {
        'name': '${original.name} (Copy)',
        'description': original.description,
        'price': original.price,
        'unit': original.unit,
        'stock': original.stock,
        'category': original.category,
        'imageUrls': original.imageUrls,
        'isAvailable': original.isAvailable,
        'isAiPrice': original.isAiPrice,
        'isPreOrder': original.isPreOrder,
        'estimatedHarvestDate':
            original.estimatedHarvestDate?.toIso8601String(),
        'preOrderTarget': original.preOrderTarget,
      };

      return await createProduct(newData);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
