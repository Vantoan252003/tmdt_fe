import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'auth_service.dart';
import 'api_endpoints.dart';
import '../models/review.dart';
import '../models/api_response.dart';

class ReviewService {
  // Create review with images
  Future<Review> createReview(
    String productId,
    int rating,
    String? comment,
    List<File>? images,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiEndpoints.baseUrl}/reviews/create'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add fields
      request.fields['productId'] = productId;
      request.fields['rating'] = rating.toString();
      if (comment != null && comment.isNotEmpty) {
        request.fields['comment'] = comment;
      }

      // Add images (max 3)
      if (images != null && images.isNotEmpty) {
        final imagesToUpload = images.take(3).toList();
        for (int i = 0; i < imagesToUpload.length; i++) {
          final file = imagesToUpload[i];
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              file.path,
              filename: 'review_image_$i.jpg',
            ),
          );
        }
      }

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        final apiResponse = ApiResponse<Review>.fromJson(
          jsonResponse,
          (data) => Review.fromJson(data),
        );
        if (apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw Exception('No review data in response');
        }
      } else {
        throw Exception('Failed to create review: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }

  // Get product reviews
  Future<List<ReviewResponse>> getProductReviews(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/reviews/product/$productId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<List<ReviewResponse>>.fromJson(
          jsonResponse,
          (data) {
            if (data is List) {
              return data.map((item) => ReviewResponse.fromJson(item as Map<String, dynamic>)).toList();
            } else {
              throw Exception('Expected List but got ${data.runtimeType}');
            }
          },
        );
        return apiResponse.data ?? [];
      } else {
        throw Exception('Failed to get reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting reviews: $e');
    }
  }

  // Get rating stats
  Future<RatingStats> getProductRatingStats(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/reviews/product/$productId/stats'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonResponse,
          (data) => data as Map<String, dynamic>,
        );
        if (apiResponse.data != null) {
          return RatingStats.fromJson(apiResponse.data!);
        } else {
          throw Exception('No stats data in response');
        }
      } else {
        throw Exception('Failed to get stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting stats: $e');
    }
  }

  // Get user reviews
  Future<List<ReviewResponse>> getMyReviews() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/reviews/my-reviews'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<List<ReviewResponse>>.fromJson(
          jsonResponse,
          (data) {
            if (data is List) {
              return data.map((item) => ReviewResponse.fromJson(item as Map<String, dynamic>)).toList();
            } else {
              throw Exception('Expected List but got ${data.runtimeType}');
            }
          },
        );
        return apiResponse.data ?? [];
      } else {
        throw Exception('Failed to get my reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting my reviews: $e');
    }
  }

  // Get reviewable products
  Future<List<Map<String, dynamic>>> getReviewableProducts() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/reviews/reviewable-products'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          if (data is List) {
            return data.map((item) => item as Map<String, dynamic>).toList();
          } else {
            throw Exception('Expected List but got ${data.runtimeType}');
          }
        } else {
          throw Exception('API returned success=false');
        }
      } else {
        throw Exception('Failed to get reviewable products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting reviewable products: $e');
    }
  }

  // Check if user can review product
  Future<Map<String, bool>> canReviewProduct(String productId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/reviews/can-review?productId=$productId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          return Map<String, bool>.from(
            (data as Map).map((key, value) => MapEntry(key as String, value as bool))
          );
        } else {
          throw Exception('API returned success=false');
        }
      } else {
        throw Exception('Failed to check review permission: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking review permission: $e');
    }
  }
}
