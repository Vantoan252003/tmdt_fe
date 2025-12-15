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

  // ---------------- SEARCH LOGIC ----------------
  void _performSearch(String query) async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    if (query.isEmpty) {
      productProvider.clearSearchResults();
      return;
    }

    await productProvider.searchProducts(
      keyword: query,
      categoryId: _selectedCategoryId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );
  }

  void _addToCart(Product product) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đang thêm vào giỏ hàng..."),
          backgroundColor: AppTheme.primaryColor,
          duration: Duration(seconds: 1),
        ),
      );

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.addToCart(product.productId, 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã thêm ${product.productName} vào giỏ hàng"),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${e.toString()}"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  // ---------------- BUILD UI ----------------
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildSearchBarRow(),
                      const SizedBox(height: 12),
                      if (_hasFilters()) _buildActiveFilters(),
                      const SizedBox(height: 12),
                      Expanded(child: _buildResults()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER SHOPEE STYLE ----------------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          const Text(
            "Tìm kiếm sản phẩm",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SEARCH BAR + FILTER BUTTON ----------------
  Widget _buildSearchBarRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: _performSearch,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _showFilterDialog,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.filter_list, color: Colors.white, size: 26),
          ),
        ),
      ],
    );
  }

  // ---------------- RESULTS ----------------
  Widget _buildResults() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isSearching) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              "Lỗi: ${provider.error}",
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          );
        }

        if (_searchController.text.isEmpty) {
          return _buildSuggestions();
        }

        final results = provider.searchResults;
        if (results.isEmpty) return _buildNoResults();

        return GridView.builder(
          padding: const EdgeInsets.only(top: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: results.length,
          itemBuilder: (context, i) {
            return ProductCard(
              product: results[i],
              onAddToCart: () => _addToCart(results[i]),
            );
          },
        );
      },
    );
  }

  // ---------------- SEARCH SUGGESTIONS ----------------
  Widget _buildSuggestions() {
    final suggestions = [
      "🖊️ Bút viết",
      "🎒 Ba lô",
      "📒 Vở học sinh",
      "📐 Thước kẻ",
      "📚 Sách giáo khoa",
      "✂️ Dụng cụ học tập",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gợi ý tìm kiếm",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: suggestions.map((s) {
            return GestureDetector(
              onTap: () {
                _searchController.text = s.substring(2).trim();
                _performSearch(_searchController.text);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  s,
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

  // ---------------- NO RESULTS ----------------
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off,
              size: 80, color: AppTheme.textLight),
          const SizedBox(height: 16),
          const Text(
            "Không tìm thấy kết quả",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Hãy thử từ khóa khác",
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // ---------------- ACTIVE FILTER BADGE ----------------
  bool _hasFilters() =>
      _selectedCategoryId != null || _minPrice != null || _maxPrice != null;

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _filterText(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: _clearFilters,
            child: const Icon(Icons.close,
                color: AppTheme.primaryColor, size: 16),
          ),
        ],
      ),
    );
  }

  String _filterText() {
    final list = <String>[];
    if (_selectedCategoryId != null) list.add("Danh mục");
    if (_minPrice != null || _maxPrice != null) {
      list.add("Giá: ${_minPrice ?? 0} - ${_maxPrice ?? "∞"}");
    }
    return list.join(", ");
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

  // ---------------- FILTER DIALOG ----------------
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bộ lọc tìm kiếm"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Danh mục: chưa triển khai"),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _minPrice?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Giá từ",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        _minPrice = v.isEmpty ? null : double.tryParse(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _maxPrice?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Giá đến",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        _maxPrice = v.isEmpty ? null : double.tryParse(v),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_searchController.text.isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
            child: const Text("Áp dụng"),
          ),
        ],
      ),
    );
  }
}
