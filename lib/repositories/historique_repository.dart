import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class HistoriqueRepository extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final logger = Logger();

  List<HistoriqueEvent> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HistoriqueEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charge tous les événements d'historique
  Future<void> loadAllEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          historiqueId, type, description, date, details
        FROM Historique
        ORDER BY date DESC
      ''';

      final rows = await _db.query(sql);
      _events = rows.map((row) => HistoriqueEvent.fromMap(row)).toList();

      logger.i('${_events.length} événements d\'historique chargés');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement de l\'historique: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les événements d'historique filtrés par type
  Future<void> loadEventsByType(String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          historiqueId, type, description, date, details
        FROM Historique
        WHERE type = ?
        ORDER BY date DESC
      ''';

      final rows = await _db.query(sql, [type]);
      _events = rows.map((row) => HistoriqueEvent.fromMap(row)).toList();

      logger.i('${_events.length} événements du type $type chargés');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement de l\'historique: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les événements d'historique pour un client
  Future<void> loadEventsForClient(int clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          h.historiqueId, h.type, h.description, h.date, h.details
        FROM Historique h
        JOIN Client c ON h.details LIKE CONCAT('%clientId:', c.clientId, '%')
        WHERE c.clientId = ?
        ORDER BY h.date DESC
      ''';

      final rows = await _db.query(sql, [clientId]);
      _events = rows.map((row) => HistoriqueEvent.fromMap(row)).toList();

      logger.i('${_events.length} événements du client $clientId chargés');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement de l\'historique: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les événements d'historique pour une plage de dates
  Future<void> loadEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          historiqueId, type, description, date, details
        FROM Historique
        WHERE date >= ? AND date <= ?
        ORDER BY date DESC
      ''';

      final rows = await _db.query(sql, [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
      _events = rows.map((row) => HistoriqueEvent.fromMap(row)).toList();

      logger.i('${_events.length} événements trouvés');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement de l\'historique: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enregistre un nouvel événement d'historique
  Future<int> logEvent(String type, String description, String details) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        INSERT INTO Historique (type, description, date, details)
        VALUES (?, ?, ?, ?)
      ''';

      final id = await _db.insert(sql, [
        type,
        description,
        DateTime.now().toIso8601String(),
        details,
      ]);

      final newEvent = HistoriqueEvent(
        historiqueId: id,
        type: type,
        description: description,
        date: DateTime.now(),
        details: details,
      );
      _events.insert(0, newEvent);

      logger.i('Événement d\'historique créé: $type');
      return id;
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la création de l\'événement: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enregistre la création d'un client
  Future<void> logClientCreation(int clientId, String clientName) async {
    await logEvent(
      'client',
      'Nouveau client créé',
      'clientId:$clientId,nom:$clientName',
    );
  }

  /// Enregistre la modification d'un client
  Future<void> logClientUpdate(int clientId, String clientName) async {
    await logEvent(
      'client',
      'Client modifié',
      'clientId:$clientId,nom:$clientName',
    );
  }

  /// Enregistre la suppression d'un client
  Future<void> logClientDeletion(int clientId, String clientName) async {
    await logEvent(
      'client',
      'Client supprimé',
      'clientId:$clientId,nom:$clientName',
    );
  }

  /// Enregistre la création d'une facture
  Future<void> logFactureCreation(int factureId, double montant) async {
    await logEvent(
      'facture',
      'Nouvelle facture créée',
      'factureId:$factureId,montant:$montant',
    );
  }

  /// Enregistre le paiement d'une facture
  Future<void> logFacturePayment(int factureId, double montant) async {
    await logEvent(
      'paiement',
      'Facture payée',
      'factureId:$factureId,montant:$montant',
    );
  }

  /// Enregistre la création d'un contrat
  Future<void> logContratCreation(int contratId) async {
    await logEvent('contrat', 'Nouveau contrat créé', 'contratId:$contratId');
  }

  /// Enregistre la fin d'un contrat
  Future<void> logContratEnd(int contratId) async {
    await logEvent('contrat', 'Contrat terminé', 'contratId:$contratId');
  }

  /// Recherche dans l'historique
  Future<void> searchEvents(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          historiqueId, type, description, date, details
        FROM Historique
        WHERE description LIKE ? OR details LIKE ?
        ORDER BY date DESC
      ''';

      final searchTerm = '%$query%';
      final rows = await _db.query(sql, [searchTerm, searchTerm]);
      _events = rows.map((row) => HistoriqueEvent.fromMap(row)).toList();

      logger.i(
        '${_events.length} événements trouvés pour la recherche: $query',
      );
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la recherche: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère les statistiques d'historique
  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    for (final event in _events) {
      stats[event.type] = (stats[event.type] ?? 0) + 1;
    }
    return stats;
  }

  /// Nettoie l'historique plus ancien que X jours
  Future<void> cleanupOldEvents(int days) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      const sql = 'DELETE FROM Historique WHERE date < ?';

      await _db.execute(sql, [cutoffDate.toIso8601String()]);

      // Recharger les événements
      await loadAllEvents();

      logger.i('Événements plus vieux que $days jours supprimés');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du nettoyage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
