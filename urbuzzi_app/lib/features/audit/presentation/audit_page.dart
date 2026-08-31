import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'audit_provider.dart';
import '../domain/models/audit_entry.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/theme/app_colors.dart';

class AuditPage extends ConsumerStatefulWidget {
  const AuditPage({super.key});

  @override
  ConsumerState<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends ConsumerState<AuditPage> {
  String? _userId;
  String? _action;
  DateTime? _startDate;
  DateTime? _endDate;

  void _applyFilters() {
    ref.read(auditControllerProvider.notifier).fetchEntries(
      userId: _userId,
      action: _action,
      startDate: _startDate?.toIso8601String(),
      endDate: _endDate?.toIso8601String(),
    );
  }

  /// Traduz os códigos de ação do backend para textos legíveis em português
  String _translateAction(String action) {
    switch (action) {
      case 'CREATE_LOT':
        return 'Criou lote';
      case 'UPDATE_LOT_STATUS':
        return 'Alterou status do lote';
      case 'CREATE_PROPOSAL':
        return 'Criou proposta';
      case 'UPDATE_PROPOSAL_STATUS':
        return 'Alterou status da proposta';
      case 'CREATE_RESERVATION':
        return 'Criou reserva';
      case 'CREATE_CLIENT':
        return 'Cadastrou cliente';
      case 'CANCEL_RESERVATION':
        return 'Cancelou reserva';
      case 'APPROVE_RESERVATION':
        return 'Aprovou reserva';
      case 'UPDATE_LOT_PRICE':
        return 'Atualizou valor de tabela';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auditState = ref.watch(auditControllerProvider);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: auditState.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppColors.border),
                  const SizedBox(height: 16),
                  Text('Nenhum registro encontrado.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtros',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Usuário (ID ou Email)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (value) => _userId = value.isEmpty ? null : value,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                decoration: const InputDecoration(
                                  labelText: 'Ação',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                initialValue: _action,
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Todas')),
                                  DropdownMenuItem(value: 'CREATE_LOT', child: Text('Criou lote')),
                                  DropdownMenuItem(value: 'UPDATE_LOT_STATUS', child: Text('Alterou status do lote')),
                                  DropdownMenuItem(value: 'CREATE_PROPOSAL', child: Text('Criou proposta')),
                                  DropdownMenuItem(value: 'UPDATE_PROPOSAL_STATUS', child: Text('Alterou status da proposta')),
                                  DropdownMenuItem(value: 'CREATE_RESERVATION', child: Text('Criou reserva')),
                                  DropdownMenuItem(value: 'APPROVE_RESERVATION', child: Text('Aprovou reserva')),
                                ],
                                onChanged: (val) => _action = val,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() => _startDate = date);
                                  }
                                },
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: Text(_startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'Data Inicial'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() => _endDate = date);
                                  }
                                },
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: Text(_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Data Final'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _applyFilters();
                                });
                              },
                              child: const Text('Filtrar'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _userId = null;
                                  _action = null;
                                  _startDate = null;
                                  _endDate = null;
                                  _applyFilters();
                                });
                              },
                              child: const Text('Limpar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return _buildTimelineItem(context, entry, dateFormatter, isLast: index == entries.length - 1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, AuditEntry entry, DateFormat formatter, {required bool isLast}) {
    final description = _translateAction(entry.action);
    final details = entry.details;

    // Tenta extrair info de localização do lote a partir dos details
    String? locationInfo;
    if (details != null) {
      final landName = details['landName'];
      final lotNumber = details['lotNumber'];
      final lotBlock = details['lotBlock'];
      if (lotNumber != null && lotBlock != null) {
        locationInfo = landName != null
            ? '$landName · Lote $lotNumber / Quadra $lotBlock'
            : 'Lote $lotNumber / Quadra $lotBlock';
      }
    }

    // Tenta extrair nome do usuário responsável
    String userDisplay;
    if (details != null && details['userName'] != null) {
      final role = details['userRole'];
      userDisplay = role != null 
          ? '${details['userName']} · $role' 
          : '${details['userName']}';
    } else {
      userDisplay = entry.userId.isNotEmpty ? 'Usuário: ${entry.userId}' : 'Sistema';
    }

    // Transições de status
    final oldStatus = details?['oldStatus'];
    final newStatus = details?['newStatus'];
    final hasStatusTransition = oldStatus != null && newStatus != null;

    // Alteração de valores
    String? priceChange;
    if (details != null && details['oldPrice'] != null && details['newPrice'] != null) {
      final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
      final oldPrice = double.tryParse(details['oldPrice'].toString()) ?? 0;
      final newPrice = double.tryParse(details['newPrice'].toString()) ?? 0;
      priceChange = '${formatter.format(oldPrice)} → ${formatter.format(newPrice)}';
    } else if (details != null && details['price'] != null) {
      priceChange = 'Valor: R\$ ${details['price']}';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data/hora
                    Text(
                      formatter.format(entry.createdAt),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Nome + Cargo do responsável
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            userDisplay,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Descrição da ação (traduzida)
                    Text(
                      description,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
                    ),
                    // Localização do lote
                    if (locationInfo != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            locationInfo,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                    // Transição de status com badges coloridos
                    if (hasStatusTransition) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          StatusBadge(status: oldStatus.toString()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward, size: 14, color: AppColors.textMuted),
                          ),
                          StatusBadge(status: newStatus.toString()),
                        ],
                      ),
                    ],
                    // Alteração de preço
                    if (priceChange != null && !hasStatusTransition) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          priceChange,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
