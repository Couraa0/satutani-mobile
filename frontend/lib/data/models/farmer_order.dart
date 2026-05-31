import '../mock/orders_mock.dart' show OrderStatus;

/// Order dari sisi petani, hasil parse JSON backend (GET /api/orders/farmer).
/// Backend = 1 baris order per produk, jadi model ini single-produk.
class FarmerOrder {
  final String id;
  final String productName;
  final String productImageUrl;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double shippingCost;
  final OrderStatus status;
  final String consumerName;
  final String consumerPhone;
  final DateTime createdAt;

  const FarmerOrder({
    required this.id,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.shippingCost,
    required this.status,
    required this.consumerName,
    required this.consumerPhone,
    required this.createdAt,
  });

  double get subtotal => quantity * pricePerUnit;
  double get total => subtotal + shippingCost;

  factory FarmerOrder.fromJson(Map<String, dynamic> json) {
    final consumer = json['consumer'] as Map<String, dynamic>?;
    return FarmerOrder(
      id: json['id']?.toString() ?? '',
      productName: json['productName'] ?? '',
      productImageUrl: json['productImageUrl'] ?? '',
      quantity: _toDouble(json['quantity']),
      unit: json['unit'] ?? 'kg',
      pricePerUnit: _toDouble(json['pricePerUnit']),
      shippingCost: _toDouble(json['shippingCost']),
      status: statusFromBackend(json['status']?.toString()),
      consumerName: consumer?['name'] ?? json['consumerName'] ?? 'Pembeli',
      consumerPhone: consumer?['phone'] ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static List<FarmerOrder> listFromJson(List<dynamic> data) =>
      data.map((e) => FarmerOrder.fromJson(e as Map<String, dynamic>)).toList();

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

/// Map status string backend -> enum tampilan (Indonesia) yang dipakai StatusBadge.
OrderStatus statusFromBackend(String? s) {
  switch (s) {
    case 'confirmed':
      return OrderStatus.dikonfirmasi;
    case 'harvesting':
      return OrderStatus.dipanen;
    case 'shipped':
      return OrderStatus.dikirim;
    case 'completed':
      return OrderStatus.selesai;
    case 'cancelled':
      return OrderStatus.dibatalkan;
    case 'pending':
    default:
      return OrderStatus.menunggu;
  }
}

/// Map enum tampilan -> status string backend (untuk PATCH status).
String statusToBackend(OrderStatus s) {
  switch (s) {
    case OrderStatus.menunggu:
      return 'pending';
    case OrderStatus.dikonfirmasi:
      return 'confirmed';
    case OrderStatus.dipanen:
      return 'harvesting';
    case OrderStatus.dikirim:
      return 'shipped';
    case OrderStatus.selesai:
      return 'completed';
    case OrderStatus.dibatalkan:
      return 'cancelled';
  }
}
