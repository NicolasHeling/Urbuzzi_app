import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'tasks_provider.dart';
import '../../crm/presentation/clients_provider.dart';

class AgendaPage extends ConsumerWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Agenda de Visitas', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('Nenhuma visita agendada.', style: TextStyle(color: Colors.grey, fontSize: 16)));
          }

          final todayTasks = tasks.where((t) => t.date == todayStr).toList();
          final tomorrowTasks = tasks.where((t) => t.date == tomorrowStr).toList();
          final futureTasks = tasks.where((t) => t.date.compareTo(tomorrowStr) > 0).toList();
          final pastTasks = tasks.where((t) => t.date.compareTo(todayStr) < 0).toList();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (todayTasks.isNotEmpty) ...[
                const Text('Hoje', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),
                ...todayTasks.map((t) => _TaskCard(task: t, clients: clientsAsync.valueOrNull)),
                const SizedBox(height: 24),
              ],
              if (tomorrowTasks.isNotEmpty) ...[
                const Text('Amanhã', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),
                ...tomorrowTasks.map((t) => _TaskCard(task: t, clients: clientsAsync.valueOrNull)),
                const SizedBox(height: 24),
              ],
              if (futureTasks.isNotEmpty) ...[
                const Text('Próximos Dias', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),
                ...futureTasks.map((t) => _TaskCard(task: t, clients: clientsAsync.valueOrNull)),
                const SizedBox(height: 24),
              ],
              if (pastTasks.isNotEmpty) ...[
                const Text('Anteriores (Atrasados)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                const SizedBox(height: 12),
                ...pastTasks.map((t) => _TaskCard(task: t, clients: clientsAsync.valueOrNull)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar agenda: $e')),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final dynamic task;
  final dynamic clients;

  const _TaskCard({required this.task, this.clients});

  @override
  Widget build(BuildContext context) {
    String clientName = 'Cliente não encontrado';
    if (clients != null) {
      try {
        final client = clients.firstWhere((c) => c.id == task.clientId);
        clientName = client.name;
      } catch (_) {}
    }

    // Format date nicely if not today/tomorrow
    DateTime? parsedDate = DateTime.tryParse(task.date);
    String displayDate = parsedDate != null ? DateFormat('dd/MM').format(parsedDate) : task.date;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
          child: const Icon(Icons.event, color: Colors.blue),
        ),
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('$clientName \nData: $displayDate às ${task.time}', style: TextStyle(color: Colors.grey.shade700)),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: task.status == 'Pendente' ? Colors.orange.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(task.status, style: TextStyle(
            color: task.status == 'Pendente' ? Colors.orange.shade700 : Colors.green.shade700,
            fontWeight: FontWeight.bold,
          )),
        ),
      ),
    );
  }
}
