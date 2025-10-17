import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // Helper function to get the token from local storage
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  // Register
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register');
    }
  }

  // Log a daily task (Farmer)
  static Future<void> logTask(
    String taskType,
    DateTime date,
    int farmerId,
  ) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/farmers/tasks'),
      headers: {'Content-Type': 'application/json', 'x-auth-token': token!},
      body: jsonEncode({
        'task_type': taskType,
        'date': date.toIso8601String(),
        'farmer_id': farmerId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to log task');
    }
  }

  // Create a new batch (Farmer)
  static Future<void> createBatch(
    String batchId,
    double weight,
    String quality,
    String location,
    int farmerId,
  ) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/farmers/batches'),
      headers: {'Content-Type': 'application/json', 'x-auth-token': token!},
      body: jsonEncode({
        'batch_id': batchId,
        'weight': weight,
        'quality': quality,
        'location': location,
        'farmer_id': farmerId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create batch');
    }
  }

  // Update batch quality (Aggregator)
  static Future<void> updateBatchQuality(int batchId, String quality) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/aggregators/batches/$batchId'),
      headers: {'Content-Type': 'application/json', 'x-auth-token': token!},
      body: jsonEncode({'quality': quality}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update batch quality');
    }
  }

  // Update batch location and status (Transporter)
  static Future<void> updateBatchLocation(
    int batchId,
    String location,
    String status,
  ) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/transporters/batches/$batchId'),
      headers: {'Content-Type': 'application/json', 'x-auth-token': token!},
      body: jsonEncode({'location': location, 'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update batch location');
    }
  }

  // Get all batches (Processor)
  static Future<List<dynamic>> getBatches() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/processors/batches'),
      headers: {'x-auth-token': token!},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch batches');
    }
  }
}
