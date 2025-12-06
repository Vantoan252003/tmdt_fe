import '../services/location_service.dart';

class VietnamLocation {
  // Get cities/provinces dynamically from API
  static Future<List<String>> get cities async {
    return await LocationService.getCities();
  }

  // Get districts for a specific city dynamically from API
  static Future<List<String>> getDistricts(String city) async {
    return await LocationService.getDistricts(city);
  }

  // Check if a city has districts (always true for Vietnamese provinces)
  static bool hasDistricts(String city) {
    return true; // All Vietnamese provinces have districts
  }

  // Get all locations at once
  static Future<Map<String, List<String>>> getAllLocations() async {
    return await LocationService.getAllLocations();
  }
}