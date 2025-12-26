import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';
import '../../core/theme.dart';

class ContratScreen extends StatefulWidget {
  final int? clientId; // Si null, affiche tous les contrats

  const ContratScreen({Key? key, this.clientId}) : super(key: key);

  @override
  State<ContratScreen> createState() => _ContratScreenState();
}

class _ContratScreenState extends State<ContratScreen> {
  // Données fictives pour la démo
  final List<Contrat> _contrats = [
    Contrat(
      contratId: 1,
      clientId: 1,
      dateDebut: DateTime(2024, 2, 1),
      dateFin: DateTime(2024, 12, 31),
      prix: 5000.0,
      etat: 'Actif',
    ),
    Contrat(
      contratId: 2,
      clientId: 1,
      dateDebut: DateTime(2024, 7, 1),
      dateFin: DateTime(2025, 6, 30),
      prix: 6000.0,
      etat: 'Actif',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredContrats = widget.clientId != null
        ? _contrats.where((c) => c.clientId == widget.clientId).toList()
        : _contrats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des contrats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un contrat',
            onPressed: () => _showAddContratDialog(),
          ),
        ],
      ),
      body: filteredContrats.isEmpty
          ? const EmptyStateWidget(
              title: 'Aucun contrat',
              message: 'Aucun contrat trouvé. Créez-en un pour commencer.',
              icon: Icons.description_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredContrats.length,
              itemBuilder: (context, index) {
                final contrat = filteredContrats[index];
                return _ContratCard(
                  contrat: contrat,
                  onTap: () => _showContratDetails(contrat),
                );
              },
            ),
    );
  }

  void _showAddContratDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Ajouter un contrat'),
        content: const Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showContratDetails(Contrat contrat) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contrat #${contrat.contratId}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Éditer'),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Édition - À implémenter'),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: AppTheme.errorRed,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: AppTheme.errorRed),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Prix', '${contrat.prix} Ar'),
              _buildDetailRow('État', contrat.etat),
              _buildDetailRow('Début', dateFormat.format(contrat.dateDebut)),
              _buildDetailRow('Fin', dateFormat.format(contrat.dateFin)),
              _buildDetailRow('Durée', '${contrat.durationInMonths} mois'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voir factures - À implémenter'),
                      ),
                    );
                  },
                  child: const Text('Voir factures du contrat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class _ContratCard extends StatelessWidget {
  final Contrat contrat;
  final VoidCallback onTap;

  const _ContratCard({Key? key, required this.contrat, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isActive =
        DateTime.now().isBefore(contrat.dateFin) &&
        DateTime.now().isAfter(contrat.dateDebut);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: isActive
                ? AppTheme.successGradient
                : AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isActive ? Icons.check_circle : Icons.description,
            color: Colors.white,
          ),
        ),
        title: Text('Contrat #${contrat.contratId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Du ${dateFormat.format(contrat.dateDebut)} au ${dateFormat.format(contrat.dateFin)}',
            ),
            Text(
              isActive ? 'Actif' : 'Inactif',
              style: TextStyle(
                color: isActive
                    ? AppTheme.successGreen
                    : AppTheme.warningOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Text('${contrat.durationInMonths}M'),
        onTap: onTap,
      ),
    );
  }
}
