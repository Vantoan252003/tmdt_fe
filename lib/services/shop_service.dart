import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shop.dart';
import '../models/api_response.dart';
import 'api_endpoints.dart';

class ShopService {
  // Get shop details with products
  Future<Shop?> getShopDetails(String shopId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.shopDetails(shopId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>,
        );
        
        if (apiResponse.data != null) {
          return Shop.fromJson(apiResponse.data!);
        }
        return null;
      } else {
        throw Exception('Failed to load shop details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading shop details: $e');
      return null;
    }
  }
}
