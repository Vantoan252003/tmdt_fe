import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'package:provider/provider.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Category category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  String sortBy = 'default';
  bool includeSubcategories = false;

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadProductsByCategory(
      widget.category.categoryId,
      includeSubcategories: includeSubcategories,
    );
  }

  void _sortProducts(List<Product> products) {
    switch (sortBy) {
      case 'price_asc':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        products.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'bestseller':
        products.sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));
        break;
      default:
        break;
    }
  }

  void _addToCart(Product product) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.addToCart(product.productId, 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${product.productName} vào giỏ hàng'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể thêm vào giỏ hàng: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFFEE4D2D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  String _getSortText() {
    switch (sortBy) {
      case 'price_asc':
        return 'Giá Thấp - Cao';
      case 'price_desc':
        return 'Giá Cao - Thấp';
      case 'rating':
        return 'Đánh Giá';
      case 'bestseller':
        return 'Bán Chạy';
      case 'name':
        return 'Tên A-Z';
      default:
        return 'Phổ Biến';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEE4D2D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.category.categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to search
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              // Navigate to cart
            },
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoadingCategory) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFEE4D2D),
              ),
            );
          }

          if (productProvider.error != null) {
            return Center(
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
                    'Lỗi: ${productProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCategoryProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE4D2D),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final products = List<Product>.from(productProvider.categoryProducts);
          _sortProducts(products);

          if (products.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Filter bar (Shopee style)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip('Phổ Biến', 'default'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Bán Chạy', 'bestseller'),
                    const SizedBox(width: 8),
                    _buildSortButton(),
                    const Spacer(),
                    _buildViewToggle(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Product count
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  '${products.length} sản phẩm',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Products grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadCategoryProducts,
                  color: const Color(0xFFEE4D2D),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: products[index],
                        onAddToCart: () => _addToCart(products[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = sortBy == value;
    return InkWell(
      onTap: () {
        setState(() {
          sortBy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEE4D2D) : Colors.white,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isSelected ? const Color(0xFFEE4D2D) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return InkWell(
      onTap: _showSortOptions,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getSortText(),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Icon(
        Icons.filter_list,
        size: 20,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.inventory_2_outlined,
              size: 60,
              color: Color(0xFFEE4D2D),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có sản phẩm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Danh mục này hiện chưa có sản phẩm nào',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE4D2D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Khám phá danh mục khác'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Sắp xếp theo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              _buildSortOption('Phổ Biến', 'default', Icons.trending_up),
              _buildSortOption('Bán Chạy', 'bestseller', Icons.local_fire_department),
              _buildSortOption('Giá Thấp - Cao', 'price_asc', Icons.arrow_upward),
              _buildSortOption('Giá Cao - Thấp', 'price_desc', Icons.arrow_downward),
              _buildSortOption('Đánh Giá', 'rating', Icons.star),
              _buildSortOption('Tên A-Z', 'name', Icons.sort_by_alpha),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, String value, IconData icon) {
    final isSelected = sortBy == value;
    return InkWell(
      onTap: () {
        setState(() {
          sortBy = value;
        });
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: isSelected
            ? const Color(0xFFEE4D2D).withOpacity(0.05)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFFEE4D2D)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected
                      ? const Color(0xFFEE4D2D)
                      : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFEE4D2D),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}