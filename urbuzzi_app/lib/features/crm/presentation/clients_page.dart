import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'clients_provider.dart';
import '../models/client.dart';
import '../../proposals/presentation/proposals_provider.dart';
import '../../reservations/presentation/reservations_provider.dart';
import '../../agenda/presentation/tasks_provider.dart';

class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends ConsumerState<ClientsPage> {
  String _searchQuery = '';
  bool _isKanbanMode = false;

  void _showClientProfile(Client client) {
    showDialog(
      context: context,
      builder: (context) => _ClientProfileDialog(client: client),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
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
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),
                ToggleButtons(
                  isSelected: [!_isKanbanMode, _isKanbanMode],
                  onPressed: (index) => setState(() => _isKanbanMode = index == 1),
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Icon(Icons.list), SizedBox(width: 8), Text('Lista')])),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Icon(Icons.view_kanban), SizedBox(width: 8), Text('Kanban')])),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: clientsAsync.when(
              data: (clients) {
                final filteredClients = clients.where((client) {
                  final nameMatches = client.name.toLowerCase().contains(_searchQuery);
                  final cpfMatches = client.cpfOrCnpj.toLowerCase().contains(_searchQuery);
                  return nameMatches || cpfMatches;
                }).toList();

                if (filteredClients.isEmpty) {
                  return _buildEmptyState();
                }

                if (_isKanbanMode) {
                  return _buildKanbanBoard(filteredClients);
                }

                return _buildListView(filteredClients, context);
              },
              loading: () => const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/clients/new').then((_) {
            ref.read(clientsProvider.notifier).fetchClients();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async => ref.read(clientsProvider.notifier).fetchClients(),
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

  Widget _buildListView(List<Client> filteredClients, BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => ref.read(clientsProvider.notifier).fetchClients(),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: constraints.maxWidth - 48,
                      child: DataTable(
                        showCheckboxColumn: false,
                        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        columns: const [
                          DataColumn(label: Text('Nome')),
                          DataColumn(label: Text('Documento / Origem')),
                          DataColumn(label: Text('E-mail')),
                          DataColumn(label: Text('Telefone')),
                          DataColumn(label: Text('Estágio')),
                        ],
                        rows: filteredClients.map((client) {
                          final isLead = client.cpfOrCnpj.startsWith('LEAD-');
                          return DataRow(
                            onSelectChanged: (_) => _showClientProfile(client),
                            cells: [
                              DataCell(Text(client.name)),
                              DataCell(
                                isLead 
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
                                      child: const Text('Vitrine (Lead)', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                                    )
                                  : Text(client.cpfOrCnpj),
                              ),
                              DataCell(Text(client.email)),
                              DataCell(Text(client.phone)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                                  child: Text(client.funnelStage ?? 'Novo', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                                )
                              ),
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
                subtitle: Text('${client.email} \n${client.phone}\nEstágio: ${client.funnelStage ?? "Novo"}'),
                isThreeLine: true,
                onTap: () => _showClientProfile(client),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildKanbanBoard(List<Client> clients) {
    const stages = ['Novo', 'Contato', 'Visita', 'Proposta'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: stages.map((stage) {
          final stageClients = clients.where((c) => (c.funnelStage ?? 'Novo') == stage).toList();
          return Expanded(
            child: _KanbanColumn(
              stage: stage,
              clients: stageClients,
              onDrop: (clientId) {
                ref.read(clientsProvider.notifier).updateStage(clientId, stage);
              },
              onClientTap: _showClientProfile,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String stage;
  final List<Client> clients;
  final Function(String) onDrop;
  final Function(Client) onClientTap;

  const _KanbanColumn({
    required this.stage,
    required this.clients,
    required this.onDrop,
    required this.onClientTap,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        onDrop(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(stage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                    child: Text('${clients.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return Draggable<String>(
                      data: client.id,
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: _KanbanCard(client: client, width: 250),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: _KanbanCard(client: client),
                      ),
                      child: GestureDetector(
                        onTap: () => onClientTap(client),
                        child: _KanbanCard(client: client),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Client client;
  final double? width;
  const _KanbanCard({required this.client, this.width});

  @override
  Widget build(BuildContext context) {
    final isLead = client.cpfOrCnpj.startsWith('LEAD-');
    return Container(
      width: width,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (isLead) const Icon(Icons.language, size: 14, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(client.phone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientProfileDialog extends ConsumerWidget {
  final Client client;
  
  const _ClientProfileDialog({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isLead = client.cpfOrCnpj.startsWith('LEAD-');

    final proposalsState = ref.watch(proposalsControllerProvider);
    final clientProposals = proposalsState.valueOrNull?.where((p) => p.customerDocument == client.cpfOrCnpj).toList() ?? [];

    final reservationsState = ref.watch(pendingReservationsProvider);
    final clientReservations = reservationsState.valueOrNull?.where((r) => r.clientId == client.id).toList() ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 32, backgroundColor: const Color(0xFF1E293B), child: Text(client.name[0].toUpperCase(), style: const TextStyle(fontSize: 24, color: Colors.white))),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(client.email, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(width: 16),
                            const Icon(Icons.phone, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(client.phone, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showScheduleModal(context, ref, client),
                      icon: const Icon(Icons.event, size: 18),
                      label: const Text('Agendar Visita'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isLead)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.language, size: 16, color: Colors.blue),
                        SizedBox(width: 6),
                        Text('Lead da Vitrine (Público)', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.badge, size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text('Documento: ${client.cpfOrCnpj}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                const SizedBox(width: 12),
                if (client.createdAt != null)
                  Text('Cadastrado em: ${DateFormat('dd/MM/yyyy HH:mm').format(client.createdAt!.toLocal())}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TabBar(
                      labelColor: Color(0xFF1E293B),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color(0xFF1E293B),
                      tabs: [
                        Tab(text: 'Propostas de Compra'),
                        Tab(text: 'Reservas (Meio do Funil)'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          clientProposals.isEmpty
                            ? const Center(child: Text('Nenhuma proposta vinculada.', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.only(top: 16),
                                itemCount: clientProposals.length,
                                itemBuilder: (context, index) {
                                  final p = clientProposals[index];
                                  return Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
                                    child: ListTile(
                                      leading: const Icon(Icons.request_page, color: Color(0xFF1E293B)),
                                      title: Text('Proposta no Lote ${p.lot?['number'] ?? '-'} (Qd ${p.lot?['block'] ?? '-'})'),
                                      subtitle: Text('${DateFormat('dd/MM/yyyy').format(p.createdAt)} - Corretor: ${p.responsibleUserName ?? 'N/A'}'),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(p.offeredPrice != null ? currencyFormatter.format(p.offeredPrice) : 'Valor Padrão', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(p.status, style: TextStyle(color: p.status == 'Concluída' ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          clientReservations.isEmpty
                            ? const Center(child: Text('Nenhuma reserva ativa vinculada.', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.only(top: 16),
                                itemCount: clientReservations.length,
                                itemBuilder: (context, index) {
                                  final r = clientReservations[index];
                                  return Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
                                    child: ListTile(
                                      leading: const Icon(Icons.lock_clock, color: Colors.orange),
                                      title: Text('Reserva no Lote ${r.lot?.number ?? '-'} (Qd ${r.lot?.block ?? '-'})'),
                                      subtitle: Text('Expira em: ${r.expirationDate != null ? DateFormat('dd/MM/yyyy HH:mm').format(r.expirationDate!.toLocal()) : 'N/A'}'),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                                        child: Text(r.status ?? 'PENDING', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleModal(BuildContext context, WidgetRef ref, Client client) {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Agendar Visita"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Descrição (Ex: Visita ao Lote 12)")),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: "Data (YYYY-MM-DD)")),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Hora (HH:MM)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(tasksProvider.notifier).createTask(
                  title: titleCtrl.text,
                  date: dateCtrl.text,
                  time: timeCtrl.text,
                  clientId: client.id,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Visita agendada com sucesso!")));
                }
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Agendar"),
          ),
        ],
      ),
    ).then((_) {
      titleCtrl.dispose();
      dateCtrl.dispose();
      timeCtrl.dispose();
    });
  }
}

