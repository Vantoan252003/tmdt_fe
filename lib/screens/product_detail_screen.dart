import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import '../models/product.dart';
import '../widgets/gradient_button.dart';
import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  int selectedImageIndex = 0;

  void _addToCart() async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang thêm vào giỏ hàng...'),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Add to cart using CartProvider
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.addToCart(widget.product.productId, quantity);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${widget.product.productName} vào giỏ hàng'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể thêm vào giỏ hàng: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product images
                    _buildImageCarousel(),
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.product.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Product name
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Rating and reviews
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppTheme.ratingColor,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.product.rating}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${widget.product.reviewCount} đánh giá)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Còn ${widget.product.stock} sản phẩm',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Price
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Giá:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${widget.product.price.toStringAsFixed(0)}đ',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Quantity selector
                          _buildQuantitySelector(),
                          const SizedBox(height: 20),
                          
                          // Description
                          const Text(
                            'Mô tả sản phẩm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.product.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom button
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.product.images.isNotEmpty 
        ? widget.product.images 
        : [widget.product.imageUrl];
        
    return Column(
      children: [
        Container(
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.secondaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: images[selectedImageIndex].isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: images[selectedImageIndex],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.image,
                    size: 80,
                    color: AppTheme.textLight,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final isSelected = index == selectedImageIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedImageIndex = index;
                  });
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? AppTheme.primaryGradient 
                        : AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: images[index].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image_not_supported,
                              size: 24,
                              color: AppTheme.textLight,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.image,
                          size: 24,
                          color: AppTheme.textLight,
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Số lượng:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                if (quantity > 1) {
                  setState(() {
                    quantity--;
                  });
                }
              },
              icon: const Icon(
                Icons.remove,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            width: 60,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                if (quantity < widget.product.stock) {
                  setState(() {
                    quantity++;
                  });
                }
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: GradientButton(
          text: 'Thêm vào giỏ hàng',
          icon: Icons.shopping_cart,
          onPressed: _addToCart,
        ),
      ),
    );
  }
}
