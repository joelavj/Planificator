import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/index.dart';
import '../../core/theme.dart';

class HistoriqueScreen extends StatefulWidget {
  final int? clientId; // Si null, affiche tout l'historique

  const HistoriqueScreen({Key? key, this.clientId}) : super(key: key);

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  // Données fictives pour la démo
  final List<Map<String, dynamic>> _historique = [
    {
      'date': DateTime.now(),
      'action': 'Facture créée',
      'description': 'Facture #1001 pour 50 000 Ar',
      'type': 'facture',
      'icon': Icons.receipt,
      'color': AppTheme.primaryBlue,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'action': 'Client modifié',
      'description': 'Adresse mise à jour',
      'type': 'client',
      'icon': Icons.person,
      'color': AppTheme.infoBlue,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'action': 'Contrat signé',
      'description': 'Contrat #101 validé',
      'type': 'contrat',
      'icon': Icons.description,
      'color': AppTheme.successGreen,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'action': 'Paiement reçu',
      'description': 'Facture #1000 marquée comme payée',
      'type': 'paiement',
      'icon': Icons.attach_money,
      'color': AppTheme.successGreen,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'action': 'Client créé',
      'description': 'Nouveau client enregistré',
      'type': 'client',
      'icon': Icons.person_add,
      'color': Colors.orange,
    },
  ];

  late List<Map<String, dynamic>> _filtered;
  String _selectedFilter = 'tous';

  @override
  void initState() {
    super.initState();
    _applyFilter();
  }

  void _applyFilter() {
    if (_selectedFilter == 'tous') {
      _filtered = _historique;
    } else {
      _filtered = _historique
          .where((h) => h['type'] == _selectedFilter)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Télécharger l\'historique',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Téléchargement - À implémenter')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tous',
                  selected: _selectedFilter == 'tous',
                  onSelected: () {
                    setState(() {
                      _selectedFilter = 'tous';
                      _applyFilter();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Factures',
                  selected: _selectedFilter == 'facture',
                  onSelected: () {
                    setState(() {
                      _selectedFilter = 'facture';
                      _applyFilter();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Clients',
                  selected: _selectedFilter == 'client',
                  onSelected: () {
                    setState(() {
                      _selectedFilter = 'client';
                      _applyFilter();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Contrats',
                  selected: _selectedFilter == 'contrat',
                  onSelected: () {
                    setState(() {
                      _selectedFilter = 'contrat';
                      _applyFilter();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Paiements',
                  selected: _selectedFilter == 'paiement',
                  onSelected: () {
                    setState(() {
                      _selectedFilter = 'paiement';
                      _applyFilter();
                    });
                  },
                ),
              ],
            ),
          ),

          // Liste de l'historique
          Expanded(
            child: _filtered.isEmpty
                ? const EmptyStateWidget(
                    title: 'Aucun événement',
                    message: 'Aucun événement à afficher',
                    icon: Icons.history,
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final item = _filtered[index];
                      final nextItem = index < _filtered.length - 1
                          ? _filtered[index + 1]
                          : null;
                      final isNewDay =
                          nextItem == null ||
                          !isSameDay(
                            item['date'] as DateTime,
                            nextItem['date'] as DateTime,
                          );

                      return Column(
                        children: [
                          _HistoriqueCard(
                            date: item['date'] as DateTime,
                            action: item['action'] as String,
                            description: item['description'] as String,
                            icon: item['icon'] as IconData,
                            color: item['color'] as Color,
                            showConnector: index < _filtered.length - 1,
                          ),
                          if (isNewDay && index < _filtered.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey[100],
      selectedColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey[800]),
    );
  }
}

class _HistoriqueCard extends StatelessWidget {
  final DateTime date;
  final String action;
  final String description;
  final IconData icon;
  final Color color;
  final bool showConnector;

  const _HistoriqueCard({
    Key? key,
    required this.date,
    required this.action,
    required this.description,
    required this.icon,
    required this.color,
    this.showConnector = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    const iconSize = 24.0;
    const leftPadding = 50.0;

    return Stack(
      children: [
        // Ligne de temps
        if (showConnector)
          Positioned(
            left: leftPadding - 12,
            top: 50,
            bottom: 0,
            child: Container(width: 2, color: Colors.grey[300]),
          ),

        // Contenu
        Padding(
          padding: const EdgeInsets.only(
            left: leftPadding,
            right: 16,
            top: 8,
            bottom: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Point de la timeline
              Padding(
                padding: const EdgeInsets.only(left: -42),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: iconSize),
                ),
              ),

              // Informations
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            action,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            timeFormat.format(date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
