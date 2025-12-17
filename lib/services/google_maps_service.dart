import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleMapsService {
  static const String apiKey = 'AIzaSyB3o5yLQv7Wt52Rl_ZBa0iiUiOihQ240DY';

  // Get current location using GPS
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services.');
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Reverse geocoding - Get address from coordinates
  Future<Map<String, dynamic>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Use Google Geocoding API for more detailed results
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$latitude,$longitude'
        '&language=vi'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final addressComponents = result['address_components'] as List;

          // Parse address components
          String streetNumber = '';
          String route = '';
          String ward = '';
          String district = '';
          String city = '';
          String country = '';

          for (var component in addressComponents) {
            final types = component['types'] as List;
            final longName = component['long_name'];

            if (types.contains('street_number')) {
              streetNumber = longName;
            } else if (types.contains('route')) {
              route = longName;
            } else if (types.contains('sublocality_level_1') ||
                types.contains('sublocality')) {
              ward = longName;
            } else if (types.contains('administrative_area_level_2')) {
              district = longName;
            } else if (types.contains('administrative_area_level_1')) {
              city = longName;
            } else if (types.contains('country')) {
              country = longName;
            }
          }

          // Build address line
          List<String> addressLineParts = [];
          if (streetNumber.isNotEmpty) addressLineParts.add(streetNumber);
          if (route.isNotEmpty) addressLineParts.add(route);
          String addressLine = addressLineParts.join(' ');

          // Full formatted address
          String fullAddress = result['formatted_address'];

          return {
            'success': true,
            'latitude': latitude,
            'longitude': longitude,
            'addressLine': addressLine,
            'ward': ward,
            'district': district,
            'city': city,
            'country': country,
            'fullAddress': fullAddress,
          };
        } else {
          throw Exception('No address found for these coordinates');
        }
      } else {
        throw Exception('Failed to fetch address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting address: $e');
    }
  }

  // Search places using Google Places Autocomplete API
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$query'
        '&language=vi'
        '&components=country:vn'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((prediction) {
            return {
              'placeId': prediction['place_id'],
              'description': prediction['description'],
              'mainText': prediction['structured_formatting']['main_text'],
              'secondaryText':
                  prediction['structured_formatting']['secondary_text'] ?? '',
            };
          }).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }

  // Get place details from place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&language=vi'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          final addressComponents = result['address_components'] as List;

          // Parse address components
          String streetNumber = '';
          String route = '';
          String ward = '';
          String district = '';
          String city = '';
          String country = '';

          for (var component in addressComponents) {
            final types = component['types'] as List;
            final longName = component['long_name'];

            if (types.contains('street_number')) {
              streetNumber = longName;
            } else if (types.contains('route')) {
              route = longName;
            } else if (types.contains('sublocality_level_1') ||
                types.contains('sublocality')) {
              ward = longName;
            } else if (types.contains('administrative_area_level_2')) {
              district = longName;
            } else if (types.contains('administrative_area_level_1')) {
              city = longName;
            } else if (types.contains('country')) {
              country = longName;
            }
          }

          // Build address line
          List<String> addressLineParts = [];
          if (streetNumber.isNotEmpty) addressLineParts.add(streetNumber);
          if (route.isNotEmpty) addressLineParts.add(route);
          String addressLine = addressLineParts.join(' ');

          return {
            'success': true,
            'latitude': location['lat'],
            'longitude': location['lng'],
            'addressLine': addressLine,
            'ward': ward,
            'district': district,
            'city': city,
            'country': country,
            'fullAddress': result['formatted_address'],
          };
        } else {
          throw Exception('Failed to get place details');
        }
      } else {
        throw Exception('Failed to fetch place details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting place details: $e');
    }
  }

  // Format address for display
  String formatAddress(Map<String, dynamic> addressData) {
    List<String> parts = [];

    if (addressData['addressLine']?.isNotEmpty ?? false) {
      parts.add(addressData['addressLine']);
    }
    if (addressData['ward']?.isNotEmpty ?? false) {
      parts.add(addressData['ward']);
    }
    if (addressData['district']?.isNotEmpty ?? false) {
      parts.add(addressData['district']);
    }
    if (addressData['city']?.isNotEmpty ?? false) {
      parts.add(addressData['city']);
    }

    return parts.join(', ');
  }
}
