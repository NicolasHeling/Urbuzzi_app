import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Urbuzzi - Mapa Interativo')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.maps_home_work, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text('Menu Urbuzzi', style: TextStyle(color: Colors.white, fontSize: 24)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Mapa Interativo (Home)'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('CRM de Clientes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/clients');
              },
            ),
            ListTile(
              leading: const Icon(Icons.landscape),
              title: const Text('Lista de Lotes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/lots');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Propostas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/proposals');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Auditoria'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/audit');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Mapa Interativo (Home) - Implementação SVG será aqui', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
