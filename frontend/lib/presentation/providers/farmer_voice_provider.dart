import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  FarmerVoiceNotifier() : super(FarmerVoiceState()) {
    loadDashboardData();
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

      // Mock initial items if empty for visually rich initial demo mirror
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

  /// Start Listening to Voice Input
  void startListening() {
    state = state.copyWith(
      voiceState: VoiceState.listening,
      recognizedText: 'Mendengarkan suara Anda...',
      speechResponse: '',
      notificationMessage: null,
    );
  }

  /// Process Voice Command (handles STT -> Intent Classifier -> API Exec -> TTS Feedback)
  Future<void> processSpeech(String rawSpeech) async {
    state = state.copyWith(
      voiceState: VoiceState.processing,
      recognizedText: rawSpeech,
      speechResponse: 'Menganalisis maksud perintah...',
    );

    await Future.delayed(const Duration(milliseconds: 700));

    final result = await VoiceAiService.processVoiceCommand(rawSpeech);

    // Dynamic UI Update according to executed backend intent
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

    // Automatically transition back to idle after speaking duration
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && state.voiceState == VoiceState.speaking) {
        state = state.copyWith(voiceState: VoiceState.idle);
      }
    });
  }

  /// Reset Voice Assistant state
  void stopListening() {
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
}

final farmerVoiceProvider =
    StateNotifierProvider<FarmerVoiceNotifier, FarmerVoiceState>((ref) {
  return FarmerVoiceNotifier();
});
