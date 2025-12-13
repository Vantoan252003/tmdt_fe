class Voucher {
  final String voucherId;
  final String code;
  final String title;
  final String description;
  final String type; // PERCENTAGE_DISCOUNT, FIXED_AMOUNT
  final String scope; // ADMIN_WIDE, SHOP_SPECIFIC
  final double discountValue;
  final double? maxDiscount;
  final double minOrderValue;
  final int usageLimit;
  final int usageLimitPerUser;
  final int usedCount;
  final String validFrom;
  final String validTo;
  final String status;
  final String? shopId;
  final String createdBy;
  final List<String>? applicableCategories;
  final List<String>? applicableProducts;
  final bool firstOrderOnly;
  final String createdAt;
  final String updatedAt;
  final bool expired;
  final bool usedUp;
  final bool valid;

  Voucher({
    required this.voucherId,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.scope,
    required this.discountValue,
    this.maxDiscount,
    required this.minOrderValue,
    required this.usageLimit,
    required this.usageLimitPerUser,
    required this.usedCount,
    required this.validFrom,
    required this.validTo,
    required this.status,
    this.shopId,
    required this.createdBy,
    this.applicableCategories,
    this.applicableProducts,
    required this.firstOrderOnly,
    required this.createdAt,
    required this.updatedAt,
    required this.expired,
    required this.usedUp,
    required this.valid,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      voucherId: json['voucherId'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      scope: json['scope'] ?? '',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      maxDiscount: json['maxDiscount'] != null ? (json['maxDiscount'] as num).toDouble() : null,
      minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
      usageLimit: json['usageLimit'] ?? 0,
      usageLimitPerUser: json['usageLimitPerUser'] ?? 0,
      usedCount: json['usedCount'] ?? 0,
      validFrom: json['validFrom'] ?? '',
      validTo: json['validTo'] ?? '',
      status: json['status'] ?? '',
      shopId: json['shopId'],
      createdBy: json['createdBy'] ?? '',
      applicableCategories: json['applicableCategories'] != null
          ? List<String>.from(json['applicableCategories'])
          : null,
      applicableProducts: json['applicableProducts'] != null
          ? List<String>.from(json['applicableProducts'])
          : null,
      firstOrderOnly: json['firstOrderOnly'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      expired: json['expired'] ?? false,
      usedUp: json['usedUp'] ?? false,
      valid: json['valid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucherId': voucherId,
      'code': code,
      'title': title,
      'description': description,
      'type': type,
      'scope': scope,
      'discountValue': discountValue,
      'maxDiscount': maxDiscount,
      'minOrderValue': minOrderValue,
      'usageLimit': usageLimit,
      'usageLimitPerUser': usageLimitPerUser,
      'usedCount': usedCount,
      'validFrom': validFrom,
      'validTo': validTo,
      'status': status,
      'shopId': shopId,
      'createdBy': createdBy,
      'applicableCategories': applicableCategories,
      'applicableProducts': applicableProducts,
      'firstOrderOnly': firstOrderOnly,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'expired': expired,
      'usedUp': usedUp,
      'valid': valid,
    };
  }

  // Calculate discount amount for given order value
  double calculateDiscount(double orderValue) {
    if (!valid || expired || usedUp) return 0.0;
    if (orderValue < minOrderValue) return 0.0;

    if (type == 'PERCENTAGE_DISCOUNT') {
      double discount = orderValue * (discountValue / 100);
      if (maxDiscount != null && discount > maxDiscount!) {
        return maxDiscount!;
      }
      return discount;
    } else if (type == 'FIXED_AMOUNT') {
      return discountValue;
    }
    return 0.0;
  }

  // Get display text for discount value
  String get discountText {
    if (type == 'PERCENTAGE_DISCOUNT') {
      return 'Giảm ${discountValue.toStringAsFixed(0)}%';
    } else if (type == 'FIXED_AMOUNT') {
      return 'Giảm ${discountValue.toStringAsFixed(0)}đ';
    }
    return '';
  }

  // Get display text for minimum order value
  String get minOrderText {
    if (minOrderValue > 0) {
      return 'Đơn tối thiểu ${minOrderValue.toStringAsFixed(0)}đ';
    }
    return 'Không yêu cầu đơn tối thiểu';
  }

  // Get display text for max discount
  String? get maxDiscountText {
    if (type == 'PERCENTAGE_DISCOUNT' && maxDiscount != null) {
      return 'Tối đa ${maxDiscount!.toStringAsFixed(0)}đ';
    }
    return null;
  }

  // Check if voucher can be applied to order
  bool canApplyToOrder(double orderValue) {
    return valid && !expired && !usedUp && orderValue >= minOrderValue;
  }
}
