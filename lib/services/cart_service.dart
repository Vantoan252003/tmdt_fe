import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_endpoints.dart';
import '../models/cart_item_response.dart';
import '../models/api_response.dart';

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
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<CartItemResponse>.fromJson(
          jsonResponse,
          (data) => CartItemResponse.fromJson(data),
        );
        return apiResponse.data;
      } else {
        throw Exception('Failed to add item to cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  // Get cart items via API
  Future<List<CartItemResponse>> getCartItems() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.cart),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          if (data is List) {
            return data.map((item) => CartItemResponse.fromJson(item)).toList();
          } else {
            return [];
          }
        } else {
          throw Exception('API returned success=false: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to get cart items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting cart items: $e');
    }
  }

  // Update cart item quantity via API
  Future<CartItemResponse?> updateCartItem(String cartItemId, int quantity) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('${ApiEndpoints.updateCartItem(cartItemId)}?quantity=$quantity'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<CartItemResponse>.fromJson(
          jsonResponse,
          (data) => CartItemResponse.fromJson(data),
        );
        return apiResponse.data;
      } else {
        throw Exception('Failed to update cart item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating cart item: $e');
    }
  }

  // Remove item from cart via API
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse(ApiEndpoints.removeFromCart(cartItemId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove item from cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }

  // Clear cart via API
  Future<void> clearCart() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse(ApiEndpoints.clearCart),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to clear cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }
}