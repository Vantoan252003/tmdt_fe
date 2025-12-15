import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io';
import '../models/user.dart';
import 'api_endpoints.dart';
import 'fcm_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      // 🔥 Xóa toàn bộ cache cũ trước khi login
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      print('🔑 Token mới nhận được sau login: ${data['data']['token']}');

      if (response.statusCode == 200 && data['success'] == true) {
        // ✅ Lưu token mới
        await prefs.setString(_tokenKey, data['data']['token']);
        await prefs.reload();

        // ✅ Lưu user
        final user = User.fromJson(data['data']);
        await prefs.setString(_userDataKey, jsonEncode(user.toJson()));

        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Register method
  static Future<Map<String, dynamic>> register(
    String email,
    String fullName,
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'fullName': fullName,
          'phone': phone,
          'password': password,
          'role': 'CUSTOMER',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng ký thất bại'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Facebook Login
  static Future<Map<String, dynamic>> loginWithFacebook() async {
  try {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.success) {
      final accessToken = result.accessToken!.tokenString;

      final response = await http.post(
        Uri.parse(ApiEndpoints.facebookLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': accessToken,  
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['data']['token']);
        
        final user = User.fromJson(data['data']);
        await prefs.setString(_userDataKey, jsonEncode(user.toJson()));

        return {'success': true, 'message': 'Đăng nhập Facebook thành công'};
      }
      return {'success': false, 'message': data['message']};
    }
    
    if (result.status == LoginStatus.cancelled) {
      return {'success': false, 'message': 'Đã hủy đăng nhập'};
    }
    
    return {'success': false, 'message': result.message};
  } catch (e) {
    return {'success': false, 'message': 'Lỗi: $e'};
  }
}

  // Logout method
  static Future<void> logout() async {
    // Deactivate FCM token before logging out
    await FCMService().deactivateCurrentToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get SharedPreferences instance (for other services)
  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userDataKey);
    if (userDataJson != null) {
      try {
        final userData = jsonDecode(userDataJson);
        return User.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<User?> fetchUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiEndpoints.profile),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final user = User.fromJson(data['data']);
          
          // Update cache
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
          
          return user;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user ID from stored user data
  static Future<String?> getUserId() async {
    final user = await getUserData();
    return user?.id;
  }

  // Upload avatar
  static Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Người dùng chưa đăng nhập'};
      }

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.uploadAvatar));
      request.headers['Authorization'] = 'Bearer $token';

      // Add image file
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(multipartFile);

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);

      if (response.statusCode == 200 && data['success'] == true) {
        // Fetch fresh user data from API to get updated avatar and latest stats
        await fetchUserProfile();

        return {'success': true, 'message': 'Upload avatar thành công', 'avatarUrl': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Upload avatar thất bại'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUserInfo(User user) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Người dùng chưa đăng nhập'};
      }


      final response = await http.put(
        Uri.parse(ApiEndpoints.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "fullName": user.fullName,
          "phoneNumber": user.phoneNumber,
          "email": user.email,
        }),
      );
   

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
        return {
          'success': true,
          'message': 'Cập nhật thông tin thành công! 🎉'
        };
      }

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      return {
        'success': false,
        'message': data['message'] ?? 'Cập nhật thất bại',
      };
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Người dùng chưa đăng nhập'};
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': 'Đổi mật khẩu thành công'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đổi mật khẩu thất bại'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
