import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

import '../utils/app_theme.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';
import '../providers/cart_provider.dart';
import 'search_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> featuredProducts = [];
  List<Product> newProducts = [];
  List<Category> categories = [];

  bool isLoading = true;

  Duration flashSaleDuration = const Duration(hours: 2, minutes: 30, seconds: 45);
  int _currentBanner = 0;

  Timer? _flashSaleTimer;

  final List<String> bannerImages = [
    "https://images.unsplash.com/photo-1607082350899-7e105aa886ae?auto=format&fit=crop&w=1200",
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200",
    "https://images.unsplash.com/photo-1585386959984-a4155224a1ad?auto=format&fit=crop&w=1200",
  ];

  // Category icons and colors (Shopee style)
  final List<CategoryStyle> categoryStyles = [
    CategoryStyle(icon: Icons.phone_android, color: Color(0xFFFF6B35)),
    CategoryStyle(icon: Icons.laptop, color: Color(0xFF4ECDC4)),
    CategoryStyle(icon: Icons.watch, color: Color(0xFFFFBE0B)),
    CategoryStyle(icon: Icons.headphones, color: Color(0xFF9B5DE5)),
    CategoryStyle(icon: Icons.camera_alt, color: Color(0xFFFF006E)),
    CategoryStyle(icon: Icons.sports_esports, color: Color(0xFF06FFA5)),
    CategoryStyle(icon: Icons.checkroom, color: Color(0xFFFF6B6B)),
    CategoryStyle(icon: Icons.menu_book, color: Color(0xFF4D96FF)),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();

    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (flashSaleDuration.inSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() {
          flashSaleDuration -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _flashSaleTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final categoryService = CategoryService();
      final productService = ProductService();

      final results = await Future.wait([
        categoryService.getCategories(),
        productService.getFeaturedProducts(),
        productService.getNewProducts(),
      ]);

      final allCategories = results[0] as List<Category>;

      if (!mounted) return;
      setState(() {
        categories =
            allCategories.where((c) => c.parentCategoryId == null).toList();
        featuredProducts = results[1] as List<Product>;
        newProducts = results[2] as List<Product>;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _addToCart(Product product) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.addToCart(product.productId, 1);
  }

  // Helper method to safely get image URL
  String _getProductImage(Product product) {
    try {
      if (product.images.isNotEmpty) {
        return product.images[0];
      }
    } catch (e) {
      return '';
    }
    return product.mainImageUrl ?? product.imageUrl ?? '';
  }

  // ======================= BUILD =======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFEE4D2D)))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFFEE4D2D),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildBanner(),
                      const SizedBox(height: 2),
                      _buildContent(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ======================= HEADER =======================

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEE4D2D), Color(0xFFFF6347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 12),
                          Icon(Icons.search, color: Color(0xFFEE4D2D), size: 22),
                          SizedBox(width: 8),
                          Text(
                            "Tìm kiếm sản phẩm...",
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================= BANNER =======================

  Widget _buildBanner() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          CarouselSlider(
            items: bannerImages.map((url) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 160,
              viewportFraction: 0.92,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              onPageChanged: (i, _) => setState(() => _currentBanner = i),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: bannerImages.asMap().entries.map((entry) {
              return Container(
                width: _currentBanner == entry.key ? 20 : 8,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: _currentBanner == entry.key
                      ? const Color(0xFFEE4D2D)
                      : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ======================= CONTENT =======================

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildCategories(),
        const SizedBox(height: 8),
        _buildFlashSaleSection(),
        const SizedBox(height: 8),
        _buildNewProductsSection(),
        const SizedBox(height: 16),
      ],
    );
  }

  // ======================= CATEGORY =======================

  Widget _buildCategories() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: categories.length > 8 ? 8 : categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 0,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, i) {
              final c = categories[i];
              final style = categoryStyles[i % categoryStyles.length];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: style.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(style.icon, color: style.color, size: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.categoryName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, height: 1.2),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ======================= FLASH SALE =======================

  Widget _buildFlashSaleSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFEE4D2D)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Text(
                  "FLASH SALE",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                _countdown(),
              ],
            ),
          ),
          Container(
            height: 240,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: featuredProducts.length,
              itemBuilder: (_, i) {
                final p = featuredProducts[i];
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 8),
                  child: _buildFlashSaleCard(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleCard(Product product) {
    final imageUrl = _getProductImage(product);
    
    return GestureDetector(
      onTap: () => _addToCart(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: const Text(
                      "-30%",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEE4D2D),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "₫${product.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEE4D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEE4D2D),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      "ĐANG BÁN CHẠY",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countdown() {
    String f(int n) => n.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _timeBox(f(flashSaleDuration.inHours)),
          const Text(" : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          _timeBox(f(flashSaleDuration.inMinutes.remainder(60))),
          const Text(" : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          _timeBox(f(flashSaleDuration.inSeconds.remainder(60))),
        ],
      ),
    );
  }

  Widget _timeBox(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        t,
        style: const TextStyle(
          color: Color(0xFFEE4D2D),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  // ======================= NEW PRODUCTS =======================

  Widget _buildNewProductsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFEE4D2D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "GỢI Ý HÔM NAY",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEE4D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: newProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, i) {
              final p = newProducts[i];
              return ProductCard(
                product: p,
                onAddToCart: () => _addToCart(p),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CategoryStyle {
  final IconData icon;
  final Color color;

  CategoryStyle({required this.icon, required this.color});
} 