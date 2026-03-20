class FarmerModel {
  final String id;
  final String name;
  final String location;
  final String province;
  final double rating;
  final int reviewCount;
  final String avatarUrl;
  final String specialty;
  final bool isVerified;
  final double distanceKm;

  const FarmerModel({
    required this.id,
    required this.name,
    required this.location,
    this.province = '',
    this.rating = 4.5,
    this.reviewCount = 0,
    this.avatarUrl = '',
    this.specialty = '',
    this.isVerified = true,
    this.distanceKm = 0,
  });

  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      province: json['province'] ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      avatarUrl: json['avatarUrl'] ?? '',
      specialty: json['specialty'] ?? '',
      isVerified: json['isVerified'] ?? true,
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'province': province,
    'rating': rating,
    'reviewCount': reviewCount,
    'avatarUrl': avatarUrl,
    'specialty': specialty,
    'isVerified': isVerified,
    'distanceKm': distanceKm,
  };

  static List<FarmerModel> mockFarmers = [
    const FarmerModel(
      id: '1',
      name: 'Pak Budi Santoso',
      location: 'Cianjur',
      province: 'Jawa Barat',
      rating: 4.9,
      reviewCount: 312,
      avatarUrl: 'https://i.pravatar.cc/100?img=3',
      specialty: 'Beras, Jagung, Padi',
      isVerified: true,
      distanceKm: 2.3,
    ),
    const FarmerModel(
      id: '2',
      name: 'Bu Sari Dewi',
      location: 'Bandung',
      province: 'Jawa Barat',
      rating: 4.7,
      reviewCount: 189,
      avatarUrl: 'https://i.pravatar.cc/100?img=5',
      specialty: 'Sayuran Organik, Bayam',
      isVerified: true,
      distanceKm: 4.1,
    ),
    const FarmerModel(
      id: '3',
      name: 'Pak Hartono',
      location: 'Indramayu',
      province: 'Jawa Barat',
      rating: 4.8,
      reviewCount: 445,
      avatarUrl: 'https://i.pravatar.cc/100?img=7',
      specialty: 'Mangga, Papaya, Rambutan',
      isVerified: true,
      distanceKm: 8.7,
    ),
    const FarmerModel(
      id: '4',
      name: 'Bu Rina Wati',
      location: 'Batu, Malang',
      province: 'Jawa Timur',
      rating: 4.6,
      reviewCount: 201,
      avatarUrl: 'https://i.pravatar.cc/100?img=9',
      specialty: 'Tomat, Paprika, Cabai',
      isVerified: true,
      distanceKm: 12.4,
    ),
  ];
}
