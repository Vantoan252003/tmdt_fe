import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/banner_widget.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/banner.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../services/banner_service.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import 'search_screen.dart';
import 'categories_screen.dart';
import 'conversation_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> featuredProducts = [];
  List<Product> newProducts = [];
  List<Category> categories = [];
  List<BannerModel> banners = [];

  bool isLoading = true;

  Duration flashSaleDuration = const Duration(hours: 2, minutes: 30, seconds: 45);

  Timer? _flashSaleTimer;

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
      final bannerService = BannerService();

      final results = await Future.wait([
        categoryService.getCategories(),
        productService.getFeaturedProducts(),
        productService.getNewProducts(),
        bannerService.getBanners(),
      ]);

      final allCategories = results[0] as List<Category>;

      if (!mounted) return;
      setState(() {
        categories =
            allCategories.where((c) => c.parentCategoryId == null).toList();
        featuredProducts = results[1] as List<Product>;
        newProducts = results[2] as List<Product>;
        banners = results[3] as List<BannerModel>;
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
                      child: const Row(
                        children:  [
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
               
                const SizedBox(width: 8),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConversationListScreen()),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                  ),
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
    return BannerWidget(
      banners: banners,
      isLoading: isLoading,
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