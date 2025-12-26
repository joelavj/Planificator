import 'package:planificator/models/signalement.dart';
import 'package:planificator/services/database_service.dart';

class SignalementRepository {
  final _db = DatabaseService();

  Future<Signalement?> createSignalement({required int planningDetailId, required String motif, required String type}) async {
    try {
      final result = await _db.query('INSERT INTO Signalement (planning_detail_id, motif, type) VALUES (?, ?, ?)', [planningDetailId, motif, type]);
      if (result.isNotEmpty) {
        return Signalement(id: result[0]['id_signalement'] as int?, planningDetailId: planningDetailId, motif: motif, type: type);
      }
      return null;
    } catch (e) {
      print('❌ Erreur créer signalement: $e');
      rethrow;
    }
  }

  Future<List<Signalement>> getSignalements(int planningDetailId) async {
    try {
      final results = await _db.query('SELECT * FROM Signalement WHERE planning_detail_id = ? ORDER BY date_signalement DESC', [planningDetailId]);
      return results.map((row) => Signalement.fromJson(row as Map<String, dynamic>)).toList();
    } catch (e) {
      print('❌ Erreur récupérer signalements: $e');
      return [];
    }
  }

  Future<bool> updateSignalement(int signalementId, String motif, String type) async {
    try {
      final result = await _db.query('UPDATE Signalement SET motif = ?, type = ? WHERE id_signalement = ?', [motif, type, signalementId]);
      return result.isNotEmpty;
    } catch (e) {
      print('❌ Erreur mettre à jour signalement: $e');
      return false;
    }
  }

  Future<bool> deleteSignalement(int signalementId) async {
    try {
      final result = await _db.query('DELETE FROM Signalement WHERE id_signalement = ?', [signalementId]);
      return result.isNotEmpty;
    } catch (e) {
      print('❌ Erreur supprimer signalement: $e');
      return false;
    }
  }
}
