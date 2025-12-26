import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class ContratRepository extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final logger = Logger();

  List<Contrat> _contrats = [];
  Contrat? _currentContrat;
  bool _isLoading = false;
  String? _errorMessage;

  List<Contrat> get contrats => _contrats;
  Contrat? get currentContrat => _currentContrat;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charge tous les contrats
  Future<void> loadContrats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          contratId, clientId, dateDebut, dateFin, prix, etat
        FROM Contrat
        ORDER BY dateDebut DESC
      ''';

      final rows = await _db.query(sql);
      _contrats = rows.map((row) => Contrat.fromMap(row)).toList();

      logger.i('${_contrats.length} contrats chargés');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement des contrats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les contrats d'un client
  Future<void> loadContratsForClient(int clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          contratId, clientId, dateDebut, dateFin, prix, etat
        FROM Contrat
        WHERE clientId = ?
        ORDER BY dateDebut DESC
      ''';

      final rows = await _db.query(sql, [clientId]);
      _contrats = rows.map((row) => Contrat.fromMap(row)).toList();

      logger.i('${_contrats.length} contrats chargés pour le client $clientId');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement des contrats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge un contrat spécifique
  Future<void> loadContrat(int contratId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          contratId, clientId, dateDebut, dateFin, prix, etat
        FROM Contrat
        WHERE contratId = ?
      ''';

      final row = await _db.queryOne(sql, [contratId]);
      if (row != null) {
        _currentContrat = Contrat.fromMap(row);
        logger.i('Contrat $contratId chargé');
      } else {
        _errorMessage = 'Contrat non trouvé';
      }
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement du contrat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée un nouveau contrat
  Future<int> createContrat(
    int clientId,
    DateTime dateDebut,
    DateTime dateFin,
    double prix,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        INSERT INTO Contrat (clientId, dateDebut, dateFin, prix, etat)
        VALUES (?, ?, ?, ?, ?)
      ''';

      final id = await _db.insert(sql, [
        clientId,
        dateDebut.toIso8601String(),
        dateFin.toIso8601String(),
        prix,
        'Actif',
      ]);

      // Ajouter le nouveau contrat à la liste
      final newContrat = Contrat(
        contratId: id,
        clientId: clientId,
        dateDebut: dateDebut,
        dateFin: dateFin,
        prix: prix,
        etat: 'Actif',
      );
      _contrats.add(newContrat);

      logger.i('Contrat créé avec l\'ID: $id');
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

  /// Met à jour un contrat
  Future<void> updateContrat(Contrat contrat) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        UPDATE Contrat 
        SET clientId = ?, dateDebut = ?, dateFin = ?, prix = ?, etat = ?
        WHERE contratId = ?
      ''';

      await _db.execute(sql, [
        contrat.clientId,
        contrat.dateDebut.toIso8601String(),
        contrat.dateFin.toIso8601String(),
        contrat.prix,
        contrat.etat,
        contrat.contratId,
      ]);

      // Mettre à jour dans la liste
      final index = _contrats.indexWhere(
        (c) => c.contratId == contrat.contratId,
      );
      if (index != -1) {
        _contrats[index] = contrat;
      }

      if (_currentContrat?.contratId == contrat.contratId) {
        _currentContrat = contrat;
      }

      logger.i('Contrat ${contrat.contratId} mis à jour');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la mise à jour: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprime un contrat
  Future<void> deleteContrat(int contratId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = 'DELETE FROM Contrat WHERE contratId = ?';

      await _db.execute(sql, [contratId]);

      _contrats.removeWhere((c) => c.contratId == contratId);

      if (_currentContrat?.contratId == contratId) {
        _currentContrat = null;
      }

      logger.i('Contrat $contratId supprimé');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la suppression: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère les contrats actifs
  List<Contrat> getActiveContrats() {
    final now = DateTime.now();
    return _contrats
        .where((c) => c.dateDebut.isBefore(now) && c.dateFin.isAfter(now))
        .toList();
  }

  /// Récupère la durée en mois d'un contrat
  int getContractDurationInMonths(Contrat contrat) {
    return contrat.dateFin.month -
        contrat.dateDebut.month +
        12 * (contrat.dateFin.year - contrat.dateDebut.year);
  }

  /// Recherche des contrats
  Future<void> searchContrats(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          c.contratId, c.clientId, c.dateDebut, c.dateFin, c.prix, c.etat
        FROM Contrat c
        JOIN Client cli ON c.clientId = cli.clientId
        WHERE cli.nom LIKE ? OR cli.prenom LIKE ?
        ORDER BY c.dateDebut DESC
      ''';

      final searchTerm = '%$query%';
      final rows = await _db.query(sql, [searchTerm, searchTerm]);
      _contrats = rows.map((row) => Contrat.fromMap(row)).toList();

      logger.i(
        '${_contrats.length} contrats trouvés pour la recherche: $query',
      );
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la recherche: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
