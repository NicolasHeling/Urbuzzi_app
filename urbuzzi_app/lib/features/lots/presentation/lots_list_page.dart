import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'lots_provider.dart';
import '../../reservations/presentation/reservation_dialog.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/justification_dialog.dart';
import '../../auth/presentation/auth_provider.dart';

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
    ...AppColors.statusOrder
  ];

  @override
  Widget build(BuildContext context) {
    final lotsState = ref.watch(lotsControllerProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por quadra ou número...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
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
                final statusColor = status == 'Todos' ? AppColors.textPrimary : AppColors.statusColor(status);
                final statusBgColor = status == 'Todos' ? AppColors.textPrimary.withValues(alpha: 0.08) : AppColors.statusColor(status).withValues(alpha: 0.08);

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
                    backgroundColor: AppColors.surface,
                    selectedColor: statusBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? statusColor.withValues(alpha: 0.35) : AppColors.border,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? statusColor : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                        '${filteredLots.length} de ${lots.length} lotes exibidos',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: filteredLots.isEmpty 
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inbox_outlined, size: 72, color: AppColors.border),
                                const SizedBox(height: 16),
                                const Text('Nenhum item encontrado', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text('Não há lotes que correspondam aos filtros atuais.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              ],
                            ),
                          )
                        : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        itemCount: filteredLots.length,
                        itemBuilder: (context, index) {
                          final lot = filteredLots[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
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
                                          lot.landName ?? 'Loteamento',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lote ${lot.number} · Quadra ${lot.block}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    StatusBadge(status: lot.status),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(color: AppColors.border, height: 1),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.straighten, size: 16, color: AppColors.textMuted),
                                        const SizedBox(width: 8),
                                        Text('${lot.area} m²', style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                      ],
                                    ),
                                    Text(
                                      currencyFormatter.format(lot.price),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    if (lot.status == 'Disponível') ...[
                                      if (userRole.canWrite)
                                        Expanded(
                                          child: FilledButton.icon(
                                            onPressed: () async {
                                              final success = await showReservationDialog(context, lot);
                                              if (success == true) {
                                                ref.read(lotsControllerProvider.notifier).fetchLots();
                                              }
                                            },
                                            icon: const Icon(Icons.bookmark_add, size: 18),
                                            label: const Text('Reservar Lote', style: TextStyle(fontWeight: FontWeight.w600)),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: AppColors.primaryForeground,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                            ),
                                          ),
                                        ),
                                    ] else ...[
                                      if (userRole.canApprove)
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              final justification = await showJustificationDialog(context, 'Tornar Disponível');
                                              if (justification != null) {
                                                ref.read(lotsControllerProvider.notifier).updateLotStatus(
                                                  lot.id, 
                                                  'Disponível',
                                                  justification: justification,
                                                );
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              side: const BorderSide(color: AppColors.border),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              foregroundColor: AppColors.textPrimary,
                                            ),
                                            child: const Text('Tornar Disponível', style: TextStyle(fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                    ],
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
              loading: () => const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stack) => Center(child: Text('Erro: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
