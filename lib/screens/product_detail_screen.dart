import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../widgets/gradient_button.dart';
import '../widgets/review_list_widget.dart';
import '../widgets/add_review_dialog.dart';
import '../providers/cart_provider.dart';
import '../services/review_service.dart';
import '../services/product_service.dart';
import 'shop_detail_screen.dart';
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

  final ReviewService _reviewService = ReviewService();
  List<ReviewResponse> _reviews = [];
  RatingStats? _ratingStats;
  bool _isLoadingReviews = false;

  final ScrollController _scrollController = ScrollController();

  final ProductService _productService = ProductService();
  Product? _detailedProduct;
  bool _isLoadingProduct = false;

  Product get _currentProduct => _detailedProduct ?? widget.product;

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
    _loadReviews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail() async {
    setState(() => _isLoadingProduct = true);

    try {
      final p = await _productService.getProductById(widget.product.productId);
      if (mounted && p != null) {
        setState(() {
          _detailedProduct = p;
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingProduct = false);
    }
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);

    try {
      final reviews =
          await _reviewService.getProductReviews(_currentProduct.productId);

      final stats =
          await _reviewService.getProductRatingStats(_currentProduct.productId);

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _ratingStats = stats;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingReviews = false);
    }
  }

  void _scrollToReviews() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        productId: _currentProduct.productId,
        onReviewSubmitted: _loadReviews,
      ),
    );
  }

  void _addToCart() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đang thêm vào giỏ hàng..."),
          backgroundColor: Color(0xFFEE4D2D),
        ),
      );

      final cart = Provider.of<CartProvider>(context, listen: false);
      await cart.addToCart(_currentProduct.productId, quantity);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã thêm ${_currentProduct.name} vào giỏ hàng"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFEE4D2D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Chi tiết sản phẩm",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.favorite_border, color: Colors.white),
          )
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(),
                  const SizedBox(height: 10),
                  _buildProductInfo(),
                  _buildPriceSection(),
                  _buildQuantitySelector(),
                  _buildDescription(),
                  _buildShopSection(),
                  _buildReviewSection(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ---------------- IMAGE CAROUSEL ----------------
  Widget _buildImageCarousel() {
    final images = _currentProduct.images.isNotEmpty
        ? _currentProduct.images
        : [_currentProduct.imageUrl];

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => selectedImageIndex = i),
            itemBuilder: (_, i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: images[i],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFEE4D2D)),
                    ),
                    errorWidget: (_, __, ___) => const Icon(Icons.image,
                        size: 80, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: selectedImageIndex == i ? 20 : 6,
              decoration: BoxDecoration(
                color: selectedImageIndex == i
                    ? const Color(0xFFEE4D2D)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  // ---------------- PRODUCT BASIC INFO ----------------
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentProduct.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFC400), size: 18),
              const SizedBox(width: 4),
              Text(
                "${_currentProduct.rating}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 6),
              Text(
                "(${_currentProduct.reviewCount} đánh giá)",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const Spacer(),
              Text(
                "Còn ${_currentProduct.stock}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }

  // ---------------- PRICE ----------------
  Widget _buildPriceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const Text(
            "Giá:",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(width: 10),
          Text(
            "${_currentProduct.price.toStringAsFixed(0)}đ",
            style: const TextStyle(
              fontSize: 28,
              color: Color(0xFFEE4D2D),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- QUANTITY ----------------
  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            'Số lượng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),

          // Minus
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              onPressed: () {
                if (quantity > 1) {
                  setState(() => quantity--);
                }
              },
              icon: const Icon(Icons.remove, color: Colors.black87),
            ),
          ),

          Container(
            width: 50,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Plus
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7043), Color(0xFFEE4D2D)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              onPressed: () {
                if (quantity < _currentProduct.stock) {
                  setState(() => quantity++);
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- DESCRIPTION ----------------
  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mô tả sản phẩm",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _currentProduct.description,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ---------------- SHOP SECTION ----------------
  Widget _buildShopSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShopDetailScreen(
              shopId: _currentProduct.shopId,
              shopName: _currentProduct.shopName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Thông tin cửa hàng",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey)
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: _currentProduct.shopLogoUrl != null &&
                          _currentProduct.shopLogoUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                              imageUrl: _currentProduct.shopLogoUrl!,
                              fit: BoxFit.cover),
                        )
                      : const Icon(Icons.store,
                          size: 35, color: Colors.white),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentProduct.shopName ?? "Cửa hàng",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (_currentProduct.shopRating != null)
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Color(0xFFFFC400)),
                            const SizedBox(width: 4),
                            Text(
                              _currentProduct.shopRating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (_currentProduct.shopDescription != null)
              Text(
                _currentProduct.shopDescription!,
                style:
                    const TextStyle(fontSize: 14, color: Colors.black87),
              ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildShopStat(
                    "${_currentProduct.totalProducts}",
                    "Sản phẩm",
                    Icons.inventory,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildShopStat(
                    "${_currentProduct.totalOrders}",
                    "Đơn hàng",
                    Icons.shopping_bag,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFEE4D2D), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  // ---------------- REVIEW SECTION ----------------
  Widget _buildReviewSection() {
    return ReviewListWidget(
      reviews: _reviews,
      ratingStats: _ratingStats,
      isLoading: _isLoadingReviews,
    );
  }

  // ---------------- BOTTOM BAR ----------------
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _scrollToReviews,
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text("Xem đánh giá"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[100],
                      foregroundColor: Colors.orange[800],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddReviewDialog,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Viết đánh giá"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE4D2D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            GradientButton(
              text: "Thêm vào giỏ hàng",
              icon: Icons.shopping_cart,
              onPressed: _addToCart,
            ),
          ],
        ),
      ),
    );
  }
}
