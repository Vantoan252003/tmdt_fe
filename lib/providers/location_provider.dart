import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  List<String> _cities = [];
  Map<String, List<String>> _districts = {};
  bool _isLoadingCities = false;
  bool _isLoadingDistricts = false;

  List<String> get cities => _cities;
  Map<String, List<String>> get districts => _districts;
  bool get isLoadingCities => _isLoadingCities;
  bool get isLoadingDistricts => _isLoadingDistricts;

  // Load cities from API
  Future<void> loadCities() async {
    if (_cities.isNotEmpty) return; // Already loaded

    _isLoadingCities = true;
    notifyListeners();

    try {
      _cities = await LocationService.getCities();
    } catch (e) {
      // Return empty list on error
      _cities = [];
    } finally {
      _isLoadingCities = false;
      notifyListeners();
    }
  }

  // Load districts for a specific city
  Future<void> loadDistricts(String city) async {
    if (_districts.containsKey(city)) return; // Already loaded

    _isLoadingDistricts = true;
    notifyListeners();

    try {
      final districts = await LocationService.getDistricts(city);
      _districts[city] = districts;
    } catch (e) {
      // Return empty list on error
      _districts[city] = [];
    } finally {
      _isLoadingDistricts = false;
      notifyListeners();
    }
  }

  // Get districts for a city (load if not available)
  Future<List<String>> getDistrictsForCity(String city) async {
    if (!_districts.containsKey(city)) {
      await loadDistricts(city);
    }
    return _districts[city] ?? [];
  }

  // Clear all data
  void clearData() {
    _cities.clear();
    _districts.clear();
    notifyListeners();
  }
}