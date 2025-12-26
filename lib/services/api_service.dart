import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

/// Service API pour communiquer avec le backend
class ApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // À adapter
  static const Duration timeout = Duration(seconds: 30);

  final Logger _logger = Logger();
  String? _authToken;

  /// Setter pour le token d'authentification
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Getter pour le token
  String? get authToken => _authToken;

  /// Headers HTTP par défaut
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  /// GET Request
  Future<T> get<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      _logger.i('GET $endpoint');
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(timeout);

      _handleResponse(response);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return fromJson(data);
    } catch (e) {
      _logger.e('GET Error: $e');
      rethrow;
    }
  }

  /// GET List
  Future<List<T>> getList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      _logger.i('GET $endpoint');
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(timeout);

      _handleResponse(response);
      final list = jsonDecode(response.body) as List;
      return list
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('GET List Error: $e');
      rethrow;
    }
  }

  /// POST Request
  Future<T> post<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      _logger.i('POST $endpoint');
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(timeout);

      _handleResponse(response);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return fromJson(data);
    } catch (e) {
      _logger.e('POST Error: $e');
      rethrow;
    }
  }

  /// PUT Request
  Future<T> put<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      _logger.i('PUT $endpoint');
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(timeout);

      _handleResponse(response);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return fromJson(data);
    } catch (e) {
      _logger.e('PUT Error: $e');
      rethrow;
    }
  }

  /// DELETE Request
  Future<bool> delete(String endpoint) async {
    try {
      _logger.i('DELETE $endpoint');
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(timeout);

      _handleResponse(response);
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('DELETE Error: $e');
      rethrow;
    }
  }

  /// Gestion des réponses
  void _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _logger.e('HTTP Error: ${response.statusCode} - ${response.body}');
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}

/// Exception API personnalisée
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
