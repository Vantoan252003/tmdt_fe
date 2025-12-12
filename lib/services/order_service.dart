import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_endpoints.dart';
import '../models/order.dart';
import '../models/order_response.dart';
import '../models/api_response.dart';

class OrderService {
  // Create order
  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      print('Creating order with data: ${jsonEncode(request.toJson())}'); // Debug log

      final response = await http.post(
        Uri.parse(ApiEndpoints.createOrder),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Create order response status: ${response.statusCode}'); // Debug log
      print('Create order response body: ${response.body}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<Order>.fromJson(
          jsonResponse,
          (data) => Order.fromJson(data),
        );
        if (apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw Exception('No order data in response');
        }
      } else {
        final errorBody = response.body;
        throw Exception('Failed to create order: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Get user orders
  Future<List<Order>> getUserOrders() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.orders),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<List<Order>>.fromJson(
          jsonResponse,
          (data) {
            if (data is List) {
              return data.map((item) => Order.fromJson(item as Map<String, dynamic>)).toList();
            } else {
              throw Exception('Expected List but got ${data.runtimeType}');
            }
          },
        );
        return apiResponse.data ?? [];
      } else {
        throw Exception('Failed to get orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting orders: $e');
    }
  }

  // Get my orders (user's orders with full details)
  Future<List<OrderResponse>> getMyOrders() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/orders/my-orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          if (data is List) {
            return data.map((item) => OrderResponse.fromJson(item as Map<String, dynamic>)).toList();
          } else {
            throw Exception('Expected List but got ${data.runtimeType}');
          }
        } else {
          throw Exception('API returned success=false: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to get my orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting my orders: $e');
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.orderDetail(orderId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<Order>.fromJson(
          jsonResponse,
          (data) => Order.fromJson(data),
        );
        return apiResponse.data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting order: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse(ApiEndpoints.cancelOrder(orderId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error canceling order: $e');
    }
  }

  // Confirm delivery
  Future<Order> confirmDelivery(String orderId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/orders/$orderId/confirm-delivery'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<Order>.fromJson(
          jsonResponse,
          (data) => Order.fromJson(data),
        );
        if (apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw Exception('No order data in response');
        }
      } else {
        throw Exception('Failed to confirm delivery: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error confirming delivery: $e');
    }
  }
}
