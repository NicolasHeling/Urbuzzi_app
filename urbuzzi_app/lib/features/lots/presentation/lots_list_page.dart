import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'lots_provider.dart';
import '../domain/models/lot.dart';
import '../../reservations/presentation/reservation_dialog.dart';

class LotsListPage extends ConsumerStatefulWidget {
  const LotsListPage({super.key});

  @override
  ConsumerState<LotsListPage> createState() => _LotsListPageState();
}

class _LotsListPageState extends ConsumerState<LotsListPage> {
  String _searchQuery = '';
  String _selectedStatus = 'Todos';

  final List<String> _statuses = [
    'Todos',
    'Disponível',
    'Reservado',
    'Em aprovação',
    'Bloqueado',
    'Vendido',
    'Cancelado'
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disponível':
        return Colors.green;
      case 'Reservado':
        return Colors.orange;
      case 'Em aprovação':
        return Colors.yellow.shade700;
      case 'Bloqueado':
        return Colors.grey;
      case 'Vendido':
        return Colors.red;
      case 'Cancelado':
        return Colors.white;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getTextColor(String status) {
    if (status == 'Cancelado' || status == 'Em aprovação') {
      return Colors.black87;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final lotsState = ref.watch(lotsControllerProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Lotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(lotsControllerProvider.notifier).fetchLots();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Buscar por quadra ou número...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    backgroundColor: status == 'Todos' ? null : _getStatusColor(status).withOpacity(0.2),
                    selectedColor: status == 'Todos' ? Theme.of(context).colorScheme.primaryContainer : _getStatusColor(status),
                    labelStyle: TextStyle(
                      color: isSelected && status != 'Todos' ? _getTextColor(status) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: lotsState.when(
              data: (lots) {
                final filteredLots = lots.where((lot) {
                  final matchesSearch = lot.block.toLowerCase().contains(_searchQuery) ||
                      lot.number.toLowerCase().contains(_searchQuery);
                  final matchesStatus = _selectedStatus == 'Todos' || lot.status == _selectedStatus;
                  return matchesSearch && matchesStatus;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        '${filteredLots.length} de ${lots.length} lotes exibidos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredLots.length,
                        itemBuilder: (context, index) {
                          final lot = filteredLots[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Quadra ${lot.block} - Lote ${lot.number}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(lot.status),
                                          borderRadius: BorderRadius.circular(12),
                                          border: lot.status == 'Cancelado' ? Border.all(color: Colors.grey) : null,
                                        ),
                                        child: Text(
                                          lot.status,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getTextColor(lot.status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Área: ${lot.area}m² | Preço: ${currencyFormatter.format(lot.price)}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (lot.status == 'Disponível')
                                        FilledButton.icon(
                                          onPressed: () async {
                                            final success = await showReservationDialog(context, lot);
                                            if (success == true) {
                                              ref.read(lotsControllerProvider.notifier).fetchLots();
                                            }
                                          },
                                          icon: const Icon(Icons.bookmark_add, size: 18),
                                          label: const Text('Reservar'),
                                        ),
                                      if (lot.status != 'Disponível')
                                        OutlinedButton(
                                          onPressed: () {
                                            ref.read(lotsControllerProvider.notifier).updateLotStatus(lot.id, 'Disponível');
                                          },
                                          child: const Text('Tornar Disponível'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erro: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
