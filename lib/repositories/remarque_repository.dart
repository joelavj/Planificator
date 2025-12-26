import 'package:planificator/models/remarque.dart';
import 'package:planificator/services/database_service.dart';

class RemarqueRepository {
  final _db = DatabaseService();

  Future<Remarque?> createRemarque({required int planningDetailId,
    required int factureId,
    String? contenu,
    String? probleme,
    String? action,
    String? modePaiement,
    String? nomFacture,
    String? datePayement,
    String? etablissement,
    String? numeroCheque,
    bool estPayee = false,
  }) async {
    try {
      final result = await _db.query('INSERT INTO Remarque (planning_detail_id, factur_id, contenu, probleme, action, mode_paiement, nom_facture, date_payement, etablissement, numero_cheque, est_payee) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [planningDetailId, factureId, contenu, probleme, action, modePaiement, nomFacture, datePayement, etablissement, numeroCheque, estPayee ? 1 : 0],
      );

      if (result.isNotEmpty) {
        return Remarque(id: result[0]['id_remarque'] as int?, planningDetailId: planningDetailId, factureId: factureId, contenu: contenu, probleme: probleme, action: action, modePaiement: modePaiement, nomFacture: nomFacture, datePayement: datePayement, etablissement: etablissement, numeroCheque: numeroCheque, estPayee: estPayee);
      }
      return null;
    } catch (e) {
      print('❌ Erreur créer remarque: $e');
      rethrow;
    }
  }

  Future<List<Remarque>> getRemarques(int planningDetailId) async {
    try {
      final results = await _db.query('SELECT * FROM Remarque WHERE planning_detail_id = ? ORDER BY date_creation DESC', [planningDetailId]);
      return results.map((row) => Remarque.fromJson(row as Map<String, dynamic>)).toList();
    } catch (e) {
      print('❌ Erreur récupérer remarques: $e');
      return [];
    }
  }

  Future<bool> updateRemarquePaiement(int remarqueId, String modePaiement, String? nomFacture, String? datePayement, String? etablissement, String? numeroCheque) async {
    try {
      final result = await _db.query('UPDATE Remarque SET mode_paiement = ?, nom_facture = ?, date_payement = ?, etablissement = ?, numero_cheque = ?, est_payee = 1 WHERE id_remarque = ?', [modePaiement, nomFacture, datePayement, etablissement, numeroCheque, remarqueId]);
      return result.isNotEmpty;
    } catch (e) {
      print('❌ Erreur mettre à jour paiement remarque: $e');
      return false;
    }
  }

  Future<bool> deleteRemarque(int remarqueId) async {
    try {
      final result = await _db.query('DELETE FROM Remarque WHERE id_remarque = ?', [remarqueId]);
      return result.isNotEmpty;
    } catch (e) {
      print('❌ Erreur supprimer remarque: $e');
      return false;
    }
  }
}
