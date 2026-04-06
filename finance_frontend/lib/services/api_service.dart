import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    return user != null ? jsonDecode(user) : null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(
      String username, String password, String email, String role) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password, 'email': email, 'role': role}),
    );
    return jsonDecode(res.body);
  }

  // Dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/dashboard/summary'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // Records
  static Future<Map<String, dynamic>> getRecords({
    String? type,
    String? category,
    String? startDate,
    String? endDate,
    int page = 0,
    int size = 10,
    String sortBy = 'date',
    String sortDir = 'DESC',
  }) async {
    final params = {
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    final uri = Uri.parse('$baseUrl/api/records').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createRecord(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/records'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateRecord(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/records/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<bool> deleteRecord(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/records/$id'),
      headers: await _headers(),
    );
    return res.statusCode == 204;
  }

  // Users
  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/users'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateUserStatus(int id, bool active) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/users/$id/status?active=$active'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }
}
