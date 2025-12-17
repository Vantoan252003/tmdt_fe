class BannerModel {
  final String bannerId;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final int displayOrder;
  final bool isActive;
  final String? validFrom;
  final String? validTo;
  final String createdAt;

  BannerModel({
    required this.bannerId,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    required this.displayOrder,
    required this.isActive,
    this.validFrom,
    this.validTo,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      bannerId: json['bannerId'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      linkUrl: json['linkUrl'],
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      validFrom: json['validFrom'],
      validTo: json['validTo'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bannerId': bannerId,
      'title': title,
      'imageUrl': imageUrl,
      if (linkUrl != null) 'linkUrl': linkUrl,
      'displayOrder': displayOrder,
      'isActive': isActive,
      if (validFrom != null) 'validFrom': validFrom,
      if (validTo != null) 'validTo': validTo,
      'createdAt': createdAt,
    };
  }
}