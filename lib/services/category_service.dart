import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import 'api_endpoints.dart';

class CategoryService {
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.categories));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final categoriesJson = data['data'] as List;
          return categoriesJson.map((json) => Category.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load categories');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}