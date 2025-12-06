import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../models/cart_item_response.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemResponse> _cartItems = [];
  final CartService _cartService = CartService();
  bool _isLoading = false;

  List<CartItemResponse> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  Future<void> loadCartItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _cartService.getCartItems();
      _cartItems.clear();
      _cartItems.addAll(items);
    } catch (e) {
      debugPrint('Error loading cart items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String productId, int quantity, {String? variantId}) async {
    try {
      await _cartService.addToCart(productId, quantity, variantId: variantId);
      await loadCartItems(); // Reload to get updated data
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);
      _cartItems.removeWhere((item) => item.cartItemId == cartItemId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId);
      } else {
        await _cartService.updateCartItem(cartItemId, quantity);
        final index = _cartItems.indexWhere((item) => item.cartItemId == cartItemId);
        if (index != -1) {
          _cartItems[index] = CartItemResponse(
            cartItemId: _cartItems[index].cartItemId,
            productId: _cartItems[index].productId,
            productName: _cartItems[index].productName,
            variantId: _cartItems[index].variantId,
            quantity: quantity,
            price: _cartItems[index].price,
            subtotal: _cartItems[index].price * quantity,
            mainImageUrl: _cartItems[index].mainImageUrl,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating cart item: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _cartItems.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }
}
