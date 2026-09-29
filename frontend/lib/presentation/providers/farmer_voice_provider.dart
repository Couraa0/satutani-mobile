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
      // Configure flutter_tts as fallback
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);
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

    // Split by capital letter boundaries that indicate concatenated partial STT results
    // e.g. "BerapaBerapa hargaBerapa harga bawang..." -> ["Berapa", "Berapa harga", "Berapa harga bawang", ...]
    final segments = cleaned.split(RegExp(r'(?<=[a-zA-Z0-9])(?=[A-Z][a-z])'));

    if (segments.isNotEmpty) {
      // Pick the last segment which represents the most complete/final partial hypothesis
      String lastSegment = segments.last.trim();
      if (lastSegment.isNotEmpty) {
        cleaned = lastSegment;
      }
    }

    // Remove adjacent duplicate words e.g. "bawang bawang" -> "bawang"
    final words = cleaned.split(RegExp(r'\s+'));
    final List<String> deduplicatedWords = [];
    for (final w in words) {
      if (deduplicatedWords.isEmpty || deduplicatedWords.last.toLowerCase() != w.toLowerCase()) {
        deduplicatedWords.add(w);
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
        _speech.listen(
          listenOptions: stt.SpeechListenOptions(
            localeId: 'id_ID',
            cancelOnError: true,
            partialResults: true,
            listenMode: stt.ListenMode.confirmation,
          ),
          pauseFor: const Duration(seconds: 2),
          listenFor: const Duration(seconds: 15),
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
    Future.delayed(const Duration(seconds: 12), () {
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

    // Fallback: use device-native TTS (robotic but always available)
    _speakWithDeviceTts(cleanText);
  }

  /// Speak using device-native flutter_tts (fallback)
  void _speakWithDeviceTts(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
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
