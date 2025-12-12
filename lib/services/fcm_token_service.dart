import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

class FCMTokenService {
  static const String _authTokenKey = 'auth_token';

  /// Register FCM token with backend
  static Future<bool> registerToken(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(_authTokenKey);

      if (authToken == null) {
        throw Exception('No auth token found');
      }

      final deviceInfo = await _getDeviceInfo();

      final response = await http.post(
        Uri.parse(ApiEndpoints.registerFCMToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': fcmToken,
          'deviceType': deviceInfo['deviceType'],
          'deviceId': deviceInfo['deviceId'],
          'appType' : 'CUSTOMER_APP',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering FCM token: $e');
      return false;
    }
  }

  /// Deactivate FCM token
  static Future<bool> deactivateToken(String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.deactivateFCMToken),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to deactivate FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deactivating FCM token: $e');
      return false;
    }
  }

  /// Get device information
  static Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String deviceId;
    String deviceType;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id;
      deviceType = 'ANDROID';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown';
      deviceType = 'IOS';
    } else {
      deviceId = 'unknown';
      deviceType = 'UNKNOWN';
    }

    return {
      'deviceId': deviceId,
      'deviceType': deviceType,
    };
  }
}