import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../models/index.dart';

class TypeTraitementRepository extends ChangeNotifier {
  final logger = Logger();

  List<TypeTraitement> _traitements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TypeTraitement> get traitements => _traitements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialise la liste prédéfinie des traitements
  void _initializeTreatments() {
    _traitements = [
      TypeTraitement(id: 1, categorie: 'PC', type: 'Dératisation (PC)'),
      TypeTraitement(id: 2, categorie: 'PC', type: 'Désinfection (PC)'),
      TypeTraitement(id: 3, categorie: 'PC', type: 'Désinsectisation (PC)'),
      TypeTraitement(id: 4, categorie: 'PC', type: 'Fumigation (PC)'),
      TypeTraitement(id: 5, categorie: 'NI', type: 'Nettoyage industriel (NI)'),
      TypeTraitement(id: 6, categorie: 'AT', type: 'Anti termites (AT)'),
      TypeTraitement(id: 7, categorie: 'RO', type: 'Ramassage ordures (RO)'),
    ];
  }

  /// Charge les types de traitement prédéfinis
  Future<void> loadAllTraitements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Initialiser la liste prédéfinie
      _initializeTreatments();

      logger.i(
        '${_traitements.length} types de traitement chargés (prédéfinis)',
      );
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Erreur lors du chargement des types de traitement: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère un type de traitement par son ID
  TypeTraitement? getTraitementById(int id) {
    try {
      return _traitements.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Récupère le nom du traitement par son ID
  String getTraitementName(int id) {
    final traitement = getTraitementById(id);
    return traitement?.type ?? 'Traitement inconnu';
  }
}
