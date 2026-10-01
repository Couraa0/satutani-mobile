import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/services/voice_ai_service.dart';
import '../../core/services/elevenlabs_tts_service.dart';
import '../../core/services/product_service.dart';
import '../../core/services/order_service.dart';
import '../../data/models/product_model.dart';
import '../../data/models/farmer_order.dart';

enum VoiceState { idle, listening, processing, speaking, error }

class FarmerVoiceState {
  final VoiceState voiceState;
  final String recognizedText;
  final String speechResponse;
  final VoiceIntentResult? lastIntentResult;
  final List<ProductModel> products;
  final List<FarmerOrder> orders;
  final bool isLoadingData;
  final String? activeCategoryFilter;
  final String? notificationMessage;

  FarmerVoiceState({
    this.voiceState = VoiceState.idle,
    this.recognizedText = '',
    this.speechResponse = '',
    this.lastIntentResult,
    this.products = const [],
    this.orders = const [],
    this.isLoadingData = false,
    this.activeCategoryFilter,
    this.notificationMessage,
  });

  FarmerVoiceState copyWith({
    VoiceState? voiceState,
    String? recognizedText,
    String? speechResponse,
    VoiceIntentResult? lastIntentResult,
    List<ProductModel>? products,
    List<FarmerOrder>? orders,
    bool? isLoadingData,
    String? activeCategoryFilter,
    String? notificationMessage,
  }) {
    return FarmerVoiceState(
      voiceState: voiceState ?? this.voiceState,
      recognizedText: recognizedText ?? this.recognizedText,
      speechResponse: speechResponse ?? this.speechResponse,
      lastIntentResult: lastIntentResult ?? this.lastIntentResult,
      products: products ?? this.products,
      orders: orders ?? this.orders,
      isLoadingData: isLoadingData ?? this.isLoadingData,
      activeCategoryFilter: activeCategoryFilter ?? this.activeCategoryFilter,
      notificationMessage: notificationMessage ?? this.notificationMessage,
    );
  }
}

class FarmerVoiceNotifier extends StateNotifier<FarmerVoiceState> {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isProcessingCommand = false;

  FarmerVoiceNotifier() : super(FarmerVoiceState()) {
    _initAudioServices();
    loadDashboardData();
  }

  void _initAudioServices() async {
    try {
      // Configure flutter_tts with Indonesian language & natural cadence
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      // Pick Indonesian voice if available
      try {
        final dynamic voices = await _flutterTts.getVoices;
        if (voices is List) {
          for (final v in voices) {
            if (v is Map && (v['locale']?.toString().toLowerCase().contains('id') ?? false)) {
              await _flutterTts.setVoice({
                "name": v["name"].toString(),
                "locale": v["locale"].toString()
              });
              break;
            }
          }
        }
      } catch (_) {}

      _flutterTts.setCompletionHandler(() {
        _isProcessingCommand = false;
        if (mounted && state.voiceState == VoiceState.speaking) {
          state = state.copyWith(voiceState: VoiceState.idle);
        }
      });

      // Listen for ElevenLabs audio player completion
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _isProcessingCommand = false;
          if (mounted && state.voiceState == VoiceState.speaking) {
            state = state.copyWith(voiceState: VoiceState.idle);
          }
        }
      });
    } catch (_) {}
  }

  /// Clean & deduplicate speech text to prevent concatenated/doubled partial STT outputs
  static String deduplicateSpeechText(String text) {
    if (text.isEmpty) return text;
    String cleaned = text.trim();

    // 1. Mobile Web STT accumulator fix:
    // Web Speech API on mobile often appends streaming hypotheses without clearing prior interim chunks
    // e.g. "masukkanmasukkanmasukkan wortelmasukkan wortel sebanyak...masukkan wortel sebanyak 70 kilo"
    final firstWordMatch = RegExp(r'^[a-zA-Z0-9]+').firstMatch(cleaned);
    if (firstWordMatch != null && firstWordMatch.group(0)!.length >= 2) {
      final firstWord = firstWordMatch.group(0)!;
      final matches = RegExp(RegExp.escape(firstWord), caseSensitive: false)
          .allMatches(cleaned)
          .toList();

      if (matches.length > 1) {
        // The last occurrence of the sentence-starting token marks the final and most complete hypothesis
        final lastStart = matches.last.start;
        final candidate = cleaned.substring(lastStart).trim();
        if (candidate.isNotEmpty) {
          cleaned = candidate;
        }
      }
    }

    // 2. Split by capital letter boundaries that indicate concatenated partial STT results
    // e.g. "BerapaBerapa hargaBerapa harga bawang..." -> ["Berapa", "Berapa harga", "Berapa harga bawang", ...]
    final segments = cleaned.split(RegExp(r'(?<=[a-zA-Z0-9])(?=[A-Z][a-z])'));

    if (segments.isNotEmpty) {
      // Pick the last segment which represents the most complete/final partial hypothesis
      String lastSegment = segments.last.trim();
      if (lastSegment.isNotEmpty) {
        cleaned = lastSegment;
      }
    }

    // 3. Remove adjacent duplicate words e.g. "bawang bawang" -> "bawang"
    final words = cleaned.split(RegExp(r'\s+'));
    final List<String> deduplicatedWords = [];
    for (final w in words) {
      if (w.trim().isEmpty) continue;
      if (deduplicatedWords.isEmpty || deduplicatedWords.last.toLowerCase() != w.toLowerCase()) {
        deduplicatedWords.add(w.trim());
      }
    }

    return deduplicatedWords.join(' ');
  }

  /// Load initial dashboard data (products & orders)
  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoadingData: true);
    try {
      final results = await Future.wait([
        ProductService.getFarmerProducts().catchError((_) => <ProductModel>[]),
        OrderService.getFarmerOrders()
            .then(FarmerOrder.listFromJson)
            .catchError((_) => <FarmerOrder>[]),
      ]);

      List<ProductModel> fetchedProducts = results[0] as List<ProductModel>;
      List<FarmerOrder> fetchedOrders = results[1] as List<FarmerOrder>;

      if (fetchedProducts.isEmpty) {
        fetchedProducts = _defaultDemoProducts();
      }

      state = state.copyWith(
        products: fetchedProducts,
        orders: fetchedOrders,
        isLoadingData: false,
      );
    } catch (_) {
      state = state.copyWith(
        products: _defaultDemoProducts(),
        isLoadingData: false,
      );
    }
  }

  /// Start Listening to Voice Input from Microphone (STT)
  void startListening() async {
    _isProcessingCommand = false;
    state = state.copyWith(
      voiceState: VoiceState.listening,
      recognizedText: 'Mendengarkan suara Anda...',
      speechResponse: '',
      notificationMessage: null,
    );

    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (!_isProcessingCommand &&
              (status == 'done' || status == 'notListening') &&
              state.voiceState == VoiceState.listening &&
              state.recognizedText.isNotEmpty &&
              state.recognizedText != 'Mendengarkan suara Anda...') {
            processSpeech(state.recognizedText);
          }
        },
        onError: (_) {},
      );

      if (available) {
        // Dynamically find supported Indonesian locale for mobile/web compatibility
        String targetLocale = 'id-ID';
        try {
          final locales = await _speech.locales();
          for (final loc in locales) {
            final idLower = loc.localeId.toLowerCase();
            final nameLower = loc.name.toLowerCase();
            if (idLower.startsWith('id') ||
                idLower.startsWith('in') ||
                nameLower.contains('indonesia')) {
              targetLocale = loc.localeId;
              break;
            }
          }
        } catch (_) {
          targetLocale = 'id-ID';
        }

        _speech.listen(
          localeId: targetLocale,
          listenOptions: stt.SpeechListenOptions(
            localeId: targetLocale,
            cancelOnError: false,
            partialResults: true,
            listenMode: stt.ListenMode.confirmation,
          ),
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 25),
          onResult: (result) {
            if (result.recognizedWords.isNotEmpty) {
              final cleaned = deduplicateSpeechText(result.recognizedWords);
              if (cleaned.isNotEmpty) {
                state = state.copyWith(recognizedText: cleaned);
              }
            }
          },
        );
      }
    } catch (_) {
      // Fallback mode if mic permission is pending or in web simulator
    }
  }

  /// Process Voice Command & Speak Response Out Loud (TTS Audio Feedback)
  Future<void> processSpeech(String rawSpeech) async {
    if (_isProcessingCommand) return;
    _isProcessingCommand = true;

    final cleanedSpeech = deduplicateSpeechText(rawSpeech);

    state = state.copyWith(
      voiceState: VoiceState.processing,
      recognizedText: cleanedSpeech,
      speechResponse: 'Menganalisis maksud perintah...',
    );

    try {
      await _speech.stop();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 300));

    final result = await VoiceAiService.processVoiceCommand(cleanedSpeech);

    List<ProductModel> updatedProducts = List.from(state.products);
    List<FarmerOrder> updatedOrders = List.from(state.orders);

    if (result.type == VoiceIntentType.addProduct && result.actionPayload is ProductModel) {
      final newProd = result.actionPayload as ProductModel;
      updatedProducts.insert(0, newProd);
    }

    state = state.copyWith(
      voiceState: VoiceState.speaking,
      speechResponse: result.speechResponse,
      lastIntentResult: result,
      products: updatedProducts,
      orders: updatedOrders,
      notificationMessage: result.success ? "✅ Aksi Suara Berhasil Dieksekusi" : "❌ Gagal Mengeksekusi Aksi",
    );

    // Speak audio voice response — try ElevenLabs first, fallback to device TTS
    await _speakWithElevenLabsOrFallback(result.speechResponse);

    // Fallback transition back to idle after speech completes
    Future.delayed(const Duration(seconds: 14), () {
      if (mounted && state.voiceState == VoiceState.speaking) {
        _isProcessingCommand = false;
        state = state.copyWith(voiceState: VoiceState.idle);
      }
    });
  }

  /// Try ElevenLabs TTS first for natural voice; fall back to flutter_tts if unavailable
  Future<void> _speakWithElevenLabsOrFallback(String responseText) async {
    final cleanText = _stripMarkdown(responseText);
    if (cleanText.isEmpty) return;

    try {
      // Attempt ElevenLabs high-quality TTS via backend proxy
      final Uint8List? audioBytes = await ElevenLabsTtsService.synthesize(cleanText);

      if (audioBytes != null && audioBytes.isNotEmpty) {
        // Play the MP3 audio from ElevenLabs
        await _audioPlayer.stop();
        final audioSource = _InMemoryAudioSource(audioBytes);
        await _audioPlayer.setAudioSource(audioSource);
        await _audioPlayer.play();
        return; // Success — no need for fallback
      }
    } catch (_) {
      // ElevenLabs failed — fall through to device TTS
    }

    // Fallback: use device-native TTS with natural Indonesian phonetic normalization
    _speakWithDeviceTts(cleanText);
  }

  /// Speak using device-native flutter_tts (fallback with natural phonetic Indonesian)
  void _speakWithDeviceTts(String text) async {
    try {
      await _flutterTts.stop();
      final phoneticIndonesian = formatForIndonesianSpeech(text);
      await _flutterTts.speak(phoneticIndonesian);
    } catch (_) {}
  }

  /// Strip markdown symbols for clean speech synthesis
  static String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*+|_+|#+|-|`'), '')
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
  }

  /// Natural Indonesian Phonetic and Number Converter for Smooth Voice Reading
  static String formatForIndonesianSpeech(String raw) {
    String text = _stripMarkdown(raw);

    // Convert Currency (e.g. Rp 35.000, Rp 3.450.000) into Indonesian spoken words
    text = text.replaceAllMapped(RegExp(r'Rp\s*([\d\.]+)'), (match) {
      final numStr = match.group(1)?.replaceAll('.', '') ?? '0';
      final n = int.tryParse(numStr);
      if (n != null) {
        return '${numberToIndonesianWords(n)} rupiah';
      }
      return match.group(0) ?? '';
    });

    // Convert dates (e.g. 25/10/2026)
    text = text.replaceAllMapped(RegExp(r'\b(\d{1,2})\/(\d{1,2})\/(\d{4})\b'), (match) {
      final day = int.tryParse(match.group(1) ?? '1') ?? 1;
      final month = int.tryParse(match.group(2) ?? '1') ?? 1;
      final year = int.tryParse(match.group(3) ?? '2026') ?? 2026;
      final monthNames = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthStr = (month >= 1 && month <= 12) ? monthNames[month] : 'bulan $month';
      return 'tanggal ${numberToIndonesianWords(day)} $monthStr tahun ${numberToIndonesianWords(year)}';
    });

    // Convert decimal numbers (e.g. 0.5 hektar -> setengah hektar)
    text = text.replaceAll('0.5 hektar', 'setengah hektar');
    text = text.replaceAll('0,5 hektar', 'setengah hektar');
    text = text.replaceAllMapped(RegExp(r'\b(\d+)[.,](\d+)\b'), (match) {
      final whole = int.tryParse(match.group(1) ?? '0') ?? 0;
      final dec = match.group(2) ?? '0';
      return '${numberToIndonesianWords(whole)} koma $dec';
    });

    // Convert common agricultural terms for phonetics
    text = text.replaceAll('/kg', ' per kilogram');
    text = text.replaceAll('/ha', ' per hektar');
    text = text.replaceAll('°C', ' derajat Celsius');
    text = text.replaceAll('%', ' persen');
    text = text.replaceAll('kg', ' kilogram');
    text = text.replaceAll('mm/minggu', ' milimeter per minggu');
    text = text.replaceAll('±', 'kurang lebih ');
    text = text.replaceAll('~', 'sekitar ');

    // Normalize spacing
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  /// Indonesian Number-to-Words ('Terbilang') Engine
  static String numberToIndonesianWords(int n) {
    if (n == 0) return 'nol';
    if (n < 0) return 'minus ${numberToIndonesianWords(-n)}';

    final units = [
      '', 'satu', 'dua', 'tiga', 'empat', 'lima',
      'enam', 'tujuh', 'delapan', 'sembilan', 'sepuluh', 'sebelas'
    ];

    if (n < 12) return units[n];
    if (n < 20) return '${units[n - 10]} belas';
    if (n < 100) {
      final div = n ~/ 10;
      final rem = n % 10;
      return '${units[div]} puluh${rem > 0 ? ' ${units[rem]}' : ''}';
    }
    if (n < 200) {
      final rem = n - 100;
      return 'seratus${rem > 0 ? ' ${numberToIndonesianWords(rem)}' : ''}';
    }
    if (n < 1000) {
      final div = n ~/ 100;
      final rem = n % 100;
      return '${units[div]} ratus${rem > 0 ? ' ${numberToIndonesianWords(rem)}' : ''}';
    }
    if (n < 2000) {
      final rem = n - 1000;
      return 'seribu${rem > 0 ? ' ${numberToIndonesianWords(rem)}' : ''}';
    }
    if (n < 1000000) {
      final div = n ~/ 1000;
      final rem = n % 1000;
      return '${numberToIndonesianWords(div)} ribu${rem > 0 ? ' ${numberToIndonesianWords(rem)}' : ''}';
    }
    if (n < 1000000000) {
      final div = n ~/ 1000000;
      final rem = n % 1000000;
      return '${numberToIndonesianWords(div)} juta${rem > 0 ? ' ${numberToIndonesianWords(rem)}' : ''}';
    }
    final div = n ~/ 1000000000;
    final rem = n % 1000000000;
    return '${numberToIndonesianWords(div)} miliar${rem > 0 ? ' ${numberToIndonesianWords(rem)}' : ''}';
  }

  /// Stop listening & speech synthesis
  void stopListening() {
    _isProcessingCommand = false;
    try {
      _speech.stop();
      _flutterTts.stop();
      _audioPlayer.stop();
    } catch (_) {}
    state = state.copyWith(voiceState: VoiceState.idle);
  }

  static List<ProductModel> _defaultDemoProducts() {
    return const [
      ProductModel(
        id: 'demo_1',
        name: 'Wortel Organik Lembang',
        description: 'Wortel manis segar panen langsung',
        price: 12000,
        unit: 'kg',
        stock: 80,
        category: 'Sayuran',
        imageUrls: ['assets/images/product_wortel.jpg'],
        isAvailable: true,
        rating: 4.8,
      ),
      ProductModel(
        id: 'demo_2',
        name: 'Cabai Merah Keriting',
        description: 'Cabai pedas segar kualitas super',
        price: 38000,
        unit: 'kg',
        stock: 45,
        category: 'Cabai',
        imageUrls: ['assets/images/product_cabai.jpg'],
        isAvailable: true,
        rating: 4.9,
      ),
      ProductModel(
        id: 'demo_3',
        name: 'Tomat Merah Fresh',
        description: 'Tomat segar buah besar',
        price: 15000,
        unit: 'kg',
        stock: 30,
        category: 'Sayuran',
        imageUrls: ['assets/images/product_tomat.jpg'],
        isAvailable: true,
        rating: 4.7,
      ),
    ];
  }

  @override
  void dispose() {
    _isProcessingCommand = false;
    try {
      _speech.stop();
      _flutterTts.stop();
      _audioPlayer.dispose();
    } catch (_) {}
    super.dispose();
  }
}

/// Custom AudioSource that plays audio from in-memory bytes (for ElevenLabs MP3 response)
class _InMemoryAudioSource extends StreamAudioSource {
  final Uint8List _audioBytes;

  _InMemoryAudioSource(this._audioBytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final effectiveStart = start ?? 0;
    final effectiveEnd = end ?? _audioBytes.length;
    return StreamAudioResponse(
      sourceLength: _audioBytes.length,
      contentLength: effectiveEnd - effectiveStart,
      offset: effectiveStart,
      stream: Stream.value(
        _audioBytes.sublist(effectiveStart, effectiveEnd),
      ),
      contentType: 'audio/mpeg',
    );
  }
}

final farmerVoiceProvider =
    StateNotifierProvider<FarmerVoiceNotifier, FarmerVoiceState>((ref) {
  return FarmerVoiceNotifier();
});
