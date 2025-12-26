class PlanningEvent {
  final int planningId;
  final int contratId;
  final String titre;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;

  PlanningEvent({
    required this.planningId,
    required this.contratId,
    required this.titre,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
  });

  factory PlanningEvent.fromMap(Map<String, dynamic> map) {
    return PlanningEvent(
      planningId: map['planningId'] as int,
      contratId: map['contratId'] as int,
      titre: map['titre'] as String,
      description: map['description'] as String,
      dateDebut: DateTime.parse(map['dateDebut'] as String),
      dateFin: DateTime.parse(map['dateFin'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planningId': planningId,
      'contratId': contratId,
      'titre': titre,
      'description': description,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
    };
  }

  PlanningEvent copyWith({
    int? planningId,
    int? contratId,
    String? titre,
    String? description,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) {
    return PlanningEvent(
      planningId: planningId ?? this.planningId,
      contratId: contratId ?? this.contratId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
    );
  }

  @override
  String toString() {
    return 'PlanningEvent(planningId: $planningId, contratId: $contratId, titre: $titre, dateDebut: $dateDebut)';
  }

  /// Durée en heures
  Duration get duration => dateFin.difference(dateDebut);

  /// Si l'événement est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return dateDebut.year == now.year &&
        dateDebut.month == now.month &&
        dateDebut.day == now.day;
  }

  /// Si l'événement est en cours
  bool get isOngoing {
    final now = DateTime.now();
    return dateDebut.isBefore(now) && dateFin.isAfter(now);
  }

  /// Si l'événement est passé
  bool get isPast => dateFin.isBefore(DateTime.now());

  /// Si l'événement est à venir
  bool get isUpcoming => dateDebut.isAfter(DateTime.now());
}
