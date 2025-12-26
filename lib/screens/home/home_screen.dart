import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';
import '../../core/theme.dart';
import '../client/client_list_screen.dart';
import '../facture/facture_list_screen.dart';
import '../contrat/contrat_screen.dart';
import '../planning/planning_screen.dart';
import '../historique/historique_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientService>().loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Planificator 1.1.0'),
          elevation: 0,
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            _DashboardTab(),
            ClientListScreen(),
            FactureListScreen(),
            ContratScreen(),
            PlanningScreen(),
            HistoriqueScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Factures',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Contrats',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Planning'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historique',
            ),
          ],
        ),
        drawer: _buildDrawer(context),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                accountName: Text(user?.fullName ?? 'Utilisateur'),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.fullName.isNotEmpty == true
                        ? user!.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.home,
                title: 'Accueil',
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.people,
                title: 'Clients',
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.receipt,
                title: 'Factures',
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.description,
                title: 'Contrats',
                onTap: () {
                  setState(() => _selectedIndex = 3);
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.event,
                title: 'Planning',
                onTap: () {
                  setState(() => _selectedIndex = 4);
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.history,
                title: 'Historique',
                onTap: () {
                  setState(() => _selectedIndex = 5);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Paramètres',
                onTap: () {
                  setState(() => _selectedIndex = 6);
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Déconnexion',
                textColor: AppTheme.errorRed,
                onTap: () {
                  Navigator.pop(context);
                  _logout(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  void _logout(BuildContext context) {
    AppDialogs.confirm(
      context,
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      confirmText: 'Déconnexion',
      cancelText: 'Annuler',
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<AuthService>().logout();
      }
    });
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, ClientService>(
      builder: (context, authService, clientService, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _WelcomeCard(
                userName: authService.currentUser?.fullName ?? 'Utilisateur',
                isAdmin: authService.currentUser?.isAdmin ?? false,
              ),
              const SizedBox(height: 24),

              // Statistics Section
              Text(
                'Statistiques',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _buildStatisticsCards(clientService),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Actions rapides',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCards(ClientService clientService) {
    final clientCount = clientService.clients.length;

    return Row(
      children: [
        Expanded(
          child: _StatisticCard(
            title: 'Clients',
            value: clientCount.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatisticCard(
            title: 'Factures',
            value: '12', // À implémenter
            icon: Icons.receipt,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Liste des clients - À implémenter'),
              ),
            ),
            icon: const Icon(Icons.people),
            label: const Text('Voir tous les clients'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ajouter un client - À implémenter'),
              ),
            ),
            icon: const Icon(Icons.person_add),
            label: const Text('Ajouter un client'),
          ),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String userName;
  final bool isAdmin;

  const _WelcomeCard({Key? key, required this.userName, required this.isAdmin})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue, $userName!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isAdmin ? 'Administrateur' : 'Utilisateur standard',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// Placeholder tabs à implémenter
class _ClientsTabStub extends StatelessWidget {
  const _ClientsTabStub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: 'Clients',
      message: 'La gestion des clients sera bientôt disponible',
      icon: Icons.people_outline,
    );
  }
}

class _FacturesTabStub extends StatelessWidget {
  const _FacturesTabStub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: 'Factures',
      message: 'La gestion des factures sera bientôt disponible',
      icon: Icons.receipt_outlined,
    );
  }
}

class _SettingsTabStub extends StatelessWidget {
  const _SettingsTabStub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: 'Paramètres',
      message: 'Les paramètres seront bientôt disponibles',
      icon: Icons.settings_outlined,
    );
  }
}
