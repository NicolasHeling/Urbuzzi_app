import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'lots_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/models/lot.dart';
import '../../auth/presentation/auth_provider.dart';

class LotsListPage extends ConsumerStatefulWidget {
  const LotsListPage({super.key});

  @override
  ConsumerState<LotsListPage> createState() => _LotsListPageState();
}

class _LotsListPageState extends ConsumerState<LotsListPage> with AutomaticKeepAliveClientMixin {
  final List<String> _statuses = [
    'Todos',
    ...AppColors.statusOrder,
  ];

  @override
  bool get wantKeepAlive => true;

  /// IDs dos lotes selecionados para ação em massa.
  final Set<String> _selectedIds = {};

  /// Indica se uma operação em massa está em andamento.
  bool _isBulkUpdating = false;

  // ─── Seleção ────────────────────────────────────────────────────────────

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll(List<Lot> lots) {
    setState(() {
      if (_selectedIds.length == lots.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(lots.map((l) => l.id));
      }
    });
  }

  void _clearSelection() => setState(() => _selectedIds.clear());

  // ─── Ação em Massa ──────────────────────────────────────────────────────

  Future<void> _applyBulkStatus(String newStatus) async {
    if (_selectedIds.isEmpty) return;
    setState(() => _isBulkUpdating = true);
    try {
      final controller = ref.read(lotsControllerProvider.notifier);
      await controller.updateLotsStatusBulk(_selectedIds.toList(), newStatus);
      if (mounted) {
        _clearSelection();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status alterado para "$newStatus" com sucesso.'),
            backgroundColor: AppColors.disponivel,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao alterar status em massa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBulkUpdating = false);
    }
  }

  /// Exibe um diálogo para o administrador escolher o novo status em massa.
  void _showBulkStatusDialog() {
    final statuses = AppColors.statusOrder;
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Alterar status de ${_selectedIds.length} lote(s)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.statusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(status),
              onTap: () => Navigator.of(ctx).pop(status),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    ).then((chosen) {
      if (chosen != null) _applyBulkStatus(chosen);
    });
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final lotsState = ref.watch(lotsControllerProvider);
    final controller = ref.read(lotsControllerProvider.notifier);
    final userRole = ref.watch(currentUserRoleProvider);
    final canWrite = userRole.canWrite;
    final currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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
              // ── Barra de ações em massa (visível apenas quando há seleção) ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: (canWrite && _selectedIds.isNotEmpty)
                    ? _BulkActionBar(
                        key: const ValueKey('bulk_bar'),
                        selectedCount: _selectedIds.length,
                        isBusy: _isBulkUpdating,
                        onChangeStatus: _showBulkStatusDialog,
                        onClear: _clearSelection,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),

              // ── Search / Filter header ──
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final searchField = TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar lotes...',
                        hintStyle:
                            const TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        controller.setSearchQuery(value);
                        // Limpa seleção ao filtrar (evita lotes ocultos selecionados)
                        _clearSelection();
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
                          icon: const Icon(Icons.arrow_drop_down,
                              color: AppColors.textPrimary),
                          items: _statuses.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.setStatusFilter(newValue);
                              _clearSelection();
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

              // ── Table Body ──
              Expanded(
                child: lotsState.when(
                  data: (lots) {
                    if (lots.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () =>
                            ref.read(lotsControllerProvider.notifier).fetchLots(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: 400,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.inbox_outlined,
                                    size: 72, color: AppColors.border),
                                SizedBox(height: 16),
                                Text('Nenhum item encontrado',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text(
                                    'Não há lotes que correspondam aos filtros atuais.',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final notifier = ref.read(lotsControllerProvider.notifier);
                    final allSelected = lots.isNotEmpty &&
                        _selectedIds.length == lots.length;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return RefreshIndicator(
                          onRefresh: () =>
                              ref.read(lotsControllerProvider.notifier).fetchLots(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      headingRowColor:
                                          WidgetStateProperty.all(AppColors.muted
                                              .withValues(alpha: 0.6)),
                                      dataRowColor: WidgetStateProperty
                                          .resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                          if (states.contains(
                                              WidgetState.hovered)) {
                                            return AppColors.muted
                                                .withValues(alpha: 0.3);
                                          }
                                          return null;
                                        },
                                      ),
                                      dividerThickness: 1,
                                      horizontalMargin: 24,
                                      columnSpacing: 24,
                                      headingTextStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                        color: AppColors.textSecondary,
                                      ),
                                      columns: [
                                        // Coluna de checkbox "selecionar tudo"
                                        if (canWrite)
                                          DataColumn(
                                            label: Checkbox(
                                              tristate: true,
                                              value: allSelected
                                                  ? true
                                                  : (_selectedIds.isEmpty
                                                      ? false
                                                      : null),
                                              activeColor: AppColors.primary,
                                              onChanged: (_) =>
                                                  _toggleSelectAll(lots),
                                            ),
                                          ),
                                        const DataColumn(
                                            label: Text('LOTEAMENTO')),
                                        const DataColumn(
                                            label: Text('QUADRA')),
                                        const DataColumn(
                                            label: Text('LOTE')),
                                        const DataColumn(
                                            label: Text('ÁREA')),
                                        const DataColumn(
                                            label: Text('VALOR')),
                                        const DataColumn(
                                            label: Text('STATUS')),
                                      ],
                                      rows: lots.map((lot) {
                                        final isSelected =
                                            _selectedIds.contains(lot.id);
                                        return DataRow(
                                          selected: isSelected,
                                          color: WidgetStateProperty
                                              .resolveWith<Color?>(
                                            (states) {
                                              if (isSelected) {
                                                return AppColors.primary
                                                    .withValues(alpha: 0.07);
                                              }
                                              if (states.contains(
                                                  WidgetState.hovered)) {
                                                return AppColors.muted
                                                    .withValues(alpha: 0.3);
                                              }
                                              return null;
                                            },
                                          ),
                                          cells: [
                                            // Checkbox individual do lote
                                            if (canWrite)
                                              DataCell(
                                                Checkbox(
                                                  value: isSelected,
                                                  activeColor: AppColors.primary,
                                                  onChanged: (_) =>
                                                      _toggleSelect(lot.id),
                                                ),
                                              ),
                                            DataCell(Text(lot.landName ?? '-',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500))),
                                            DataCell(Text(lot.block)),
                                            DataCell(
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(lot.number),
                                                  Text(
                                                    'Matrícula: ${lot.registration ?? '—'}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(Text(
                                                '${NumberFormat.decimalPattern('pt_BR').format(lot.area)} m²')),
                                            DataCell(Text(
                                                currencyFormatter
                                                    .format(lot.price))),
                                            DataCell(
                                              _StatusDropdown(lot: lot),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                // Botão "Carregar mais" para paginação
                                if (notifier.hasMore)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: SizedBox(
                                      width: 200,
                                      child: OutlinedButton.icon(
                                        onPressed: notifier.isLoadingMore
                                            ? null
                                            : () => notifier.loadMore(),
                                        icon: notifier.isLoadingMore
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color:
                                                            AppColors.primary),
                                              )
                                            : const Icon(Icons.expand_more),
                                        label: Text(
                                          notifier.isLoadingMore
                                              ? 'Carregando...'
                                              : 'Carregar mais',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(
                                              color: AppColors.primary),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12),
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
                  error: (error, stack) =>
                      Center(child: Text('Erro: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Barra de Ações em Massa ──────────────────────────────────────────────

/// Aparece no topo da tabela quando há lotes selecionados.
/// Exibe a contagem e permite alterar o status de todos de uma vez.
class _BulkActionBar extends StatelessWidget {
  final int selectedCount;
  final bool isBusy;
  final VoidCallback onChangeStatus;
  final VoidCallback onClear;

  const _BulkActionBar({
    super.key,
    required this.selectedCount,
    required this.isBusy,
    required this.onChangeStatus,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          // Ícone de seleção
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.checklist_rounded,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),

          // Contagem
          Text(
            '$selectedCount lote(s) selecionado(s)',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),

          // Botão "Alterar status"
          if (isBusy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            )
          else
            FilledButton.icon(
              onPressed: onChangeStatus,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text(
                'Alterar Status',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          const SizedBox(width: 8),

          // Botão "Limpar seleção"
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 18),
            tooltip: 'Limpar seleção',
            color: AppColors.textSecondary,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}


// ─── Dropdown de Status Inline ─────────────────────────────────────────────

/// Célula interativa da coluna STATUS na tabela de lotes.
///
/// Exibe o [StatusBadge] atual com um chevron sutil. Ao tocar, abre um
/// [PopupMenuButton] com todos os status disponíveis. A transição é feita
/// via PATCH /lots/:id/status e o estado local é atualizado imediatamente
/// (sem refetch da lista inteira). Um [CircularProgressIndicator] leve é
/// exibido inline durante o carregamento.
class _StatusDropdown extends ConsumerStatefulWidget {
  final Lot lot;
  const _StatusDropdown({required this.lot});

  @override
  ConsumerState<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends ConsumerState<_StatusDropdown> {
  bool _isLoading = false;

  Future<void> _changeStatus(String newStatus) async {
    if (newStatus == widget.lot.status) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(lotsControllerProvider.notifier)
          .updateLotStatus(widget.lot.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status do Lote ${widget.lot.number} alterado para "$newStatus".',
            ),
            backgroundColor: AppColors.statusColor(newStatus),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao alterar status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto aguarda resposta do servidor, exibe um spinner compacto inline.
    if (_isLoading) {
      return SizedBox(
        width: 110,
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.statusColor(widget.lot.status),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.lot.status,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.statusColor(widget.lot.status),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'Alterar status',
      offset: const Offset(0, 32),
      onSelected: _changeStatus,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(status: widget.lot.status, dense: true),
          const SizedBox(width: 2),
          Icon(
            Icons.expand_more_rounded,
            size: 14,
            color: AppColors.statusColor(widget.lot.status)
                .withValues(alpha: 0.7),
          ),
        ],
      ),
      itemBuilder: (context) => AppColors.statusOrder.map((status) {
        final isCurrent = status == widget.lot.status;
        final color = AppColors.statusColor(status);
        final bg = AppColors.statusBgColor(status);
        return PopupMenuItem<String>(
          value: status,
          enabled: !isCurrent,
          padding: EdgeInsets.zero,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: isCurrent
                ? BoxDecoration(color: bg.withValues(alpha: 0.45))
                : null,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent ? color : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isCurrent)
                  Icon(Icons.check_rounded, size: 14, color: color),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
