import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'api_endpoints.dart';

class ProductService {
  // Get all products
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.products),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> productsJson = data['data'];
          return productsJson.map((json) => Product.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }

  // Get featured products (top 5 by rating)
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final products = await getProducts();
      // Sort by rating and take top 5
      products.sort((a, b) => b.rating.compareTo(a.rating));
      return products.take(5).toList();
    } catch (e) {
      print('Error loading featured products: $e');
      return [];
    }
  }

  // Get new products (top 5 by created date)
  Future<List<Product>> getNewProducts() async {
    try {
      final products = await getProducts();
      // Sort by createdAt (newest first) and take top 5
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products.take(5).toList();
    } catch (e) {
      print('Error loading new products: $e');
      return [];
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.productDetail(id)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return Product.fromJson(data['data']);
        }
        return null;
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading product: $e');
      return null;
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.searchProducts}?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> productsJson = data['data'];
          return productsJson.map((json) => Product.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.productsByCategory(categoryId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> productsJson = data['data'];
          return productsJson.map((json) => Product.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load category products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading category products: $e');
      return [];
    }
  }
}
