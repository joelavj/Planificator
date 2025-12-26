import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/index.dart';
import 'api_service.dart';

/// Service pour gérer les clients
class ClientService extends ChangeNotifier {
  final ApiService _apiService;
  final Logger _logger = Logger();

  List<Client> _clients = [];
  Client? _currentClient;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Client> get clients => _clients;
  Client? get currentClient => _currentClient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ClientService(this._apiService);

  /// Charger tous les clients
  Future<void> loadClients() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _clients = await _apiService.getList(
        '/clients',
        (json) => Client.fromJson(json),
      );

      _logger.i('✅ Loaded ${_clients.length} clients');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Error loading clients: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Charger un client spécifique
  Future<void> loadClient(int clientId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _currentClient = await _apiService.get(
        '/clients/$clientId',
        (json) => Client.fromJson(json),
      );

      _logger.i('✅ Loaded client: ${_currentClient?.fullName}');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Error loading client: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Créer un nouveau client
  Future<Client?> createClient(Map<String, dynamic> clientData) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final newClient = await _apiService.post(
        '/clients',
        clientData,
        (json) => Client.fromJson(json),
      );

      _clients.add(newClient);
      _logger.i('✅ Client created: ${newClient.fullName}');
      notifyListeners();
      return newClient;
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Error creating client: $e');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Mettre à jour un client
  Future<bool> updateClient(
    int clientId,
    Map<String, dynamic> clientData,
  ) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final updatedClient = await _apiService.put(
        '/clients/$clientId',
        clientData,
        (json) => Client.fromJson(json),
      );

      final index = _clients.indexWhere((c) => c.clientId == clientId);
      if (index != -1) {
        _clients[index] = updatedClient;
      }

      if (_currentClient?.clientId == clientId) {
        _currentClient = updatedClient;
      }

      _logger.i('✅ Client updated: ${updatedClient.fullName}');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Error updating client: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprimer un client
  Future<bool> deleteClient(int clientId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final success = await _apiService.delete('/clients/$clientId');

      if (success) {
        _clients.removeWhere((c) => c.clientId == clientId);
        if (_currentClient?.clientId == clientId) {
          _currentClient = null;
        }
        _logger.i('✅ Client deleted: $clientId');
      }

      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Error deleting client: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Rechercher des clients par nom
  List<Client> searchClients(String query) {
    if (query.isEmpty) return _clients;
    return _clients
        .where(
          (client) =>
              client.fullName.toLowerCase().contains(query.toLowerCase()) ||
              client.email.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
