import 'product.dart';

class Shop {
  final String shopId;
  final String shopName;
  final String description;
  final String? logoUrl;
  final String? bannerUrl;
  final String address;
  final String phoneNumber;
  final String sellerId;
  final double rating;
  final int totalOrders;
  final int totalProducts;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<Product> products;

  Shop({
    required this.shopId,
    required this.shopName,
    required this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.address,
    required this.phoneNumber,
    required this.sellerId,
    this.rating = 0.0,
    this.totalOrders = 0,
    this.totalProducts = 0,
    this.status = 'PENDING',
    required this.createdAt,
    required this.updatedAt,
    this.products = const [],
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'],
      bannerUrl: json['bannerUrl'],
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      sellerId: json['sellerId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      products: json['products'] != null
          ? (json['products'] as List).map((p) => Product.fromJson(p)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'description': description,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'address': address,
      'phoneNumber': phoneNumber,
      'sellerId': sellerId,
      'rating': rating,
      'totalOrders': totalOrders,
      'totalProducts': totalProducts,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}
