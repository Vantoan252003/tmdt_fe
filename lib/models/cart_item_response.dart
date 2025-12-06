class CartItemResponse {
  final String cartItemId;
  final String productId;
  final String productName;
  final String? variantId;
  final int quantity;
  final double price;
  final double subtotal;
  final String? mainImageUrl;

  CartItemResponse({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    this.variantId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.mainImageUrl,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      cartItemId: json['cartItemId'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      variantId: json['variantId'],
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      mainImageUrl: json['mainImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'productId': productId,
      'productName': productName,
      'variantId': variantId,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'mainImageUrl': mainImageUrl,
    };
  }
}