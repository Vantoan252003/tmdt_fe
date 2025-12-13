class Order {
  final String orderId;
  final String userId;
  final double totalAmount;
  final String status;
  final String? shippingAddressId;
  final String paymentMethod;
  final String? note;
  final String createdAt;
  final String updatedAt;
  final List<OrderItem>? items;

  Order({
    required this.orderId,
    required this.userId,
    required this.totalAmount,
    required this.status,
    this.shippingAddressId,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      shippingAddressId: json['shippingAddressId'],
      paymentMethod: json['paymentMethod'] ?? '',
      note: json['note'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'totalAmount': totalAmount,
      'status': status,
      'shippingAddressId': shippingAddressId,
      'paymentMethod': paymentMethod,
      'note': note,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String productId;
  final int quantity;
  final double price;
  final String? productName;
  final String? mainImageUrl;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
    this.mainImageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      productName: json['productName'],
      mainImageUrl: json['mainImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
      if (productName != null) 'productName': productName,
      if (mainImageUrl != null) 'mainImageUrl': mainImageUrl,
    };
  }
}

class CreateOrderRequest {
  final List<OrderItem> items;
  final String shippingAddressId;
  final String paymentMethod;
  final String? note;
  final String? voucherId;

  CreateOrderRequest({
    required this.items,
    required this.shippingAddressId,
    required this.paymentMethod,
    this.note,
    this.voucherId,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddressId': shippingAddressId,
      'paymentMethod': paymentMethod,
      if (note != null && note!.isNotEmpty) 'note': note,
      if (voucherId != null) 'voucherId': voucherId,
    };
  }
}
