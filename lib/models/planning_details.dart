class PlanningDetails {
  final int? id;
  final int planningId;
  final DateTime datePlanification;
  final String etat; // 'À venir', 'Effectué', 'Décalé'
  final DateTime? dateEffective;
  final int? facturId;
  final DateTime? createdAt;

  PlanningDetails({
    this.id,
    required this.planningId,
    required this.datePlanification,
    this.etat = 'À venir',
    this.dateEffective,
    this.facturId,
    this.createdAt,
  });

  // Serialization from JSON (MySQL result)
  factory PlanningDetails.fromJson(Map<String, dynamic> json) {
    return PlanningDetails(
      id: json['id_planning_details'] ?? json['planning_details_id'],
      planningId: json['planning_id'] ?? json['id_planning'] ?? 0,
      datePlanification: json['date_planification'] != null
          ? DateTime.parse(json['date_planification'].toString())
          : DateTime.now(),
      etat: json['etat'] ?? json['status'] ?? 'À venir',
      dateEffective: json['date_effective'] != null
          ? DateTime.parse(json['date_effective'].toString())
          : null,
      facturId: json['factur_id'] ?? json['facture_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_planning_details': id,
      'planning_id': planningId,
      'date_planification': datePlanification.toIso8601String().split('T')[0],
      'etat': etat,
      'date_effective': dateEffective?.toIso8601String().split('T')[0],
      'factur_id': facturId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return datePlanification.year == now.year &&
        datePlanification.month == now.month &&
        datePlanification.day == now.day;
  }

  // Check if date is upcoming
  bool get isUpcoming => datePlanification.isAfter(DateTime.now());

  // Check if overdue
  bool get isOverdue =>
      etat == 'À venir' && datePlanification.isBefore(DateTime.now());

  @override
  String toString() =>
      'PlanningDetails(id: $id, planning: $planningId, date: $datePlanification, etat: $etat)';
}
