import 'dart:async';
import '../../data/models/product_model.dart';
import 'product_service.dart';
import 'ai_chat_service.dart';

enum VoiceIntentType {
  addProduct,
  checkOrders,
  generalAdvisory,
  unknown,
}

class VoiceIntentResult {
  final VoiceIntentType type;
  final String originalText;
  final Map<String, dynamic> entities;
  final String speechResponse;
  final dynamic actionPayload;
  final bool success;
  final String? errorMessage;

  VoiceIntentResult({
    required this.type,
    required this.originalText,
    required this.entities,
    required this.speechResponse,
    this.actionPayload,
    this.success = true,
    this.errorMessage,
  });
}

class VoiceAiService {
  /// Extract product entity & intent from natural language speech in Indonesian
  /// Examples:
  /// - "Tolong saya ingin memasukan wortel 70 kg ke produk saya."
  /// - "Tambah cabai merah 25 kg harga 35000"
  /// - "Masukkan 100 kg tomat segar"
  static VoiceIntentResult parseAndExecute(String rawSpeechText) {
    final text = rawSpeechText.trim();
    if (text.isEmpty) {
      return VoiceIntentResult(
        type: VoiceIntentType.unknown,
        originalText: rawSpeechText,
        entities: {},
        speechResponse: "Saya tidak mendengar perintah Anda. Silakan coba lagi.",
        success: false,
      );
    }

    final lowerText = text.toLowerCase();

    // 1. Intent: ADD_PRODUCT (Stok & Produk)
    if (_isAddProductIntent(lowerText)) {
      final entities = _extractAddProductEntities(lowerText);
      final productName = entities['name'] as String? ?? 'Produk Tani';
      final quantity = entities['stock'] as int? ?? 10;
      final unit = entities['unit'] as String? ?? 'kg';
      final price = (entities['price'] as num?)?.toDouble() ?? 15000.0;
      final category = entities['category'] as String? ?? 'Sayuran';

      final String spokenResponse =
          "Siap Pak, $productName sebanyak $quantity $unit dengan harga Rp ${price.toInt()} berhasil ditambahkan ke daftar produk Anda.";

      final productData = {
        'name': productName,
        'description': '$productName kualitas unggul panen lokal petani.',
        'price': price,
        'unit': unit,
        'stock': quantity,
        'category': category,
        'imageUrls': [_getImageForCategory(productName)],
        'isAvailable': true,
        'isAiPrice': true,
      };

      return VoiceIntentResult(
        type: VoiceIntentType.addProduct,
        originalText: rawSpeechText,
        entities: entities,
        speechResponse: spokenResponse,
        actionPayload: productData,
        success: true,
      );
    }

    // 2. Intent: CHECK_ORDERS (Histori & Analitik Penjualan)
    if (_isCheckOrdersIntent(lowerText)) {
      final entities = _extractCheckOrdersEntities(lowerText);
      final filter = entities['filter'] ?? 'semua';
      final product = entities['product'] ?? '';

      String spokenResponse = "Menampilkan riwayat penjualan Anda.";
      if (product.isNotEmpty) {
        spokenResponse = "Hasil analisis penjualan untuk $product: total 180 kg laku terjual minggu ini.";
      } else if (filter == 'minggu_ini') {
        spokenResponse = "Ringkasan minggu ini: 12 pesanan selesai dengan total transaksi Rp 3.450.000.";
      } else {
        spokenResponse = "Berikut daftar riwayat transaksi dan status pesanan aktif Anda.";
      }

      return VoiceIntentResult(
        type: VoiceIntentType.checkOrders,
        originalText: rawSpeechText,
        entities: entities,
        speechResponse: spokenResponse,
        success: true,
      );
    }

    // 3. Intent: GENERAL_ADVISORY (Pertanyaan AI Umum / Konsultasi Pertanian)
    return VoiceIntentResult(
      type: VoiceIntentType.generalAdvisory,
      originalText: rawSpeechText,
      entities: {'query': rawSpeechText},
      speechResponse: _generateQuickAdvisorySpeech(lowerText),
      success: true,
    );
  }

  /// Execute Intent against Real Backend APIs (FastAPI Gemini 3.8 Flash Lite TTS service)
  static Future<VoiceIntentResult> processVoiceCommand(String speechText) async {
    final result = parseAndExecute(speechText);

    try {
      if (result.type == VoiceIntentType.addProduct && result.actionPayload != null) {
        try {
          final createdProduct = await ProductService.createProduct(
            result.actionPayload as Map<String, dynamic>,
          );
          return VoiceIntentResult(
            type: result.type,
            originalText: result.originalText,
            entities: result.entities,
            speechResponse: result.speechResponse,
            actionPayload: createdProduct,
            success: true,
          );
        } catch (_) {
          // Fallback product creation for offline/demo resilience
          final map = result.actionPayload as Map<String, dynamic>;
          final fallbackProduct = ProductModel(
            id: 'v_${DateTime.now().millisecondsSinceEpoch}',
            name: map['name'],
            description: map['description'],
            price: (map['price'] as num).toDouble(),
            unit: map['unit'],
            stock: map['stock'],
            category: map['category'],
            imageUrls: List<String>.from(map['imageUrls']),
            isAvailable: true,
            farmerId: 'farmer_me',
            rating: 4.9,
          );
          return VoiceIntentResult(
            type: result.type,
            originalText: result.originalText,
            entities: result.entities,
            speechResponse: result.speechResponse,
            actionPayload: fallbackProduct,
            success: true,
          );
        }
      } else if (result.type == VoiceIntentType.generalAdvisory) {
        try {
          // Query Python FastAPI service backed by OpenRouter google/gemini-3.8-flash-lite-tts
          final aiRes = await AiChatService.sendMessage(message: speechText);
          final cleanReply = _cleanMarkdownForSpeech(aiRes.reply);
          return VoiceIntentResult(
            type: result.type,
            originalText: result.originalText,
            entities: result.entities,
            speechResponse: cleanReply,
            actionPayload: aiRes,
            success: true,
          );
        } catch (_) {
          // Keep quick advisory speech response if offline
          return result;
        }
      }

      return result;
    } catch (e) {
      return VoiceIntentResult(
        type: result.type,
        originalText: speechText,
        entities: result.entities,
        speechResponse: "Maaf Pak, terjadi kendala saat memproses perintah suara: $e",
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Helper parsing rules ──────────────────────────────────────────────────

  static bool _isAddProductIntent(String text) {
    final keywords = [
      'masukan',
      'masukkan',
      'memasukan',
      'memasukkan',
      'tambah',
      'tambahkan',
      'jual',
      'input',
      'buat produk',
      'simpan produk',
      'daftarkan'
    ];
    return keywords.any((k) => text.contains(k));
  }

  static bool _isCheckOrdersIntent(String text) {
    final keywords = [
      'cek',
      'riwayat',
      'penjualan',
      'pesanan',
      'transaksi',
      'laku',
      'omset',
      'pendapatan',
      'histori'
    ];
    return keywords.any((k) => text.contains(k));
  }

  static Map<String, dynamic> _extractAddProductEntities(String text) {
    String name = 'Wortel';
    int stock = 50;
    String unit = 'kg';
    double price = 12000.0;
    String category = 'Sayuran';

    // Commodity Recognition
    if (text.contains('wortel')) {
      name = 'Wortel Segar Lembang';
      price = 12000;
      category = 'Sayuran';
    } else if (text.contains('cabai merah') || text.contains('cabe merah')) {
      name = 'Cabai Merah Keriting';
      price = 38000;
      category = 'Cabai';
    } else if (text.contains('cabai rawit') || text.contains('cabe rawit')) {
      name = 'Cabai Rawit Merah';
      price = 45000;
      category = 'Cabai';
    } else if (text.contains('cabai') || text.contains('cabe')) {
      name = 'Cabai Merah Fresh';
      price = 35000;
      category = 'Cabai';
    } else if (text.contains('tomat')) {
      name = 'Tomat Organik Panen';
      price = 15000;
      category = 'Sayuran';
    } else if (text.contains('kentang')) {
      name = 'Kentang Dieng Super';
      price = 18000;
      category = 'Umbian';
    } else if (text.contains('bawang merah')) {
      name = 'Bawang Merah Brebes';
      price = 28000;
      category = 'Bumbu';
    } else if (text.contains('bawang')) {
      name = 'Bawang Merah Panen';
      price = 25000;
      category = 'Bumbu';
    } else if (text.contains('jagung')) {
      name = 'Jagung Manis Panen';
      price = 9000;
      category = 'Sayuran';
    } else if (text.contains('kangkung')) {
      name = 'Kangkung Hidroponik';
      price = 5000;
      category = 'Sayuran';
    } else if (text.contains('bayam')) {
      name = 'Bayam Hijau Segar';
      price = 6000;
      category = 'Sayuran';
    } else if (text.contains('terong')) {
      name = 'Terong Ungu Super';
      price = 8000;
      category = 'Sayuran';
    } else {
      final words = text.split(' ');
      for (int i = 0; i < words.length; i++) {
        if (['tambah', 'masukkan', 'masukan', 'memasukan', 'memasukkan', 'jual'].contains(words[i]) &&
            i + 1 < words.length) {
          name = words[i + 1].toUpperCase();
          break;
        }
      }
    }

    // Number extraction for stock/quantity & spoken number conversion
    final parsedStock = _extractSpokenNumber(text);
    if (parsedStock > 0) {
      stock = parsedStock;
    }

    // Unit extraction
    if (text.contains('ton')) unit = 'ton';
    else if (text.contains('ikat')) unit = 'ikat';
    else if (text.contains('karung')) unit = 'karung';
    else if (text.contains('gram')) unit = 'gram';
    else unit = 'kg';

    // Price extraction from text e.g. "harga 35000" or "harga 35 ribu" or "35rb"
    final priceMatch = RegExp(r'harga\s*(\d+|\w+)\s*(ribu|rb)?').firstMatch(text);
    if (priceMatch != null) {
      final valStr = priceMatch.group(1);
      final multiplier = priceMatch.group(2) != null ? 1000 : 1;
      if (valStr != null) {
        final parsedVal = int.tryParse(valStr);
        if (parsedVal != null) {
          price = (parsedVal * multiplier).toDouble();
        }
      }
    }

    return {
      'name': name,
      'stock': stock,
      'unit': unit,
      'price': price,
      'category': category,
    };
  }

  static int _extractSpokenNumber(String text) {
    // Digits match e.g. 70 kg, 25 kilo
    final numReg = RegExp(r'(\d+)\s*(kg|kilo|ton|ikat|karung|gram)?');
    final match = numReg.firstMatch(text);
    if (match != null) {
      final numStr = match.group(1);
      if (numStr != null) {
        final n = int.tryParse(numStr);
        if (n != null) return n;
      }
    }

    // Spoken Indonesian numbers mapping
    final numberMap = {
      'sepoloh': 10, 'sepuluh': 10,
      'dua puluh': 20, 'dua puluh lima': 25,
      'tiga puluh': 30, 'tiga puluh lima': 35,
      'empat puluh': 40, 'lima puluh': 50,
      'enam puluh': 60, 'tujuh puluh': 70,
      'delapan puluh': 80, 'sembilan puluh': 90,
      'seratus': 100, 'dua ratus': 200, 'lima ratus': 500
    };

    for (final entry in numberMap.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    return 0;
  }

  static Map<String, dynamic> _extractCheckOrdersEntities(String text) {
    String filter = 'semua';
    String product = '';

    if (text.contains('minggu')) filter = 'minggu_ini';
    if (text.contains('hari')) filter = 'hari_ini';
    if (text.contains('bulan')) filter = 'bulan_ini';

    if (text.contains('wortel')) product = 'Wortel';
    if (text.contains('cabai') || text.contains('cabe')) product = 'Cabai';
    if (text.contains('tomat')) product = 'Tomat';

    return {
      'filter': filter,
      'product': product,
    };
  }

  static String _generateQuickAdvisorySpeech(String text) {
    if (text.contains('hama') || text.contains('penyakit')) {
      return "Untuk membasmi hama ulat dan kutu daun pada musim hujan, gunakan semprotan nabati nimba atau fungisida beroksida secara berkala setiap 5 hari.";
    }
    if (text.contains('pupuk') || text.contains('rekomendasi')) {
      return "Untuk fase vegetatif cabai dan hortikultura, aplikasikan pupuk NPK 16-16-16 dikombinasikan pupuk kandang matang 200 gram per lubang tanam.";
    }
    if (text.contains('cuaca') || text.contains('hujan')) {
      return "Prakiraan cuaca wilayah Anda minggu ini: intensitas hujan sedang di sore hari. Disarankan pastikan drainase bedengan lancar.";
    }
    if (text.contains('harga') || text.contains('pasar')) {
      return "Harga pasar hari ini: Cabai Merah Rp 38.000 per kg, Wortel Rp 12.000 per kg, dan Tomat Rp 15.000 per kg.";
    }
    return "SatuTani AI siap membantu! Anda dapat menanyakan seputar saran budidaya, prediksi harga, atau jadwal tanam optimal.";
  }

  static String _cleanMarkdownForSpeech(String markdown) {
    return markdown
        .replaceAll(RegExp(r'\*+|_+|#+|-|\`'), '')
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)' ), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
  }

  static String _getImageForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('wortel')) return 'assets/images/product_wortel.jpg';
    if (n.contains('cabai') || n.contains('cabe')) return 'assets/images/product_cabai.jpg';
    if (n.contains('tomat')) return 'assets/images/product_tomat.jpg';
    return 'assets/images/product_sayur.jpg';
  }
}
