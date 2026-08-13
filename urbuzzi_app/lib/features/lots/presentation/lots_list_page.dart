import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lots_provider.dart';
import '../domain/models/lot.dart';

class LotsListPage extends ConsumerWidget {
  const LotsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsState = ref.watch(lotsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Lotes (Urbuzzi)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(lotsControllerProvider.notifier).fetchLots();
            },
          )
        ],
      ),
      body: lotsState.when(
        data: (lots) => _buildLotsList(context, ref, lots),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro ao carregar lotes:\n$error', textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildLotsList(BuildContext context, WidgetRef ref, List<Lot> lots) {
    if (lots.isEmpty) {
      return const Center(child: Text('Nenhum lote cadastrado no momento.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lots.length,
      itemBuilder: (context, index) {
        final lot = lots[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(lot.status),
              child: Icon(_getStatusIcon(lot.status), color: Colors.white),
            ),
            title: Text('Quadra ${lot.block} - Lote ${lot.number}'),
            subtitle: Text('Área: ${lot.area}m² | Preço: R\$ ${lot.price.toStringAsFixed(2)}'),
            trailing: PopupMenuButton<String>(
              onSelected: (newStatus) {
                ref.read(lotsControllerProvider.notifier).updateLotStatus(lot.id, newStatus);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Disponível', child: Text('Marcar Disponível')),
                const PopupMenuItem(value: 'Reservado', child: Text('Marcar Reservado')),
                const PopupMenuItem(value: 'Vendido', child: Text('Marcar Vendido')),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disponível':
        return Colors.green;
      case 'Reservado':
        return Colors.orange;
      case 'Vendido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Disponível':
        return Icons.check_circle;
      case 'Reservado':
        return Icons.access_time_filled;
      case 'Vendido':
        return Icons.monetization_on;
      default:
        return Icons.help;
    }
  }
}
