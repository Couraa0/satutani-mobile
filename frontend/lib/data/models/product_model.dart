class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final double rating;
  final int reviewCount;
  final double stock;
  final String category;
  final List<String> imageUrls;
  final String farmerId;
  final String farmerName;
  final String farmerAvatarUrl;
  final bool isAvailable;
  final bool isAiPrice;
  final bool isPreOrder;
  final DateTime? estimatedHarvestDate;
  final double? preOrderTarget;
  final double? preOrderFilled;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.unit = 'kg',
    this.rating = 4.5,
    this.reviewCount = 0,
    this.stock = 0,
    this.category = '',
    this.imageUrls = const [],
    this.farmerId = '',
    this.farmerName = '',
    this.farmerAvatarUrl = '',
    this.isAvailable = true,
    this.isAiPrice = false,
    this.isPreOrder = false,
    this.estimatedHarvestDate,
    this.preOrderTarget,
    this.preOrderFilled,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      stock: (json['stock'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      farmerId: json['farmerId']?.toString() ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerAvatarUrl: json['farmerAvatarUrl'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      isAiPrice: json['isAiPrice'] ?? false,
      isPreOrder: json['isPreOrder'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'unit': unit,
    'rating': rating,
    'reviewCount': reviewCount,
    'stock': stock,
    'category': category,
    'imageUrls': imageUrls,
    'farmerId': farmerId,
    'farmerName': farmerName,
    'farmerAvatarUrl': farmerAvatarUrl,
    'isAvailable': isAvailable,
    'isAiPrice': isAiPrice,
    'isPreOrder': isPreOrder,
  };

  // Mock data
  static List<ProductModel> mockProducts = [
    const ProductModel(
      id: '1',
      name: 'Beras Premium Cianjur',
      description: 'Beras premium kualitas super dari lahan organik Cianjur. Dipanen langsung oleh petani berpengalaman dengan metode tradisional yang terjaga kualitasnya.',
      price: 14000,
      unit: 'kg',
      rating: 4.8,
      reviewCount: 234,
      stock: 150,
      category: 'grain',
      imageUrls: [
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
        'https://images.unsplash.com/photo-1559825481-12a05cc00344?w=400',
      ],
      farmerId: '1',
      farmerName: 'Pak Budi Santoso',
      farmerAvatarUrl: 'https://i.pravatar.cc/100?img=3',
      isAvailable: true,
      isAiPrice: true,
    ),
    const ProductModel(
      id: '2',
      name: 'Bayam Organik Segar',
      description: 'Bayam organik segar dipanen pagi hari, tanpa pestisida kimia. Kaya nutrisi dan cocok untuk konsumsi sehari-hari.',
      price: 5000,
      unit: 'ikat',
      rating: 4.6,
      reviewCount: 89,
      stock: 50,
      category: 'vegetable',
      imageUrls: [
        'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
      ],
      farmerId: '2',
      farmerName: 'Bu Sari Dewi',
      farmerAvatarUrl: 'https://i.pravatar.cc/100?img=5',
      isAvailable: true,
      isAiPrice: false,
    ),
    const ProductModel(
      id: '3',
      name: 'Mangga Harum Manis',
      description: 'Mangga harum manis dari kebun Indramayu. Manis, segar, dan langsung dari pohon.',
      price: 18000,
      unit: 'kg',
      rating: 4.9,
      reviewCount: 412,
      stock: 80,
      category: 'fruit',
      imageUrls: [
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400',
      ],
      farmerId: '3',
      farmerName: 'Pak Hartono',
      farmerAvatarUrl: 'https://i.pravatar.cc/100?img=7',
      isAvailable: true,
      isAiPrice: true,
    ),
    const ProductModel(
      id: '4',
      name: 'Tomat Cherry Merah',
      description: 'Tomat cherry segar dari highland Batu, Malang. Asam manis, cocok untuk salad dan masakan.',
      price: 8000,
      unit: 'kg',
      rating: 4.7,
      reviewCount: 156,
      stock: 30,
      category: 'vegetable',
      imageUrls: [
        'https://images.unsplash.com/photo-1598512752271-33f913a5af13?w=400',
      ],
      farmerId: '4',
      farmerName: 'Bu Rina Wati',
      farmerAvatarUrl: 'https://i.pravatar.cc/100?img=9',
      isAvailable: true,
      isAiPrice: false,
    ),
    ProductModel(
      id: '5',
      name: 'Jagung Manis Pre-Order',
      description: 'Pre-order jagung manis panen berikutnya. Perkiraan panen 2 minggu lagi.',
      price: 6000,
      unit: 'kg',
      rating: 4.5,
      reviewCount: 23,
      stock: 0,
      category: 'grain',
      imageUrls: [
        'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400',
      ],
      farmerId: '1',
      farmerName: 'Pak Budi Santoso',
      farmerAvatarUrl: 'https://i.pravatar.cc/100?img=3',
      isAvailable: false,
      isAiPrice: false,
      isPreOrder: true,
      estimatedHarvestDate: DateTime.now().add(const Duration(days: 14)),
      preOrderTarget: 500,
      preOrderFilled: 320,
    ),
  ];
}
