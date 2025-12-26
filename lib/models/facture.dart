/// Modèle Facture
/// Représente une facture pour un traitement
class Facture {
  final int factureId;
  final DateTime date;
  final double montant;
  final String etat; // 'Payé' ou 'Non payé'

  Facture({
    required this.factureId,
    required this.date,
    required this.montant,
    required this.etat,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      factureId: json['facture_id'] as int,
      date: DateTime.parse(json['date'] as String),
      montant: (json['montant'] as num).toDouble(),
      etat: json['etat'] as String? ?? 'Non payé',
    );
  }

  factory Facture.fromMap(Map<String, dynamic> map) {
    return Facture(
      factureId: map['factureId'] as int,
      date: DateTime.parse(map['date'] as String),
      montant: (map['montant'] as num).toDouble(),
      etat: map['etat'] as String? ?? 'Non payé',
    );
  }

  Map<String, dynamic> toJson() => {
    'facture_id': factureId,
    'date': date.toIso8601String(),
    'montant': montant,
    'etat': etat,
  };

  /// Format montant avec séparateur de milliers
  String get montantFormatted {
    final formatter = _NumberFormatter();
    return '${formatter.format(montant.toInt())} Ar';
  }

  /// Est payée ?
  bool get isPaid => etat == 'Payé' || etat == 'Payée';

  Facture copyWith({
    int? factureId,
    DateTime? date,
    double? montant,
    String? etat,
  }) {
    return Facture(
      factureId: factureId ?? this.factureId,
      date: date ?? this.date,
      montant: montant ?? this.montant,
      etat: etat ?? this.etat,
    );
  }

  @override
  String toString() =>
      'Facture(id: $factureId, montant: $montantFormatted, etat: $etat)';
}

/// Utilitaire pour formatter les nombres
class _NumberFormatter {
  String format(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match match) => ' ',
    );
  }
}
