class ShopReview {
  final String reviewId;
  final String shopId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String comment;
  final String createdAt;
  final String? updatedAt;

  ShopReview({
    required this.reviewId,
    required this.shopId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory ShopReview.fromJson(Map<String, dynamic> json) {
    return ShopReview(
      reviewId: json['reviewId'] ?? '',
      shopId: json['shopId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'shopId': shopId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}

class CanReviewShopResponse {
  final bool canReview;
  final bool hasPurchased;
  final bool hasReviewed;

  CanReviewShopResponse({
    required this.canReview,
    required this.hasPurchased,
    required this.hasReviewed,
  });

  factory CanReviewShopResponse.fromJson(Map<String, dynamic> json) {
    return CanReviewShopResponse(
      canReview: json['canReview'] ?? false,
      hasPurchased: json['hasPurchased'] ?? false,
      hasReviewed: json['hasReviewed'] ?? false,
    );
  }
}

class CreateShopReviewRequest {
  final int rating;
  final String comment;

  CreateShopReviewRequest({
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}
