import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address.dart';

class LocationService {
  static const String _baseUrl = 'https://provinces.open-api.vn';

  // Cache for provinces
  static List<Province>? _cachedProvinces;

  // Get list of cities/provinces
  static Future<List<String>> getCities() async {
    try {
      final provinces = await getProvinces();
      return provinces.map((p) => p.name).toList();
    } catch (e) {
      // Return empty list on error - no fallback needed since we have API
      return [];
    }
  }

  // Get all provinces with full data
  static Future<List<Province>> getProvinces() async {
    if (_cachedProvinces != null) {
      return _cachedProvinces!;
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/p/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedProvinces = data.map((json) => Province.fromJson(json)).toList();
        return _cachedProvinces!;
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  // Get districts for a specific city
  static Future<List<String>> getDistricts(String city) async {
    // For now, return some common districts for major cities
    // TODO: Replace with proper API when available
    final Map<String, List<String>> commonDistricts = {
      'Thành phố Hà Nội': [
        'Ba Đình', 'Hoàn Kiếm', 'Tây Hồ', 'Long Biên', 'Cầu Giấy', 'Đống Đa',
        'Hai Bà Trưng', 'Hoàng Mai', 'Thanh Xuân', 'Sóc Sơn', 'Đông Anh',
        'Gia Lâm', 'Nam Từ Liêm', 'Bắc Từ Liêm', 'Thanh Trì', 'Mê Linh',
        'Hà Đông', 'Thanh Oai', 'Ứng Hòa', 'Mỹ Đức', 'Thường Tín', 'Phúc Thọ',
        'Ba Vì', 'Chương Mỹ', 'Đan Phượng', 'Hoài Đức', 'Quốc Oai', 'Thạch Thất'
      ],
      'Thành phố Hồ Chí Minh': [
        'Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 6',
        'Quận 7', 'Quận 8', 'Quận 9', 'Quận 10', 'Quận 11', 'Quận 12',
        'Bình Tân', 'Bình Thạnh', 'Gò Vấp', 'Phú Nhuận', 'Tân Bình',
        'Tân Phú', 'Thủ Đức', 'Bình Chánh', 'Cần Giờ', 'Củ Chi',
        'Hóc Môn', 'Nhà Bè'
      ],
      'Thành phố Đà Nẵng': [
        'Hải Châu', 'Thanh Khê', 'Sơn Trà', 'Ngũ Hành Sơn', 'Liên Chiểu',
        'Cẩm Lệ', 'Hòa Vang'
      ],
      'Thành phố Cần Thơ': [
        'Ninh Kiều', 'Ô Môn', 'Bình Thuỷ', 'Cái Răng', 'Thốt Nốt'
      ],
      'Tỉnh Đồng Nai': [
        'Biên Hòa', 'Long Khánh', 'Nhơn Trạch', 'Trảng Bom', 'Vĩnh Cửu',
        'Định Quán', 'Thống Nhất', 'Cẩm Mỹ', 'Long Thành', 'Xuân Lộc', 'Tân Phú'
      ],
      'Tỉnh Bình Dương': [
        'Thủ Dầu Một', 'Bến Cát', 'Dầu Tiếng', 'Dĩ An', 'Phú Giáo',
        'Tân Uyên', 'Thuận An'
      ],
    };

    return commonDistricts[city] ?? [];
  }



  // Get all location data at once
  static Future<Map<String, List<String>>> getAllLocations() async {
    // Return the common districts map
    return {
      'Thành phố Hà Nội': [
        'Ba Đình', 'Hoàn Kiếm', 'Tây Hồ', 'Long Biên', 'Cầu Giấy', 'Đống Đa',
        'Hai Bà Trưng', 'Hoàng Mai', 'Thanh Xuân', 'Sóc Sơn', 'Đông Anh',
        'Gia Lâm', 'Nam Từ Liêm', 'Bắc Từ Liêm', 'Thanh Trì', 'Mê Linh',
        'Hà Đông', 'Thanh Oai', 'Ứng Hòa', 'Mỹ Đức', 'Thường Tín', 'Phúc Thọ',
        'Ba Vì', 'Chương Mỹ', 'Đan Phượng', 'Hoài Đức', 'Quốc Oai', 'Thạch Thất'
      ],
      'Thành phố Hồ Chí Minh': [
        'Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 6',
        'Quận 7', 'Quận 8', 'Quận 9', 'Quận 10', 'Quận 11', 'Quận 12',
        'Bình Tân', 'Bình Thạnh', 'Gò Vấp', 'Phú Nhuận', 'Tân Bình',
        'Tân Phú', 'Thủ Đức', 'Bình Chánh', 'Cần Giờ', 'Củ Chi',
        'Hóc Môn', 'Nhà Bè'
      ],
      'Thành phố Đà Nẵng': [
        'Hải Châu', 'Thanh Khê', 'Sơn Trà', 'Ngũ Hành Sơn', 'Liên Chiểu',
        'Cẩm Lệ', 'Hòa Vang'
      ],
      'Thành phố Cần Thơ': [
        'Ninh Kiều', 'Ô Môn', 'Bình Thuỷ', 'Cái Răng', 'Thốt Nốt'
      ],
      'Tỉnh Đồng Nai': [
        'Biên Hòa', 'Long Khánh', 'Nhơn Trạch', 'Trảng Bom', 'Vĩnh Cửu',
        'Định Quán', 'Thống Nhất', 'Cẩm Mỹ', 'Long Thành', 'Xuân Lộc', 'Tân Phú'
      ],
      'Tỉnh Bình Dương': [
        'Thủ Dầu Một', 'Bến Cát', 'Dầu Tiếng', 'Dĩ An', 'Phú Giáo',
        'Tân Uyên', 'Thuận An'
      ],
    };
  }

  // Get province by code
  static Future<Province?> getProvinceByCode(int code) async {
    final provinces = await getProvinces();
    try {
      return provinces.firstWhere((p) => p.code == code);
    } catch (e) {
      return null;
    }
  }

  // Get district by code
  static Future<District?> getDistrictByCode(int code) async {
    // This requires searching through all provinces - expensive operation
    // For now, return null. In practice, you might want to cache all districts
    return null;
  }

  // Clear cache (useful for refreshing data)
  static void clearCache() {
    _cachedProvinces = null;
  }
}