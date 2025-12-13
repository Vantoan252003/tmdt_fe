import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/voucher.dart';
import '../models/api_response.dart';
import 'api_endpoints.dart';
import 'auth_service.dart';

class VoucherService {
  

  // Get available vouchers for a shop
  Future<List<Voucher>> getAvailableVouchers(String shopId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.availableVouchers(shopId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          jsonResponse,
          (data) => data as List<dynamic>,
        );
        
        if (apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => Voucher.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load vouchers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading vouchers: $e');
      return [];
    }
  }
}
