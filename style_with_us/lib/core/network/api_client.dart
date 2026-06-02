import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiUrl;

  final http.Client _client;
  final String _baseUrl;

  String get baseUrl => _baseUrl;

  /// Injects the Firebase token automatically
  Future<Map<String, String>> _buildHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : null;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() requestFn,
  ) async {
    const int maxRetries = 2;
    int attempt = 0;
    while (true) {
      try {
        final response = await requestFn().timeout(const Duration(seconds: 15));
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw Exception('Unauthorized Backend Access');
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
        return response;
      } catch (e) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<dynamic> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    
    final response = await _executeWithRetry(() async {
      return _client.post(
        uri,
        headers: await _buildHeaders(),
        body: jsonEncode(body ?? <String, dynamic>{}),
      );
    });
    final data = jsonDecode(response.body);
    
    // Auto-polling for FastAPI Celery Async Jobs
    if (data is Map<String, dynamic> && data.containsKey('job_id') && data['status'] == 'processing') {
      return _pollJobStatus(data['job_id']);
    }
    
    return data;
  }

  Future<dynamic> getJson(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    
    final response = await _executeWithRetry(() async {
      return _client.get(
        uri,
        headers: await _buildHeaders(),
      );
    });
    return jsonDecode(response.body);
  }

  Future<dynamic> _pollJobStatus(String jobId) async {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      final uri = Uri.parse('$_baseUrl/ml/job/$jobId');
      
      final response = await _executeWithRetry(() async {
        return _client.get(uri, headers: await _buildHeaders());
      });
      final data = jsonDecode(response.body);
      
      if (data is Map<String, dynamic>) {
        if (data['status'] == 'complete') {
          return data['result'];
        } else if (data['status'] == 'error') {
          throw Exception(data['error'] ?? 'Background job failed');
        }
      }
    }
  }
}
