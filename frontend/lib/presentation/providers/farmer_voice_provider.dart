import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/services/voice_ai_service.dart';
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

  FarmerVoiceNotifier() : super(FarmerVoiceState()) {
    _initAudioServices();
    loadDashboardData();
  }

  void _initAudioServices() async {
    try {
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
    } catch (_) {}
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
    state = state.copyWith(
      voiceState: VoiceState.listening,
      recognizedText: 'Mendengarkan suara Anda...',
      speechResponse: '',
      notificationMessage: null,
    );

    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if ((status == 'done' || status == 'notListening') &&
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
          listenOptions: stt.SpeechListenOptions(localeId: 'id_ID'),
          onResult: (result) {
            if (result.recognizedWords.isNotEmpty) {
              state = state.copyWith(recognizedText: result.recognizedWords);
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
    try {
      await _speech.stop();
    } catch (_) {}

    state = state.copyWith(
      voiceState: VoiceState.processing,
      recognizedText: rawSpeech,
      speechResponse: 'Menganalisis maksud perintah...',
    );

    await Future.delayed(const Duration(milliseconds: 600));

    final result = await VoiceAiService.processVoiceCommand(rawSpeech);

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

    // Speak audio voice response out loud via TTS
    _speakAudioResponse(result.speechResponse);

    // Transition back to idle after speech completes
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && state.voiceState == VoiceState.speaking) {
        state = state.copyWith(voiceState: VoiceState.idle);
      }
    });
  }

  /// Speak audio response using Text-to-Speech
  void _speakAudioResponse(String responseText) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(responseText);
    } catch (_) {}
  }

  /// Stop listening & speech synthesis
  void stopListening() {
    try {
      _speech.stop();
      _flutterTts.stop();
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
    try {
      _speech.stop();
      _flutterTts.stop();
    } catch (_) {}
    super.dispose();
  }
}

final farmerVoiceProvider =
    StateNotifierProvider<FarmerVoiceNotifier, FarmerVoiceState>((ref) {
  return FarmerVoiceNotifier();
});
