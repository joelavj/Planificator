/// Modèle Contrat
/// Représente un contrat associé à un client
class Contrat {
  final int contratId;
  final int clientId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final double prix;
  final String etat; // 'Actif', 'Inactif', 'Terminé'

  Contrat({
    required this.contratId,
    required this.clientId,
    required this.dateDebut,
    required this.dateFin,
    required this.prix,
    this.etat = 'Actif',
  });

  factory Contrat.fromJson(Map<String, dynamic> json) {
    return Contrat(
      contratId: json['contrat_id'] as int,
      clientId: json['client_id'] as int,
      dateDebut: DateTime.parse(json['date_debut'] as String),
      dateFin: DateTime.parse(json['date_fin'] as String),
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      etat: json['etat'] as String? ?? 'Actif',
    );
  }

  factory Contrat.fromMap(Map<String, dynamic> map) {
    return Contrat(
      contratId: map['contratId'] as int,
      clientId: map['clientId'] as int,
      dateDebut: DateTime.parse(map['dateDebut'] as String),
      dateFin: DateTime.parse(map['dateFin'] as String),
      prix: (map['prix'] as num?)?.toDouble() ?? 0.0,
      etat: map['etat'] as String? ?? 'Actif',
    );
  }

  Map<String, dynamic> toJson() => {
    'contrat_id': contratId,
    'client_id': clientId,
    'date_debut': dateDebut.toIso8601String(),
    'date_fin': dateFin.toIso8601String(),
    'prix': prix,
    'etat': etat,
  };

  /// Calcule la durée en mois
  int get durationInMonths {
    return dateFin.month -
        dateDebut.month +
        12 * (dateFin.year - dateDebut.year);
  }

  /// Vérifie si le contrat est actif
  bool get isActive {
    final now = DateTime.now();
    return dateDebut.isBefore(now) && dateFin.isAfter(now) && etat == 'Actif';
  }

  /// Copier avec quelques modifications
  Contrat copyWith({
    int? contratId,
    int? clientId,
    DateTime? dateDebut,
    DateTime? dateFin,
    double? prix,
    String? etat,
  }) {
    return Contrat(
      contratId: contratId ?? this.contratId,
      clientId: clientId ?? this.clientId,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      prix: prix ?? this.prix,
      etat: etat ?? this.etat,
    );
  }

  @override
  String toString() =>
      'Contrat(id: $contratId, clientId: $clientId, duree: $durationInMonths mois)';
}
