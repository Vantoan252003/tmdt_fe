import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../widgets/category_card.dart';
import '../utils/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> categories = [];
  bool isLoading = true;
  String? error;

  // Category icons and colors (matching home screen)
  final List<CategoryStyle> categoryStyles = [
    CategoryStyle(icon: Icons.phone_android, color: Color(0xFFFF6B35), gradient: [Color(0xFFFF6B35), Color(0xFFFF8C42)]),
    CategoryStyle(icon: Icons.laptop, color: Color(0xFF4ECDC4), gradient: [Color(0xFF4ECDC4), Color(0xFF44A08D)]),
    CategoryStyle(icon: Icons.watch, color: Color(0xFFFFBE0B), gradient: [Color(0xFFFFBE0B), Color(0xFFFFA500)]),
    CategoryStyle(icon: Icons.headphones, color: Color(0xFF9B5DE5), gradient: [Color(0xFF9B5DE5), Color(0xFF7B3FF2)]),
    CategoryStyle(icon: Icons.camera_alt, color: Color(0xFFFF006E), gradient: [Color(0xFFFF006E), Color(0xFFD90062)]),
    CategoryStyle(icon: Icons.sports_esports, color: Color(0xFF06FFA5), gradient: [Color(0xFF06FFA5), Color(0xFF00D9A5)]),
    CategoryStyle(icon: Icons.checkroom, color: Color(0xFFFF6B6B), gradient: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)]),
    CategoryStyle(icon: Icons.menu_book, color: Color(0xFF4D96FF), gradient: [Color(0xFF4D96FF), Color(0xFF3B7DD9)]),
    CategoryStyle(icon: Icons.sports_soccer, color: Color(0xFF00B4D8), gradient: [Color(0xFF00B4D8), Color(0xFF0096C7)]),
    CategoryStyle(icon: Icons.home_outlined, color: Color(0xFFFF9F1C), gradient: [Color(0xFFFF9F1C), Color(0xFFE88D0F)]),
    CategoryStyle(icon: Icons.favorite_border, color: Color(0xFFE63946), gradient: [Color(0xFFE63946), Color(0xFFD62828)]),
    CategoryStyle(icon: Icons.local_dining, color: Color(0xFF06D6A0), gradient: [Color(0xFF06D6A0), Color(0xFF00B4A0)]),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categoryService = CategoryService();
      final fetchedCategories = await categoryService.getCategories();
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Danh Mục',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEE4D2D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Navigate to search
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFEE4D2D),
              ),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi: $error',
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCategories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEE4D2D),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCategories,
                  color: const Color(0xFFEE4D2D),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFEE4D2D), Color(0xFFFF6347)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Khám phá danh mục',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${categories.length} danh mục sản phẩm',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Categories grid
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final style = categoryStyles[index % categoryStyles.length];
                              return _buildCategoryCard(category, style);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCategoryCard(Category category, CategoryStyle style) {
    return GestureDetector(
      onTap: () {
        // Navigate to category products
        // Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: category)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: style.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: style.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                style.icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.categoryName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryStyle {
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  CategoryStyle({
    required this.icon,
    required this.color,
    required this.gradient,
  });
}