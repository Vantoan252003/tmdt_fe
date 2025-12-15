import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_response.dart';
import '../providers/navigation_provider.dart';
import 'checkout_screen.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.loadCartItems();
  }

  Future<void> _updateQuantity(CartItemResponse item, int newQuantity) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    try {
      await cartProvider.updateQuantity(item.cartItemId, newQuantity);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cập nhật số lượng thành công'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: const Color(0xFFEE4D2D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _removeItem(CartItemResponse item) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    try {
      await cartProvider.removeFromCart(item.cartItemId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa sản phẩm khỏi giỏ hàng'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: const Color(0xFFEE4D2D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _clearCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    try {
      await cartProvider.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa tất cả sản phẩm khỏi giỏ hàng'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: const Color(0xFFEE4D2D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _navigateToCheckout(BuildContext context, CartProvider cartProvider) async {
    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Giỏ hàng trống'),
          backgroundColor: const Color(0xFFEE4D2D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    await cartProvider.loadCartItems();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: cartProvider.cartItems,
          totalAmount: cartProvider.totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Giỏ Hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEE4D2D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.cartItems.isNotEmpty) {
                return TextButton.icon(
                  onPressed: () => _showClearCartDialog(context),
                  icon: const Icon(
                    Icons.delete_sweep,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Xóa tất cả',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFEE4D2D),
              ),
            );
          }

          if (cartProvider.cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return RefreshIndicator(
            onRefresh: _loadCartItems,
            color: const Color(0xFFEE4D2D),
            child: Column(
              children: [
                // Header info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: Color(0xFFEE4D2D), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Student Store',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEE4D2D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${cartProvider.cartItems.length} sản phẩm',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFEE4D2D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: cartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(context, cartProvider.cartItems[index]);
                    },
                  ),
                ),
                _buildBottomBar(context, cartProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEE4D2D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Color(0xFFEE4D2D),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng của bạn',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                navProvider.setIndex(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE4D2D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mua sắm ngay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItemResponse item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 8, right: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEE4D2D), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.check,
                size: 14,
                color: Color(0xFFEE4D2D),
              ),
            ),
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: item.mainImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        item.mainImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 32,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₫${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEE4D2D),
                        ),
                      ),
                      const Spacer(),
                      // Quantity controls
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: item.quantity > 1
                                  ? () => _updateQuantity(item, item.quantity - 1)
                                  : null,
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: item.quantity > 1 ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _updateQuantity(item, item.quantity + 1),
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showRemoveItemDialog(context, item),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox all
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEE4D2D), width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Color(0xFFEE4D2D),
                ),
              ),
              const Text(
                'Tất cả',
                style: TextStyle(fontSize: 14),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tổng thanh toán:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₫${cartProvider.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFEE4D2D),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _navigateToCheckout(context, cartProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE4D2D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Mua hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, CartItemResponse item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Xóa sản phẩm',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Bạn có chắc muốn xóa "${item.productName}" khỏi giỏ hàng?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeItem(item);
              },
              child: const Text(
                'Xóa',
                style: TextStyle(
                  color: Color(0xFFEE4D2D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Xóa tất cả',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm khỏi giỏ hàng?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCart();
              },
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(
                  color: Color(0xFFEE4D2D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}