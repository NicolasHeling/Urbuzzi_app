import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'lots_provider.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Lista de Lotes', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
            onPressed: () {
              ref.read(lotsControllerProvider.notifier).fetchLots();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por quadra ou número...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: _getStatusColor(status).withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? _getStatusColor(status).withOpacity(0.5) : Colors.grey.shade200,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? _getStatusColor(status) : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Text(
                        '${filteredLots.length} lotes encontrados',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        itemCount: filteredLots.length,
                        itemBuilder: (context, index) {
                          final lot = filteredLots[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Loteamento Morada do Sol',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lote ${lot.number} · Quadra ${lot.block}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(lot.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: _getStatusColor(lot.status).withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        lot.status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getStatusColor(lot.status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(height: 1),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.straighten, size: 16, color: Colors.grey.shade400),
                                        const SizedBox(width: 8),
                                        Text('${lot.area} m²', style: const TextStyle(fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    Text(
                                      currencyFormatter.format(lot.price),
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: lot.status == 'Disponível'
                                          ? FilledButton.icon(
                                              onPressed: () async {
                                                final success = await showReservationDialog(context, lot);
                                                if (success == true) {
                                                  ref.read(lotsControllerProvider.notifier).fetchLots();
                                                }
                                              },
                                              icon: const Icon(Icons.bookmark_add, size: 18),
                                              label: const Text('Reservar Lote', style: TextStyle(fontWeight: FontWeight.w600)),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: const Color(0xFF0F172A),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                              ),
                                            )
                                          : OutlinedButton(
                                              onPressed: () {
                                                ref.read(lotsControllerProvider.notifier).updateLotStatus(lot.id, 'Disponível');
                                              },
                                              style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                side: BorderSide(color: Colors.grey.shade300),
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                foregroundColor: const Color(0xFF0F172A),
                                              ),
                                              child: const Text('Tornar Disponível', style: TextStyle(fontWeight: FontWeight.w600)),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
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
