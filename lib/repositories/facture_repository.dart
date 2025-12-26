import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class FactureRepository extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final logger = Logger();

  List<Facture> _factures = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Facture> get factures => _factures;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charge les factures d'un client
  Future<void> loadFacturesForClient(int clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          factureId, date, montant, etat
        FROM Facture
        WHERE clientId = ?
        ORDER BY date DESC
      ''';

      final rows = await _db.query(sql, [clientId]);
      _factures = rows.map((row) => Facture.fromMap(row)).toList();

      logger.i(
        '${_factures.length} factures chargées pour le client $clientId',
      );
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement des factures: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge toutes les factures
  Future<void> loadAllFactures() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        SELECT 
          factureId, date, montant, etat
        FROM Facture
        ORDER BY date DESC
      ''';

      final rows = await _db.query(sql);
      _factures = rows.map((row) => Facture.fromMap(row)).toList();

      logger.i('${_factures.length} factures chargées');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement des factures: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour le prix d'une facture
  Future<void> updateFacturePrice(int factureId, double newPrice) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = 'UPDATE Facture SET montant = ? WHERE factureId = ?';

      await _db.execute(sql, [newPrice, factureId]);

      // Mettre à jour dans la liste
      final index = _factures.indexWhere((f) => f.factureId == factureId);
      if (index != -1) {
        _factures[index] = _factures[index].copyWith(montant: newPrice);
      }

      logger.i('Facture $factureId mise à jour avec le montant: $newPrice');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la mise à jour: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marque une facture comme payée
  Future<void> markAsPaid(int factureId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = 'UPDATE Facture SET etat = ? WHERE factureId = ?';

      await _db.execute(sql, ['Payée', factureId]);

      // Mettre à jour dans la liste
      final index = _factures.indexWhere((f) => f.factureId == factureId);
      if (index != -1) {
        _factures[index] = _factures[index].copyWith(etat: 'Payée');
      }

      logger.i('Facture $factureId marquée comme payée');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du marquage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée une facture
  Future<int> createFacture(int clientId, double montant, DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = '''
        INSERT INTO Facture (clientId, date, montant, etat)
        VALUES (?, ?, ?, ?)
      ''';

      final id = await _db.insert(sql, [
        clientId,
        date.toString(),
        montant,
        'Non payée',
      ]);

      logger.i('Facture créée avec l\'ID: $id');
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

  /// Supprime une facture
  Future<void> deleteFacture(int factureId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const sql = 'DELETE FROM Facture WHERE factureId = ?';

      await _db.execute(sql, [factureId]);

      _factures.removeWhere((f) => f.factureId == factureId);

      logger.i('Facture $factureId supprimée');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors de la suppression: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère le montant total payé
  double getTotalPaid() {
    return _factures
        .where((f) => f.isPaid)
        .fold(0, (sum, f) => sum + f.montant);
  }

  /// Récupère le montant total non payé
  double getTotalUnpaid() {
    return _factures
        .where((f) => !f.isPaid)
        .fold(0, (sum, f) => sum + f.montant);
  }
}
