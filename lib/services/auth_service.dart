import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/index.dart';
import 'api_service.dart';

/// Service d'authentification
class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Login
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      }, (json) => User.fromJson(json['user'] as Map<String, dynamic>));

      _currentUser = response;
      _apiService.setAuthToken(response.token);

      _logger.i('✅ Login successful for ${response.email}');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Login error: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register
  Future<bool> register(
    String email,
    String password,
    String nom,
    String prenom,
  ) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _apiService.post(
        '/auth/register',
        {'email': email, 'password': password, 'nom': nom, 'prenom': prenom},
        (json) => User.fromJson(json['user'] as Map<String, dynamic>),
      );

      _currentUser = response;
      _apiService.setAuthToken(response.token);

      _logger.i('✅ Registration successful for ${response.email}');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Registration error: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  void logout() {
    _currentUser = null;
    _apiService.setAuthToken('');
    _logger.i('✅ Logout successful');
    notifyListeners();
  }

  /// Définir l'état de chargement
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Effacer le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
