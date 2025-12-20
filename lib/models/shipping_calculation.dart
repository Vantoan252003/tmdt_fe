class ShippingCalculationRequest {
  final String shopId;
  final double deliveryLatitude;
  final double deliveryLongitude;

  ShippingCalculationRequest({
    required this.shopId,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
    };
  }
}

class ShippingCalculationResponse {
  final String shopId;
  final String shopName;
  final double shopLatitude;
  final double shopLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final double distanceKm;
  final double shippingFee;
  final String formattedDistance;
  final String formattedFee;
  final String estimatedTime;

  ShippingCalculationResponse({
    required this.shopId,
    required this.shopName,
    required this.shopLatitude,
    required this.shopLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.distanceKm,
    required this.shippingFee,
    required this.formattedDistance,
    required this.formattedFee,
    required this.estimatedTime,
  });

  factory ShippingCalculationResponse.fromJson(Map<String, dynamic> json) {
    return ShippingCalculationResponse(
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      shopLatitude: (json['shopLatitude'] ?? 0).toDouble(),
      shopLongitude: (json['shopLongitude'] ?? 0).toDouble(),
      deliveryLatitude: (json['deliveryLatitude'] ?? 0).toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      formattedDistance: json['formattedDistance'] ?? '',
      formattedFee: json['formattedFee'] ?? '',
      estimatedTime: json['estimatedTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'shopLatitude': shopLatitude,
      'shopLongitude': shopLongitude,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'distanceKm': distanceKm,
      'shippingFee': shippingFee,
      'formattedDistance': formattedDistance,
      'formattedFee': formattedFee,
      'estimatedTime': estimatedTime,
    };
  }
}
