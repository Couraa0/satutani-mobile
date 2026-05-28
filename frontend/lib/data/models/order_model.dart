class OrderModel {
  final String id;
  final String productId;
  final String productName;
  final String productImageUrl;
  final String farmerName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double shippingCost;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String deliveryMethod; // 'cold_chain' | 'regular'
  final List<TrackingStep> trackingSteps;

  const OrderModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl = '',
    this.farmerName = '',
    required this.quantity,
    this.unit = 'kg',
    required this.pricePerUnit,
    this.shippingCost = 0,
    this.status = OrderStatus.active,
    required this.createdAt,
    this.estimatedDelivery,
    this.deliveryMethod = 'regular',
    this.trackingSteps = const [],
  });

  double get subtotal => quantity * pricePerUnit;
  double get total => subtotal + shippingCost;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      productImageUrl: json['productImageUrl'] ?? '',
      farmerName: json['farmerName'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.active,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      estimatedDelivery: DateTime.tryParse(json['estimatedDelivery'] ?? ''),
      deliveryMethod: json['deliveryMethod'] ?? 'regular',
    );
  }

  static List<OrderModel> mockOrders = [
    OrderModel(
      id: 'ORD-001',
      productId: '1',
      productName: 'Beras Premium Cianjur',
      productImageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
      farmerName: 'Pak Budi Santoso',
      quantity: 5,
      unit: 'kg',
      pricePerUnit: 14000,
      shippingCost: 10000,
      status: OrderStatus.active,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
      deliveryMethod: 'cold_chain',
      trackingSteps: [
        TrackingStep(title: 'Pesanan Dikonfirmasi', isCompleted: true, completedAt: DateTime.now().subtract(const Duration(hours: 3))),
        TrackingStep(title: 'Dipanen & Disiapkan', isCompleted: true, completedAt: DateTime.now().subtract(const Duration(hours: 1))),
        const TrackingStep(title: 'Dalam Pengiriman', isCompleted: false, isActive: true),
        const TrackingStep(title: 'Diterima', isCompleted: false),
      ],
    ),
    OrderModel(
      id: 'ORD-002',
      productId: '2',
      productName: 'Bayam Organik Segar',
      productImageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
      farmerName: 'Bu Sari Dewi',
      quantity: 3,
      unit: 'ikat',
      pricePerUnit: 5000,
      shippingCost: 8000,
      status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      deliveryMethod: 'regular',
    ),
    OrderModel(
      id: 'ORD-003',
      productId: '3',
      productName: 'Mangga Harum Manis',
      productImageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400',
      farmerName: 'Pak Hartono',
      quantity: 2,
      unit: 'kg',
      pricePerUnit: 18000,
      shippingCost: 10000,
      status: OrderStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      deliveryMethod: 'regular',
    ),
  ];
}

enum OrderStatus { active, completed, cancelled }

class TrackingStep {
  final String title;
  final bool isCompleted;
  final bool isActive;
  final DateTime? completedAt;

  const TrackingStep({
    required this.title,
    this.isCompleted = false,
    this.isActive = false,
    this.completedAt,
  });
}
