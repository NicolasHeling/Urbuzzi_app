import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'clients_provider.dart';

class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends ConsumerState<ClientsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // AppColors.background (fallback)
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar clientes por nome ou CPF...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: clientsAsync.when(
              data: (clients) {
                final filteredClients = clients.where((client) {
                  final nameMatches = client.name.toLowerCase().contains(_searchQuery);
                  final cpfMatches = client.cpfOrCnpj?.toLowerCase().contains(_searchQuery) ?? false;
                  return nameMatches || cpfMatches;
                }).toList();

                if (filteredClients.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(clientsProvider.future),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 400,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 72, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('Nenhum item encontrado', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Não há clientes que correspondam à busca.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(clientsProvider.future),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                                    rows: filteredClients.map((client) {
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
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
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
                  ),
                );
              },
              loading: () => const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(),
              ),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
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
