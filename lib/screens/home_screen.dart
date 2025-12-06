import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../widgets/product_card.dart';
import '../widgets/category_card.dart';
import '../widgets/search_bar_widget.dart';
import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final categoryService = CategoryService();
      final productService = ProductService();
      
      // Load categories and products in parallel
      final results = await Future.wait([
        categoryService.getCategories(),
        productService.getFeaturedProducts(),
        productService.getNewProducts(),
      ]);
      
      final allCategories = results[0] as List<Category>;
      final topLevelCategories = allCategories.where((c) => c.parentCategoryId == null).toList();
      
      setState(() {
        categories = topLevelCategories;
        featuredProducts = results[1] as List<Product>;
        newProducts = results[2] as List<Product>;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        categories = [];
        featuredProducts = [];
        newProducts = [];
        isLoading = false;
      });
    }
  }

  void _addToCart(Product product) async {
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
      await cartProvider.addToCart(product.productId, 1);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${product.productName} vào giỏ hàng'),
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
        body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppTheme.primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          _buildHeader(),
                          const SizedBox(height: 20),
                          
                          // Search bar
                          SearchBarWidget(
                            readOnly: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Categories
                          _buildSectionTitle('Danh mục', onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(),
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          _buildCategories(),
                          const SizedBox(height: 24),
                          
                          // Featured products
                          _buildSectionTitle('Sản phẩm nổi bật'),
                          const SizedBox(height: 12),
                          _buildFeaturedProducts(),
                          const SizedBox(height: 24),
                          
                          // New products
                          _buildSectionTitle('Sản phẩm mới'),
                          const SizedBox(height: 12),
                          _buildNewProducts(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xin chào! 👋',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'Student Store',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryCard(category: categories[index]);
        },
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredProducts.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: ProductCard(
              product: featuredProducts[index],
              onAddToCart: () => _addToCart(featuredProducts[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewProducts() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: newProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: newProducts[index],
          onAddToCart: () => _addToCart(newProducts[index]),
        );
      },
    );
  }
}
