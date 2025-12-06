class Product {
  final String productId;
  final String shopId;
  final String categoryId;
  final String productName;
  final String description;
  final double price;
  final double discountPercentage;
  final int stockQuantity;
  final int soldQuantity;
  final double rating;
  final int totalReviews;
  final String status;
  final double weight;
  final String? mainImageUrl;
  final String? imageUrl1;
  final String? imageUrl2;
  final String? imageUrl3;
  final String? imageUrl4;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.productId,
    required this.shopId,
    required this.categoryId,
    required this.productName,
    required this.description,
    required this.price,
    this.discountPercentage = 0.0,
    this.stockQuantity = 0,
    this.soldQuantity = 0,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.status = 'ACTIVE',
    this.weight = 0.0,
    this.mainImageUrl,
    this.imageUrl1,
    this.imageUrl2,
    this.imageUrl3,
    this.imageUrl4,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters for backward compatibility
  String get id => productId;
  String get name => productName;
  String get imageUrl => mainImageUrl ?? imageUrl1 ?? '';
  String get category => categoryId;
  int get reviewCount => totalReviews;
  int get stock => stockQuantity;
  List<String> get images {
    return [
      if (mainImageUrl != null && mainImageUrl!.isNotEmpty) mainImageUrl!,
      if (imageUrl1 != null && imageUrl1!.isNotEmpty) imageUrl1!,
      if (imageUrl2 != null && imageUrl2!.isNotEmpty) imageUrl2!,
      if (imageUrl3 != null && imageUrl3!.isNotEmpty) imageUrl3!,
      if (imageUrl4 != null && imageUrl4!.isNotEmpty) imageUrl4!,
    ];
  }

  double get finalPrice => price * (1 - discountPercentage / 100);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? '',
      shopId: json['shopId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      soldQuantity: json['soldQuantity'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      weight: (json['weight'] ?? 0).toDouble(),
      mainImageUrl: json['mainImageUrl'],
      imageUrl1: json['imageUrl1'],
      imageUrl2: json['imageUrl2'],
      imageUrl3: json['imageUrl3'],
      imageUrl4: json['imageUrl4'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'shopId': shopId,
      'categoryId': categoryId,
      'productName': productName,
      'description': description,
      'price': price,
      'discountPercentage': discountPercentage,
      'stockQuantity': stockQuantity,
      'soldQuantity': soldQuantity,
      'rating': rating,
      'totalReviews': totalReviews,
      'status': status,
      'weight': weight,
      'mainImageUrl': mainImageUrl,
      'imageUrl1': imageUrl1,
      'imageUrl2': imageUrl2,
      'imageUrl3': imageUrl3,
      'imageUrl4': imageUrl4,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
