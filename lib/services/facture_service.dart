import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/index.dart';
import 'api_service.dart';

/// Service pour gérer les factures
class FactureService extends ChangeNotifier {
  final ApiService _apiService;
  final Logger _logger = Logger();

  List<Facture> _factures = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Facture> get factures => _factures;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FactureService(this._apiService);

  /// Charger les factures d'un client
  Future<void> loadFacturesForClient(int clientId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _factures = await _apiService.getList(
        '/clients/$clientId/factures',
        (json) => Facture.fromJson(json),
      );

      _logger.i('✅ Loaded ${_factures.length} factures');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Error loading factures: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Mettre à jour le prix d'une facture
  Future<bool> updateFacturePrice(int factureId, double newPrice) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final updatedFacture = await _apiService.put(
        '/factures/$factureId/prix',
        {'montant': newPrice},
        (json) => Facture.fromJson(json),
      );

      final index = _factures.indexWhere((f) => f.factureId == factureId);
      if (index != -1) {
        _factures[index] = updatedFacture;
      }

      _logger.i('✅ Facture price updated: ${updatedFacture.montantFormatted}');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Error updating facture price: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Marquer une facture comme payée
  Future<bool> markAsPaid(int factureId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final updatedFacture = await _apiService.put(
        '/factures/$factureId/marquer-paye',
        {'etat': 'Payé'},
        (json) => Facture.fromJson(json),
      );

      final index = _factures.indexWhere((f) => f.factureId == factureId);
      if (index != -1) {
        _factures[index] = updatedFacture;
      }

      _logger.i('✅ Facture marked as paid');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _logger.e('❌ Error marking facture as paid: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Calculer le total des factures payées
  double getTotalPaid() {
    return _factures
        .where((f) => f.isPaid)
        .fold(0.0, (sum, f) => sum + f.montant);
  }

  /// Calculer le total des factures non payées
  double getTotalUnpaid() {
    return _factures
        .where((f) => !f.isPaid)
        .fold(0.0, (sum, f) => sum + f.montant);
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
