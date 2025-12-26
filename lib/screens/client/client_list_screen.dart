import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';
import '../../widgets/index.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({Key? key}) : super(key: key);

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Charger les clients
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientService>().loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un client',
            onPressed: () => _showAddClientDialog(context),
          ),
        ],
      ),
      body: Consumer<ClientService>(
        builder: (context, service, _) {
          // État de chargement
          if (service.isLoading) {
            return const LoadingWidget(message: 'Chargement des clients...');
          }

          // État d'erreur
          if (service.errorMessage != null) {
            return ErrorDisplayWidget(
              message: service.errorMessage!,
              onRetry: () => service.loadClients(),
            );
          }

          // État vide
          if (service.clients.isEmpty) {
            return const EmptyStateWidget(
              title: 'Aucun client',
              message: 'Aucun client trouvé. Commencez par créer un client.',
              icon: Icons.people_outline,
              actionLabel: 'Ajouter un client',
            );
          }

          return Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un client...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              service.loadClients();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (query) {
                    setState(() {}); // Mettre à jour le suffixIcon
                    if (query.isEmpty) {
                      service.loadClients();
                    } else {
                      service.searchClients(query);
                    }
                  },
                ),
              ),

              // Nombre de résultats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${service.clients.length} client(s) trouvé(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),

              // Liste des clients
              Expanded(
                child: ListView.builder(
                  itemCount: service.clients.length,
                  itemBuilder: (context, index) {
                    final client = service.clients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            client.fullName.isNotEmpty
                                ? client.fullName[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(client.fullName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(client.email),
                            if (client.telephone.isNotEmpty)
                              Text(client.telephone),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.visibility, size: 18),
                                  SizedBox(width: 8),
                                  Text('Voir'),
                                ],
                              ),
                              onTap: () {
                                _showClientDetails(context, client);
                              },
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Éditer'),
                                ],
                              ),
                              onTap: () {
                                _showEditClientDialog(context, client);
                              },
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Supprimer',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showDeleteConfirmation(
                                  context,
                                  service,
                                  client.clientId,
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _showClientDetails(context, client);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Ajouter un client'),
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

  void _showEditClientDialog(BuildContext context, client) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Éditer un client'),
        content: const Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showClientDetails(BuildContext context, client) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails du client',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Nom', client.fullName),
              _buildDetailRow('Email', client.email),
              _buildDetailRow('Téléphone', client.telephone),
              _buildDetailRow('Adresse', client.adresse),
              _buildDetailRow('Catégorie', client.categorie),
              _buildDetailRow('NIF', client.nif),
              _buildDetailRow('STAT', client.stat),
              _buildDetailRow('Axe', client.axe),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : '-')),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ClientService service,
    int clientId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce client ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              service.deleteClient(clientId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Client supprimé')));
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
