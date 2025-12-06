import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _newProducts = [];
  List<Product> _categoryProducts = [];
  List<Product> _searchResults = [];
  bool _isLoading = false;
  bool _isLoadingFeatured = false;
  bool _isLoadingNew = false;
  bool _isLoadingCategory = false;
  bool _isSearching = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get newProducts => _newProducts;
  List<Product> get categoryProducts => _categoryProducts;
  List<Product> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingNew => _isLoadingNew;
  bool get isLoadingCategory => _isLoadingCategory;
  bool get isSearching => _isSearching;
  String? get error => _error;

  // Load all products
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.getProducts();
    } catch (e) {
      _error = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load featured products
  Future<void> loadFeaturedProducts() async {
    _isLoadingFeatured = true;
    notifyListeners();

    try {
      _featuredProducts = await _productService.getFeaturedProducts();
    } catch (e) {
      _featuredProducts = [];
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  // Load new products
  Future<void> loadNewProducts() async {
    _isLoadingNew = true;
    notifyListeners();

    try {
      _newProducts = await _productService.getNewProducts();
    } catch (e) {
      _newProducts = [];
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
  }

  // Load products by category
  Future<void> loadProductsByCategory(String categoryId, {bool includeSubcategories = false}) async {
    _isLoadingCategory = true;
    _error = null;
    notifyListeners();

    try {
      _categoryProducts = await _productService.getProductsByCategory(
        categoryId,
        includeSubcategories: includeSubcategories,
      );
    } catch (e) {
      _error = e.toString();
      _categoryProducts = [];
    } finally {
      _isLoadingCategory = false;
      notifyListeners();
    }
  }

  // Search products
  Future<void> searchProducts({
    required String keyword,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    int? page,
    int? size,
  }) async {
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _productService.searchProductsAdvanced(
        keyword: keyword,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: page,
        size: size,
      );
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      return await _productService.getProductById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // Clear category products
  void clearCategoryProducts() {
    _categoryProducts = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}