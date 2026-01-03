import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/plan.dart';
import '../models/operator.dart';

class PlansService {
  final Dio _dio = Dio();

  Future<Options> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    return Options(headers: {
      'Content-Type': 'application/json',
      'X-User-ID': userId.toString(),
    });
  }

  Future<List<Plan>> getPlans({int? operatorId}) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/recharge/plans/',
        queryParameters: operatorId != null ? {'operator_id': operatorId} : null,
        options: await _getHeaders(),
      );
      return (response.data as List).map((x) => Plan.fromJson(x)).toList();
    } catch (e) {
      throw Exception('Failed to load plans: $e');
    }
  }

  Future<bool> createPlan(Map<String, dynamic> data) async {
    try {
      await _dio.post(
        '${AppConstants.baseUrl}/recharge/plans/',
        data: data,
        options: await _getHeaders(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePlan(int id, Map<String, dynamic> data) async {
    try {
      await _dio.patch(
        '${AppConstants.baseUrl}/recharge/plans/$id/',
        data: data,
        options: await _getHeaders(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePlan(int id) async {
    try {
      await _dio.delete(
        '${AppConstants.baseUrl}/recharge/plans/$id/',
        options: await _getHeaders(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Operator>> getOperators() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/recharge/operators/',
        options: await _getHeaders(),
      );
      return (response.data as List).map((x) => Operator.fromJson(x)).toList();
    } catch (e) {
      throw Exception('Failed to load operators: $e');
    }
  }
}
