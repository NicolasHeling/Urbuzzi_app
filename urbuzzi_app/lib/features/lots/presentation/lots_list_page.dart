import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'lots_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';

class LotsListPage extends ConsumerStatefulWidget {
  const LotsListPage({super.key});

  @override
  ConsumerState<LotsListPage> createState() => _LotsListPageState();
}

class _LotsListPageState extends ConsumerState<LotsListPage> {
  final List<String> _statuses = [
    'Todos',
    ...AppColors.statusOrder
  ];

  @override
  Widget build(BuildContext context) {
    final lotsState = ref.watch(lotsControllerProvider);
    final controller = ref.read(lotsControllerProvider.notifier);
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
                        controller.setSearchQuery(value);
                      },
                    );

                    final filterDropdown = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedStatus,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                          items: _statuses.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status, style: const TextStyle(color: AppColors.textPrimary)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.setStatusFilter(newValue);
                            }
                          },
                        ),
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          searchField,
                          const SizedBox(height: 12),
                          filterDropdown,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 16),
                        filterDropdown,
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
                    if (lots.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => ref.read(lotsControllerProvider.notifier).fetchLots(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: 400,
                            alignment: Alignment.center,
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
                          ),
                        ),
                      );
                    }

                    final controller = ref.read(lotsControllerProvider.notifier);

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return RefreshIndicator(
                          onRefresh: () => ref.read(lotsControllerProvider.notifier).fetchLots(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
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
                                      rows: lots.map((lot) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(lot.landName ?? '-', style: const TextStyle(fontWeight: FontWeight.w500))),
                                            DataCell(Text(lot.block)),
                                            DataCell(
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(lot.number),
                                                  Text(
                                                    'Matrícula: ${lot.registration ?? '—'}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(Text('${NumberFormat.decimalPattern('pt_BR').format(lot.area)} m²')),
                                            DataCell(Text(currencyFormatter.format(lot.price))),
                                            DataCell(StatusBadge(status: lot.status)),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                // Botão "Carregar mais" para paginação
                                if (controller.hasMore)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: SizedBox(
                                      width: 200,
                                      child: OutlinedButton.icon(
                                        onPressed: controller.isLoadingMore
                                            ? null
                                            : () => controller.loadMore(),
                                        icon: controller.isLoadingMore
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                              )
                                            : const Icon(Icons.expand_more),
                                        label: Text(
                                          controller.isLoadingMore ? 'Carregando...' : 'Carregar mais',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(color: AppColors.primary),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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
