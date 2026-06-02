import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class AiChatService {
  static const String _baseUrl = 'http://localhost:4000/api';

  /// Kirim pesan ke SatuTani AI agent.
  /// Hanya bisa dipanggil oleh user dengan role petani.
  static Future<AiChatResponse> sendMessage({
    required String message,
    String wilayah = 'Lembang',
  }) async {
    final token = AuthService.accessToken;
    if (token == null) throw Exception('User tidak terautentikasi');

    final uri = Uri.parse('$_baseUrl/ai/chat');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': message,
        'wilayah': wilayah,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AiChatResponse.fromJson(data);
    } else if (response.statusCode == 403) {
      throw Exception('Akses ditolak: fitur ini hanya untuk petani.');
    } else if (response.statusCode == 503) {
      throw Exception('Layanan AI sedang tidak aktif. Coba beberapa saat lagi.');
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Gagal menghubungi AI: ${response.statusCode}');
    }
  }

  /// Cek status AI service.
  static Future<bool> isAiServiceOnline() async {
    try {
      final uri = Uri.parse('$_baseUrl/ai/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Ambil daftar wilayah yang didukung AI.
  static Future<List<String>> getWilayah() async {
    try {
      final uri = Uri.parse('$_baseUrl/ai/wilayah');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['wilayah'] ?? []);
      }
      return defaultWilayah;
    } catch (_) {
      return defaultWilayah;
    }
  }

  static const List<String> defaultWilayah = [
    'Lembang',
    'Bandung Kota',
    'Bekasi',
    'Tasikmalaya',
    'Cianjur',
    'Sukabumi',
  ];
}

class AiChatResponse {
  final String reply;
  final String wilayah;
  final List<String> toolsUsed;

  const AiChatResponse({
    required this.reply,
    required this.wilayah,
    this.toolsUsed = const [],
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      reply: json['reply'] as String? ?? '',
      wilayah: json['wilayah'] as String? ?? '',
      toolsUsed: List<String>.from(json['tools_used'] ?? []),
    );
  }
}
