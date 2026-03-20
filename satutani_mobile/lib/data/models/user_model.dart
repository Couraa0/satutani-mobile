class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final int totalOrders;
  final int totalReviews;
  final int loyaltyPoints;
  final String city;
  final String province;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.totalOrders = 0,
    this.totalReviews = 0,
    this.loyaltyPoints = 0,
    this.city = 'Jakarta',
    this.province = 'DKI Jakarta',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      totalOrders: json['totalOrders'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      city: json['city'] ?? 'Jakarta',
      province: json['province'] ?? 'DKI Jakarta',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatarUrl': avatarUrl,
    'totalOrders': totalOrders,
    'totalReviews': totalReviews,
    'loyaltyPoints': loyaltyPoints,
    'city': city,
    'province': province,
  };

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // Mock data
  static UserModel mockUser = const UserModel(
    id: '1',
    name: 'Andi Pratama',
    email: 'andi.pratama@gmail.com',
    phone: '08123456789',
    avatarUrl: 'https://i.pravatar.cc/100?img=12',
    totalOrders: 24,
    totalReviews: 18,
    loyaltyPoints: 1250,
    city: 'Jakarta',
    province: 'DKI Jakarta',
  );
}
