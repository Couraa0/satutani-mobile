import '../mock/orders_mock.dart' show OrderStatus;
import 'farmer_order.dart' show statusFromBackend;

/// Satu langkah tracking pesanan (GET /api/orders/my -> trackingSteps).
class OrderTrackingStepModel {
  final int stepOrder;
  final String title;
  final bool isCompleted;
  final bool isActive;
  final DateTime? completedAt;

  const OrderTrackingStepModel({
    required this.stepOrder,
    required this.title,
    required this.isCompleted,
    required this.isActive,
    this.completedAt,
  });

  factory OrderTrackingStepModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingStepModel(
      stepOrder: (json['stepOrder'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      isCompleted: json['isCompleted'] == true,
      isActive: json['isActive'] == true,
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
    );
  }
}

/// Pesanan dari sisi pembeli, hasil parse JSON backend (GET /api/orders/my).
/// Backend = 1 baris order per produk, jadi model ini single-produk.
class ConsumerOrder {
  final String id;
  final String productName;
  final String productImageUrl;
  final String farmerName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double shippingCost;
  final OrderStatus status;
  final String deliveryMethod;
  final DateTime createdAt;
  final List<OrderTrackingStepModel> trackingSteps;

  const ConsumerOrder({
    required this.id,
    required this.productName,
    required this.productImageUrl,
    required this.farmerName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.shippingCost,
    required this.status,
    required this.deliveryMethod,
    required this.createdAt,
    required this.trackingSteps,
  });

  double get subtotal => quantity * pricePerUnit;
  double get total => subtotal + shippingCost;

  factory ConsumerOrder.fromJson(Map<String, dynamic> json) {
    final steps = (json['trackingSteps'] as List<dynamic>? ?? [])
        .map((e) => OrderTrackingStepModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));

    return ConsumerOrder(
      id: json['id']?.toString() ?? '',
      productName: json['productName'] ?? '',
      productImageUrl: json['productImageUrl'] ?? '',
      farmerName: (json['farmerName'] as String?)?.isNotEmpty == true
          ? json['farmerName']
          : 'Petani',
      quantity: _toDouble(json['quantity']),
      unit: json['unit'] ?? 'kg',
      pricePerUnit: _toDouble(json['pricePerUnit']),
      shippingCost: _toDouble(json['shippingCost']),
      status: statusFromBackend(json['status']?.toString()),
      deliveryMethod: json['deliveryMethod']?.toString() ?? 'regular',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      trackingSteps: steps,
    );
  }

  static List<ConsumerOrder> listFromJson(List<dynamic> data) =>
      data.map((e) => ConsumerOrder.fromJson(e as Map<String, dynamic>)).toList();

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
