import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/lots/presentation/lots_list_page.dart';
import '../../features/proposals/presentation/proposals_page.dart';
import '../../features/audit/presentation/audit_page.dart';
import '../../features/vitrine/presentation/vitrine_page.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    LotsListPage(),
    ProposalsPage(),
    AuditPage(),
    VitrinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: NavigationRail(
              backgroundColor: Colors.white,
              extended: MediaQuery.of(context).size.width > 800,
              minExtendedWidth: 240,
              unselectedLabelTextStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              selectedLabelTextStyle: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
              unselectedIconTheme: IconThemeData(color: Colors.grey.shade500),
              selectedIconTheme: const IconThemeData(color: Color(0xFF0F172A)),
              useIndicator: true,
              indicatorColor: Colors.grey.shade100,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.maps_home_work, size: 28, color: Colors.blue),
                        ),
                        if (MediaQuery.of(context).size.width > 800) ...[
                          const SizedBox(width: 12),
                          const Text(
                            'Urbuzzi',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (MediaQuery.of(context).size.width > 800)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          'Gestão',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: Text('Mapa Interativo'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.list_alt_outlined),
                  selectedIcon: Icon(Icons.list_alt),
                  label: Text('Lista de Lotes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Propostas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: Text('Histórico'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: Text('Vitrine Pública'),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      color: Colors.grey.shade500,
                      tooltip: 'Sair',
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
