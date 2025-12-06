class Category {
  final String categoryId;
  final String categoryName;
  final String description;
  final String? parentCategoryId;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.description,
    this.parentCategoryId,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      description: json['description'] ?? '',
      parentCategoryId: json['parentCategoryId'],
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'parentCategoryId': parentCategoryId,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
