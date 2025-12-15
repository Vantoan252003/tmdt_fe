class User {
  final String id;
  final String fullName;
  final String email;
  final String?   phoneNumber;
  final String? avatarUrl;
  final String? address;
  final String role;
  final UserStats? stats;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.address,
    required this.role,
    this.stats,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      address: json['address'],
      role: json['role'] ?? 'CUSTOMER',
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'address': address,
      'role': role,
      'stats': stats?.toJson(),
    };
  }

  // Copy with method for updating specific fields
  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? address,
    String? role,
    UserStats? stats,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      role: role ?? this.role,
      stats: stats ?? this.stats,
    );
  }

  // Helper getters for backward compatibility
  String get name => fullName;
}

class UserStats {
  final int totalOrders;
  final int totalReviews;
  final int totalFavorites;

  UserStats({
    required this.totalOrders,
    required this.totalReviews,
    required this.totalFavorites,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalOrders: json['totalOrders'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      totalFavorites: json['totalFavorites'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'totalReviews': totalReviews,
      'totalFavorites': totalFavorites,
    };
  }
}
