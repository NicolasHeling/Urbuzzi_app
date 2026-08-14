import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'clients_provider.dart';

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Clientes')),
      body: clientsAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return const Center(child: Text('Nenhum cliente cadastrado.'));
          }
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(client.name),
                subtitle: Text('${client.email} \n${client.phone}'),
                isThreeLine: true,
                onTap: () {
                  // Pode abrir detalhes do cliente futuramente
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/clients/new').then((_) {
            // Atualiza a lista quando voltar da tela de criação
            ref.refresh(clientsProvider);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
