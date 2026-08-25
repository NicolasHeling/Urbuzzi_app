import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'clients_provider.dart';

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // AppColors.background (fallback)
      body: clientsAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Nenhum item encontrado', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Você ainda não cadastrou nenhum cliente.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: constraints.maxWidth - 48,
                        child: DataTable(
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          columns: const [
                            DataColumn(label: Text('Nome')),
                            DataColumn(label: Text('E-mail')),
                            DataColumn(label: Text('Telefone')),
                          ],
                          rows: clients.map((client) {
                            return DataRow(
                              cells: [
                                DataCell(Text(client.name)),
                                DataCell(Text(client.email)),
                                DataCell(Text(client.phone)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
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
          );
        },
        loading: () => const Align(
          alignment: Alignment.topCenter,
          child: LinearProgressIndicator(),
        ),
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
