import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.clearSearchResults();
      return;
    }

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.searchProducts(
      keyword: query,
      categoryId: _selectedCategoryId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );
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
          title: const Text(
            'Tìm kiếm',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar and filters
              Row(
                children: [
                  Expanded(
                    child: SearchBarWidget(
                      controller: _searchController,
                      onChanged: _performSearch,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _showFilterDialog,
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Active filters
              if (_selectedCategoryId != null || _minPrice != null || _maxPrice != null)
                _buildActiveFilters(),

              const SizedBox(height: 16),

              // Results
              Expanded(
                child: _buildResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isSearching) {
          return const Center(
            child: CircularProgressIndicator(),
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
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${productProvider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
              ],
            ),
          );
        }

        final searchResults = productProvider.searchResults;

        if (_searchController.text.isEmpty) {
          return _buildSuggestions();
        }

        if (searchResults.isEmpty) {
          return _buildNoResults();
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            return ProductCard(
              product: searchResults[index],
              onAddToCart: () => _addToCart(searchResults[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      '🖊️ Bút viết',
      '📓 Vở',
      '🎒 Ba lô',
      '📐 Thước kẻ',
      '🔢 Máy tính',
      '📚 Sách',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gợi ý tìm kiếm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                _searchController.text = suggestion.substring(2).trim();
                _performSearch(_searchController.text);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 80,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Không tìm thấy kết quả',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hãy thử từ khóa khác',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_list,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getActiveFiltersText(),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: _clearFilters,
            icon: const Icon(
              Icons.clear,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _getActiveFiltersText() {
    final filters = <String>[];
    if (_selectedCategoryId != null) filters.add('Danh mục');
    if (_minPrice != null || _maxPrice != null) {
      final priceText = '${_minPrice ?? 0} - ${_maxPrice ?? '∞'}';
      filters.add('Giá: $priceText');
    }
    return filters.join(', ');
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _minPrice = null;
      _maxPrice = null;
    });
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bộ lọc tìm kiếm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category filter (simplified - you can expand this)
            const Text('Danh mục: Chưa triển khai'),

            const SizedBox(height: 16),

            // Price range
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _minPrice?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Giá từ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _minPrice = value.isEmpty ? null : double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _maxPrice?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Giá đến',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxPrice = value.isEmpty ? null : double.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_searchController.text.isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }
}
