import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class ClientRepository extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final logger = Logger();

  List<Client> _clients = [];
  Client? _currentClient;
  bool _isLoading = false;
  String? _errorMessage;

  List<Client> get clients => _clients;
  Client? get currentClient => _currentClient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charge tous les clients
  Future<void> loadClients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          clientId, nom, prenom, email, telephone, adresse, 
          categorie, nif, stat, axe
        FROM Client
        ORDER BY nom ASC
      ''';

      final rows = await _db.query(sql);
      _clients = rows.map((row) => Client.fromMap(row)).toList();

      logger.i('${_clients.length} clients chargés');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement des clients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge un client spécifique
  Future<void> loadClient(int clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          clientId, nom, prenom, email, telephone, adresse,
          categorie, nif, stat, axe
        FROM Client
        WHERE clientId = ?
      ''';

      final row = await _db.queryOne(sql, [clientId]);
      if (row != null) {
        _currentClient = Client.fromMap(row);
        logger.i('Client $clientId chargé');
      } else {
        _errorMessage = 'Client non trouvé';
      }
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement du client: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée un nouveau client
  Future<int> createClient(Client client) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        INSERT INTO Client (nom, prenom, email, telephone, adresse, 
                           categorie, nif, stat, axe)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''';

      final id = await _db.insert(sql, [
        client.nom,
        client.prenom,
        client.email,
        client.telephone,
        client.adresse,
        client.categorie,
        client.nif,
        client.stat,
        client.axe,
      ]);

      final newClient = client.copyWith(clientId: id);
      _clients.add(newClient);

      logger.i('Client créé avec l\'ID: $id');
      return id;
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la création: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour un client
  Future<void> updateClient(Client client) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        UPDATE Client
        SET nom = ?, prenom = ?, email = ?, telephone = ?, adresse = ?,
            categorie = ?, nif = ?, stat = ?, axe = ?
        WHERE clientId = ?
      ''';

      await _db.execute(sql, [
        client.nom,
        client.prenom,
        client.email,
        client.telephone,
        client.adresse,
        client.categorie,
        client.nif,
        client.stat,
        client.axe,
        client.clientId,
      ]);

      // Mettre à jour dans la liste
      final index = _clients.indexWhere((c) => c.clientId == client.clientId);
      if (index != -1) {
        _clients[index] = client;
      }

      if (_currentClient?.clientId == client.clientId) {
        _currentClient = client;
      }

      logger.i('Client ${client.clientId} mis à jour');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la mise à jour: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprime un client
  Future<void> deleteClient(int clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = 'DELETE FROM Client WHERE clientId = ?';

      await _db.execute(sql, [clientId]);

      _clients.removeWhere((c) => c.clientId == clientId);

      if (_currentClient?.clientId == clientId) {
        _currentClient = null;
      }

      logger.i('Client $clientId supprimé');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la suppression: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recherche des clients
  Future<void> searchClients(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          clientId, nom, prenom, email, telephone, adresse,
          categorie, nif, stat, axe
        FROM Client
        WHERE nom LIKE ? OR prenom LIKE ? OR email LIKE ?
        ORDER BY nom ASC
      ''';

      final searchTerm = '%$query%';
      final rows = await _db.query(sql, [searchTerm, searchTerm, searchTerm]);
      _clients = rows.map((row) => Client.fromMap(row)).toList();

      logger.i('${_clients.length} clients trouvés pour la recherche: $query');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la recherche: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtre les clients par catégorie
  Future<void> filterByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          clientId, nom, prenom, email, telephone, adresse,
          categorie, nif, stat, axe
        FROM Client
        WHERE categorie = ?
        ORDER BY nom ASC
      ''';

      final rows = await _db.query(sql, [category]);
      _clients = rows.map((row) => Client.fromMap(row)).toList();

      logger.i(
        '${_clients.length} clients trouvés pour la catégorie: $category',
      );
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du filtrage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère les catégories disponibles
  Future<List<String>> getCategories() async {
    try {
      const sql =
          'SELECT DISTINCT categorie FROM Client ORDER BY categorie ASC';

      final rows = await _db.query(sql);
      final categories = rows
          .map((row) => row['categorie'] as String?)
          .whereType<String>()
          .toList();

      logger.i('${categories.length} catégories trouvées');
      return categories;
    } catch (e) {
      logger.e('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  /// Récupère le nombre total de clients
  int getTotalClients() => _clients.length;

  /// Vérifie si un email existe
  Future<bool> emailExists(String email) async {
    try {
      const sql = 'SELECT clientId FROM Client WHERE email = ?';
      final row = await _db.queryOne(sql, [email]);
      return row != null;
    } catch (e) {
      logger.e('Erreur lors de la vérification de l\'email: $e');
      return false;
    }
  }
}
