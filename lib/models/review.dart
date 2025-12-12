class Review {
  final String reviewId;
  final String userId;
  final String productId;
  final int rating;
  final String? comment;
  final List<String>? imageUrls;
  final String createdAt;
  final String updatedAt;

  Review({
    required this.reviewId,
    required this.userId,
    required this.productId,
    required this.rating,
    this.comment,
    this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'] as List)
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ReviewResponse {
  final String reviewId;
  final String userId;
  final String userName;
  final String productId;
  final String? orderId;
  final int rating;
  final String? comment;
  final List<String>? images;
  final String createdAt;

  ReviewResponse({
    required this.reviewId,
    required this.userId,
    required this.userName,
    required this.productId,
    this.orderId,
    required this.rating,
    this.comment,
    this.images,
    required this.createdAt,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      reviewId: json['reviewId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Người dùng',
      productId: json['productId'] ?? '',
      orderId: json['orderId'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'userName': userName,
      'productId': productId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': createdAt,
    };
  }
}

class CreateReviewRequest {
  final String productId;
  final int rating;
  final String? comment;

  CreateReviewRequest({
    required this.productId,
    required this.rating,
    this.comment,
  });
}

class RatingStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts; // 5: 10, 4: 5, etc

  RatingStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ratingCounts: json['ratingCounts'] != null
          ? Map<int, int>.from(
              (json['ratingCounts'] as Map).cast<String, int>()
                  .map((key, value) => MapEntry(int.parse(key), value)))
          : {},
    );
  }
}
