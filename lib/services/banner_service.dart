import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/banner.dart';
import '../models/api_response.dart';
import 'api_endpoints.dart';

class BannerService {
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.banners),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<BannerModel>>.fromJson(
          json.decode(response.body),
          (data) => (data as List<dynamic>)
              .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .where((banner) => banner.isActive) // Only active banners
              .toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)); // Sort by display order
        } else {
          throw Exception(apiResponse.message ?? 'Failed to load banners');
        }
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading banners: $e');
    }
  }
}