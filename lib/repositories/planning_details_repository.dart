import 'package:planificator/models/planning_details.dart';
import 'package:planificator/services/database_service.dart';

class PlanningDetailsRepository {
  final _db = DatabaseService();

  /// Créer un détail de planning
  Future<PlanningDetails?> createPlanningDetails(
    int planningId,
    DateTime datePlanification, {
    String etat = 'À venir',
  }) async {
    try {
      final result = await _db.query(
        'INSERT INTO PlanningDetails (planning_id, date_planification, etat) VALUES (?, ?, ?)',
        [planningId, datePlanification.toIso8601String().split('T')[0], etat],
      );

      if (result.isNotEmpty) {
        int insertId = result[0]['id_planning_details'] as int? ?? 0;
        if (insertId == 0) return null;

        return PlanningDetails(
          id: insertId,
          planningId: planningId,
          datePlanification: datePlanification,
          etat: etat,
        );
      }
      return null;
    } catch (e) {
      print('❌ Erreur créer planning_details: $e');
      rethrow;
    }
  }

  /// Récupérer détails d'un planning
  Future<List<PlanningDetails>> getPlanningDetails(int planningId) async {
    try {
      final results = await _db.query(
        'SELECT * FROM PlanningDetails WHERE planning_id = ? ORDER BY date_planification',
        [planningId],
      );

      return results
          .map((row) => PlanningDetails.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Erreur récupérer planning_details: $e');
      return [];
    }
  }

  /// Mettre à jour l'état d'un détail
  Future<bool> updatePlanningDetailsEtat(
    int planningDetailsId,
    String newEtat,
  ) async {
    try {
      final result = await _db.query(
        'UPDATE PlanningDetails SET etat = ? WHERE id_planning_details = ?',
        [newEtat, planningDetailsId],
      );

      return result.isNotEmpty;
    } catch (e) {
      print('❌ Erreur mettre à jour planning_details: $e');
      return false;
    }
  }

  /// Supprimer un détail
  Future<bool> deletePlanningDetails(int planningDetailsId) async {
    try {
      final result = await _db.query(
        'DELETE FROM PlanningDetails WHERE id_planning_details = ?',
        [planningDetailsId],
      );

      return result.isNotEmpty;
    } catch (e) {
      print('❌ Erreur supprimer planning_details: $e');
      return false;
    }
  }
}
