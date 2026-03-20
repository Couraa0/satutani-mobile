enum OrderStatus { menunggu, dikonfirmasi, dipanen, dikirim, selesai, dibatalkan }

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.menunggu: return 'Menunggu';
      case OrderStatus.dikonfirmasi: return 'Dikonfirmasi';
      case OrderStatus.dipanen: return 'Dipanen';
      case OrderStatus.dikirim: return 'Dikirim';
      case OrderStatus.selesai: return 'Selesai';
      case OrderStatus.dibatalkan: return 'Dibatalkan';
    }
  }
}

class OrderItemModel {
  final String productId, productName, productImageUrl, unit;
  final double price;
  final int quantity;
  const OrderItemModel({
    required this.productId, required this.productName, required this.productImageUrl,
    required this.price, required this.unit, required this.quantity,
  });
  double get subtotal => price * quantity;
}

class OrderModel {
  final String id, consumerId, consumerName, consumerType, farmerId, farmerName;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final double total, shipping;
  final String address, orderedAt;
  final String? confirmedAt, harvestedAt, shippedAt, completedAt;
  const OrderModel({
    required this.id, required this.consumerId, required this.consumerName,
    required this.consumerType, required this.farmerId, required this.farmerName,
    required this.items, required this.status,
    required this.total, required this.shipping,
    required this.address, required this.orderedAt,
    this.confirmedAt, this.harvestedAt, this.shippedAt, this.completedAt,
  });
}

const _bayamImg  = 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=200';
const _berasImg  = 'https://images.unsplash.com/photo-1536304929831-ee1ca9d44906?w=200';
const _cabaiImg  = 'https://images.unsplash.com/photo-1534906832023-d7eed28c3c86?w=200';
const _apelImg   = 'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?w=200';
const _udangImg  = 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=200';
const _jaheImg   = 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=200';
const _kentangImg= 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=200';
const _manggaImg = 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=200';
const _wortelImg = 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200';
const _jerukImg  = 'https://images.unsplash.com/photo-1588004785891-9a9943dfb25b?w=200';

final List<OrderModel> mockOrders = [
  const OrderModel(
    id: 'ORD-001', consumerId: 'c1', consumerName: 'Andi Pratama', consumerType: 'Individu',
    farmerId: 'f1', farmerName: 'Budi Santoso',
    items: [
      OrderItemModel(productId: 'p1', productName: 'Bayam Organik Segar', productImageUrl: _bayamImg, price: 5000, unit: 'ikat', quantity: 3),
      OrderItemModel(productId: 'p2', productName: 'Wortel Organik', productImageUrl: _wortelImg, price: 8000, unit: 'kg', quantity: 2),
    ],
    status: OrderStatus.menunggu, total: 41000, shipping: 10000,
    address: 'Jl. Sudirman No. 45, Jakarta Pusat', orderedAt: '16 Mar 2026 10:30',
  ),
  const OrderModel(
    id: 'ORD-002', consumerId: 'c2', consumerName: 'Resto Makan Enak', consumerType: 'Restoran',
    farmerId: 'f2', farmerName: 'Siti Rahayu',
    items: [
      OrderItemModel(productId: 'p19', productName: 'Beras Pandan Wangi', productImageUrl: _berasImg, price: 18000, unit: 'kg', quantity: 10),
    ],
    status: OrderStatus.dikonfirmasi, total: 205000, shipping: 25000,
    address: 'Jl. Kebon Jeruk No. 12, Jakarta Barat', orderedAt: '15 Mar 2026 14:00',
    confirmedAt: '15 Mar 2026 16:30',
  ),
  const OrderModel(
    id: 'ORD-003', consumerId: 'c1', consumerName: 'Andi Pratama', consumerType: 'Individu',
    farmerId: 'f3', farmerName: 'Ahmad Fauzi',
    items: [
      OrderItemModel(productId: 'p6', productName: 'Cabai Merah Keriting', productImageUrl: _cabaiImg, price: 35000, unit: 'kg', quantity: 1),
    ],
    status: OrderStatus.dipanen, total: 70000, shipping: 15000,
    address: 'Jl. Sudirman No. 45, Jakarta Pusat', orderedAt: '14 Mar 2026 09:00',
    confirmedAt: '14 Mar 2026 11:00', harvestedAt: '15 Mar 2026 07:00',
  ),
  const OrderModel(
    id: 'ORD-004', consumerId: 'c3', consumerName: 'Hotel Grand Nusa', consumerType: 'Hotel',
    farmerId: 'f4', farmerName: 'Dewi Kusuma',
    items: [
      OrderItemModel(productId: 'p11', productName: 'Apel Manalagi Malang', productImageUrl: _apelImg, price: 22000, unit: 'kg', quantity: 20),
      OrderItemModel(productId: 'p12', productName: 'Jeruk Keprok Organik', productImageUrl: _jerukImg, price: 18000, unit: 'kg', quantity: 15),
    ],
    status: OrderStatus.dikirim, total: 730000, shipping: 50000,
    address: 'Jl. MH Thamrin No. 1, Jakarta Pusat', orderedAt: '12 Mar 2026 08:00',
    confirmedAt: '12 Mar 2026 10:00', harvestedAt: '13 Mar 2026 06:00', shippedAt: '14 Mar 2026 09:00',
  ),
  const OrderModel(
    id: 'ORD-005', consumerId: 'c1', consumerName: 'Andi Pratama', consumerType: 'Individu',
    farmerId: 'f5', farmerName: 'Rudi Hartono',
    items: [
      OrderItemModel(productId: 'p29', productName: 'Udang Vaname Segar', productImageUrl: _udangImg, price: 80000, unit: 'kg', quantity: 2),
    ],
    status: OrderStatus.selesai, total: 185000, shipping: 25000,
    address: 'Jl. Sudirman No. 45, Jakarta Pusat', orderedAt: '5 Mar 2026 11:00',
    confirmedAt: '5 Mar 2026 13:00', harvestedAt: '6 Mar 2026 07:00',
    shippedAt: '7 Mar 2026 10:00', completedAt: '8 Mar 2026 14:30',
  ),
  const OrderModel(
    id: 'ORD-006', consumerId: 'c4', consumerName: 'Kantin Karyawan ABC', consumerType: 'Kantin',
    farmerId: 'f1', farmerName: 'Budi Santoso',
    items: [
      OrderItemModel(productId: 'p3', productName: 'Brokoli Garut', productImageUrl: _bayamImg, price: 12000, unit: 'kg', quantity: 5),
    ],
    status: OrderStatus.dibatalkan, total: 85000, shipping: 25000,
    address: 'Kawasan Industri MM2100, Bekasi', orderedAt: '10 Mar 2026 08:00',
  ),
  const OrderModel(
    id: 'ORD-007', consumerId: 'c1', consumerName: 'Andi Pratama', consumerType: 'Individu',
    farmerId: 'f6', farmerName: 'Hendra Wijaya',
    items: [
      OrderItemModel(productId: 'p23', productName: 'Jahe Merah Organik', productImageUrl: _jaheImg, price: 25000, unit: 'kg', quantity: 1),
    ],
    status: OrderStatus.selesai, total: 57000, shipping: 20000,
    address: 'Jl. Sudirman No. 45, Jakarta Pusat', orderedAt: '1 Mar 2026 09:00',
    confirmedAt: '1 Mar 2026 11:00', harvestedAt: '2 Mar 2026 07:00',
    shippedAt: '3 Mar 2026 09:00', completedAt: '4 Mar 2026 15:00',
  ),
  const OrderModel(
    id: 'ORD-008', consumerId: 'c1', consumerName: 'Andi Pratama', consumerType: 'Individu',
    farmerId: 'f9', farmerName: 'Agus Salim',
    items: [
      OrderItemModel(productId: 'p13', productName: 'Mangga Harum Manis', productImageUrl: _manggaImg, price: 20000, unit: 'kg', quantity: 3),
    ],
    status: OrderStatus.menunggu, total: 85000, shipping: 25000,
    address: 'Jl. Sudirman No. 45, Jakarta Pusat', orderedAt: '16 Mar 2026 15:00',
  ),
];
