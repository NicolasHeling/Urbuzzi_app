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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final searchField = TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar lotes...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.background,
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
                    );

                    final filterButton = OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement Status Filter Dialog or Dropdown
                      },
                      icon: const Icon(Icons.tune, size: 20),
                      label: const Text('Status'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          searchField,
                          const SizedBox(height: 12),
                          filterButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 16),
                        filterButton,
                      ],
                    );
                  },
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              
              // Table Body
              Expanded(
                child: lotsState.when(
                  data: (lots) {
                    final filteredLots = lots.where((lot) {
                      final matchesSearch = lot.block.toLowerCase().contains(_searchQuery) ||
                          lot.number.toLowerCase().contains(_searchQuery);
                      final matchesStatus = _selectedStatus == 'Todos' || lot.status == _selectedStatus;
                      return matchesSearch && matchesStatus;
                    }).toList();

                    if (filteredLots.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.inbox_outlined, size: 72, color: AppColors.border),
                            SizedBox(height: 16),
                            Text('Nenhum item encontrado', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('Não há lotes que correspondam aos filtros atuais.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ],
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(AppColors.muted.withValues(alpha: 0.6)),
                                dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return AppColors.muted.withValues(alpha: 0.3);
                                  }
                                  return null; 
                                }),
                                dividerThickness: 1,
                                horizontalMargin: 24,
                                columnSpacing: 24,
                                headingTextStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: AppColors.textSecondary,
                                ),
                                columns: const [
                                  DataColumn(label: Text('LOTEAMENTO')),
                                  DataColumn(label: Text('QUADRA')),
                                  DataColumn(label: Text('LOTE')),
                                  DataColumn(label: Text('ÁREA')),
                                  DataColumn(label: Text('VALOR')),
                                  DataColumn(label: Text('STATUS')),
                                ],
                                rows: filteredLots.map((lot) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(lot.landName ?? '-', style: const TextStyle(fontWeight: FontWeight.w500))),
                                      DataCell(Text(lot.block)),
                                      DataCell(Text(lot.number)),
                                      DataCell(Text('${lot.area} m²')),
                                      DataCell(Text(currencyFormatter.format(lot.price))),
                                      DataCell(StatusBadge(status: lot.status)),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }
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
        ),
      ),
    );
  }
}
