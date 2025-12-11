import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/topup_request.dart';
import '../models/recharge_request.dart';
import '../models/user.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<Options> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    return Options(headers: {
      'Content-Type': 'application/json',
      'X-User-ID': userId.toString(), 
    });
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}${AppConstants.adminDashboardEndpoint}',
        options: await _getHeaders(),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load dashboard stats');
    }
  }

  Future<List<TopUpRequest>> getTopUpRequests({String? status}) async {
    try {
      final url = '${AppConstants.baseUrl}${AppConstants.adminTopUpsEndpoint}';
      final response = await _dio.get(
        url,
        queryParameters: status != null ? {'status': status} : null,
        options: await _getHeaders(),
      );
      return (response.data as List).map((x) => TopUpRequest.fromJson(x)).toList();
    } catch (e) {
      throw Exception('Failed to load topups');
    }
  }

  Future<bool> connectTopUpAction(int id, String action, {String? note}) async {
    try {
      await _dio.post(
        '${AppConstants.baseUrl}/admin/topups/$id/action/',
        data: {'action': action, 'note': note},
        options: await _getHeaders(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<RechargeRequest>> getRechargeRequests() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}${AppConstants.adminRechargesEndpoint}',
        options: await _getHeaders(),
      );
      return (response.data as List).map((x) => RechargeRequest.fromJson(x)).toList();
    } catch (e) {
      throw Exception('Failed to load recharges');
    }
  }

  Future<bool> updateRechargeStatus(int id, String status) async {
    try {
      await _dio.patch(
        '${AppConstants.baseUrl}/admin/recharges/$id/',
        data: {'status': status},
        options: await _getHeaders(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/admin/users/',
        options: await _getHeaders(),
      );
      return (response.data as List).map((x) => User.fromJson(x)).toList();
    } catch (e) {
      throw Exception('Failed to load users');
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    try {
      await _dio.patch(
         '${AppConstants.baseUrl}/admin/users/$id/',
         data: data,
        options: await _getHeaders(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
