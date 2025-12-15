import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'api_endpoints.dart';
import 'auth_service.dart';

class AvatarService {
  static Future<Map<String, dynamic>> pickAndUploadAvatar(ImageSource source) async {
    try {
      // Request permissions
      bool permissionGranted = false;
      
      if (source == ImageSource.camera) {
        final status = await Permission.camera.status;
        if (status.isDenied) {
          final result = await Permission.camera.request();
          permissionGranted = result.isGranted;
        } else {
          permissionGranted = status.isGranted;
        }
      } else {
        // For gallery, try multiple permissions
        final photosStatus = await Permission.photos.status;
        final storageStatus = await Permission.storage.status;
        
        if (photosStatus.isGranted || storageStatus.isGranted) {
          permissionGranted = true;
        } else if (photosStatus.isDenied || storageStatus.isDenied) {
          // Request permissions
          final photosResult = await Permission.photos.request();
          final storageResult = await Permission.storage.request();
          permissionGranted = photosResult.isGranted || storageResult.isGranted;
        }
      }

      if (!permissionGranted) {
        return {
          'success': false,
          'message': 'Cần cấp quyền truy cập để chọn ảnh. Vui lòng vào cài đặt và cấp quyền.'
        };
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        return await uploadAvatar(File(pickedFile.path));
      } else {
        return {
          'success': false,
          'message': 'Không có ảnh được chọn'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi chọn ảnh: $e'
      };
    }
  }

  static Future<bool> _isAndroid13OrHigher() async {
    // Check if device is Android 13 or higher
    // Android 13 = API level 33
    return false; // For now, let's use storage permission for compatibility
  }

  static Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    try {
      final token = await AuthService.getToken();
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
        // Update stored user data with new avatar URL
        await _updateUserAvatar(data['data']);

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

  static Future<void> _updateUserAvatar(String avatarUrl) async {
    // Avatar is already updated in AuthService.uploadAvatar()
    // No need to do anything here
  }
  }
