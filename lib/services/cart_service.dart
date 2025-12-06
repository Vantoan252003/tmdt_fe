import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_endpoints.dart';

class AddToCartRequest {
  final String productId;
  final String? variantId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    this.variantId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'variantId': variantId,
      'quantity': quantity,
    };
  }
}

class CartItemResponse {
  final String cartItemId;
  final String productId;
  final String productName;
  final String? variantId;
  final String? variantName;
  final int quantity;
  final double price;
  final double totalPrice;
  final String? imageUrl;

  CartItemResponse({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    this.variantId,
    this.variantName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.imageUrl,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      cartItemId: json['cartItemId'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      variantId: json['variantId'],
      variantName: json['variantName'],
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
    );
  }
}

class CartService {
  // Add to cart via API
  Future<CartItemResponse?> addToCart(String productId, int quantity, {String? variantId}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final request = AddToCartRequest(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );

      final response = await http.post(
        Uri.parse(ApiEndpoints.addToCart),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(
          data,
          (json) => CartItemResponse.fromJson(json),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data;
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get cart items
  Future<List<CartItemResponse>> getCartItems() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.cart),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(
          data,
          (json) => (json as List).map((item) => CartItemResponse.fromJson(item)).toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to get cart items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  // Update cart item
  Future<CartItemResponse?> updateCartItem(String itemId, int quantity) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse(ApiEndpoints.updateCartItem(itemId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(
          data,
          (json) => CartItemResponse.fromJson(json),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data;
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('Failed to update cart item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating cart item: $e');
      rethrow;
    }
  }

  // Remove from cart
  Future<bool> removeFromCart(String itemId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse(ApiEndpoints.removeFromCart(itemId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(data, (json) => json);

        return apiResponse.success;
      } else {
        throw Exception('Failed to remove from cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse(ApiEndpoints.clearCart),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(data, (json) => json);

        return apiResponse.success;
      } else {
        throw Exception('Failed to clear cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }
}