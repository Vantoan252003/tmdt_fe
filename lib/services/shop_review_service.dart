import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'auth_service.dart';
import '../models/shop_review.dart';
import '../models/api_response.dart';

class ShopReviewService {
  // Check if user can review shop
  Future<CanReviewShopResponse?> canReviewShop(String shopId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.canReviewShop(shopId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return CanReviewShopResponse.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to check review status');
        }
      } else {
        throw Exception('Failed to check review status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking review status: $e');
    }
  }

  // Create shop review
  Future<ShopReview?> createShopReview(String shopId, CreateShopReviewRequest request) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.createShopReview(shopId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return ShopReview.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to create review');
        }
      } else {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to create review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }

  // Get all shop reviews
  Future<List<ShopReview>> getShopReviews(String shopId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.shopReviews(shopId)),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          if (data is List) {
            return data.map((review) => ShopReview.fromJson(review)).toList();
          } else {
            return [];
          }
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to get reviews');
        }
      } else {
        throw Exception('Failed to get reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting reviews: $e');
    }
  }
}
