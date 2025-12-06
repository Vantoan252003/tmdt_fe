import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_endpoints.dart';
import '../models/address.dart';
import '../models/api_response.dart';

class AddressService {
  // Get user addresses
  Future<List<Address>> getUserAddresses() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.addresses),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('API Response: $jsonResponse'); // Debug log
        final apiResponse = ApiResponse<List<Address>>.fromJson(
          jsonResponse,
          (data) {
            print('Data type: ${data.runtimeType}'); // Debug log
            if (data is List) {
              return data.map((item) {
                print('Item type: ${item.runtimeType}'); // Debug log
                return Address.fromJson(item as Map<String, dynamic>);
              }).toList();
            } else {
              throw Exception('Expected List but got ${data.runtimeType}');
            }
          },
        );
        return apiResponse.data ?? [];
      } else {
        throw Exception('Failed to get addresses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting addresses: $e');
    }
  }

  // Get address by ID
  Future<Address?> getAddressById(String addressId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.addresses}/$addressId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<Address>.fromJson(
          jsonResponse,
          (data) => Address.fromJson(data),
        );
        return apiResponse.data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting address: $e');
    }
  }

  // Get default address
  Future<Address?> getDefaultAddress() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.addresses}/default'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<Address>.fromJson(
          jsonResponse,
          (data) => Address.fromJson(data),
        );
        return apiResponse.data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get default address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting default address: $e');
    }
  }

  // Create address
  Future<Address> createAddress(AddressRequest request) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.addresses),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<Address>.fromJson(
          jsonResponse,
          (data) => Address.fromJson(data),
        );
        if (apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw Exception('No address data in response');
        }
      } else {
        throw Exception('Failed to create address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating address: $e');
    }
  }

  // Update address
  Future<Address> updateAddress(String addressId, AddressRequest request) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('${ApiEndpoints.addresses}/$addressId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<Address>.fromJson(
          jsonResponse,
          (data) => Address.fromJson(data),
        );
        if (apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw Exception('No address data in response');
        }
      } else {
        throw Exception('Failed to update address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating address: $e');
    }
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiEndpoints.addresses}/$addressId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting address: $e');
    }
  }

  // Set default address
  Future<Address> setDefaultAddress(String addressId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('${ApiEndpoints.addresses}/$addressId/default'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<Address>.fromJson(
          jsonResponse,
          (data) => Address.fromJson(data),
        );
        if (apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw Exception('No address data in response');
        }
      } else {
        throw Exception('Failed to set default address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error setting default address: $e');
    }
  }
}