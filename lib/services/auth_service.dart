import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../utils/constants.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<bool> login(String phoneNumber, String password, {String? fullName, String? fcmToken}) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.adminLoginEndpoint}',
        data: {
          'phone_number': phoneNumber,
          'password': password,
          'full_name': fullName,
          'fcm_token': fcmToken,
        },
      );

      if (response.statusCode == 200 && response.data['user_id'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', response.data['user_id']);
        await prefs.setString('full_name', response.data['full_name']);
        return true;
      }
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_id');
  }
}
