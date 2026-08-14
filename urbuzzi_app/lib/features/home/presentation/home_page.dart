import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../lots/presentation/lots_provider.dart';
import '../../lots/domain/models/lot.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

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
      default:
        return Colors.grey.shade300;
    }
  }

  void _showLotDetails(BuildContext context, Lot lot) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quadra ${lot.block} - Lote ${lot.number}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Chip(
                    backgroundColor: _getStatusColor(lot.status).withOpacity(0.2),
                    label: Text(lot.status),
                    labelStyle: TextStyle(
                      color: _getStatusColor(lot.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Área: ${lot.area} m²'),
              const SizedBox(height: 8),
              Text(
                'Valor: ${currencyFormatter.format(lot.price)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsState = ref.watch(lotsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Interativo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Loteamento Bela Vista', // Mock name
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
      body: lotsState.when(
        data: (lots) {
          final Map<String, int> counts = {
            'Disponível': 0,
            'Reservado': 0,
            'Em aprovação': 0,
            'Bloqueado': 0,
            'Vendido': 0,
          };
          for (var lot in lots) {
            counts[lot.status] = (counts[lot.status] ?? 0) + 1;
          }

          return Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(32),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: lots.length,
                    itemBuilder: (context, index) {
                      final lot = lots[index];
                      return GestureDetector(
                        onTap: () => _showLotDetails(context, lot),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getStatusColor(lot.status),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Center(
                            child: Text(
                              lot.number,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: counts.keys.map((status) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('$status (${counts[status]})', style: const TextStyle(fontSize: 12)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}
