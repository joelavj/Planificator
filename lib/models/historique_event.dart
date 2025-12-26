class HistoriqueEvent {
  final int historiqueId;
  final String type; // 'client', 'facture', 'contrat', 'paiement', 'autre'
  final String description;
  final DateTime date;
  final String details; // JSON ou format clé:valeur

  HistoriqueEvent({
    required this.historiqueId,
    required this.type,
    required this.description,
    required this.date,
    required this.details,
  });

  factory HistoriqueEvent.fromMap(Map<String, dynamic> map) {
    return HistoriqueEvent(
      historiqueId: map['historiqueId'] as int,
      type: map['type'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      details: map['details'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'historiqueId': historiqueId,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'details': details,
    };
  }

  @override
  String toString() {
    return 'HistoriqueEvent(historiqueId: $historiqueId, type: $type, description: $description, date: $date)';
  }

  /// Icône basée sur le type
  String get icon {
    switch (type) {
      case 'client':
        return '👤';
      case 'facture':
        return '📄';
      case 'contrat':
        return '📋';
      case 'paiement':
        return '💰';
      default:
        return '📌';
    }
  }

  /// Couleur basée sur le type
  int get colorValue {
    switch (type) {
      case 'client':
        return 0xFF2196F3; // Bleu
      case 'facture':
        return 0xFF4CAF50; // Vert
      case 'contrat':
        return 0xFFFFC107; // Orange
      case 'paiement':
        return 0xFF8BC34A; // Vert clair
      default:
        return 0xFF757575; // Gris
    }
  }

  /// Format de date lisible
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} minute(s)';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour(s)';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Temps exact (HH:mm)
  String get timeString {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Si l'événement est d'aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Si l'événement est récent (moins de 24h)
  bool get isRecent {
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    return date.isAfter(oneDayAgo);
  }
}
