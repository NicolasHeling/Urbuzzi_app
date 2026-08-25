import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'proposals_provider.dart';
import '../domain/models/proposal.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/widgets/justification_dialog.dart';

class ProposalsPage extends ConsumerWidget {
  const ProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsState = ref.watch(proposalsControllerProvider);
    final userRole = ref.watch(currentUserRoleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: proposalsState.when(
        data: (proposals) {
          if (proposals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_drive_file_outlined, size: 72, color: AppColors.border),
                  const SizedBox(height: 16),
                  const Text('Nenhum item encontrado', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Ainda não há propostas ou negociações.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '${proposals.length} negociações em andamento',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKanbanColumn(context, ref, userRole, 'Reserva Ativa', AppColors.reservado, proposals, 'Nova'),
                      _buildKanbanColumn(context, ref, userRole, 'Em Análise Interna (SLA 7 Dias)', AppColors.emAprovacao, proposals, 'Em Análise'),
                      _buildKanbanColumn(context, ref, userRole, 'Aprovada', AppColors.disponivel, proposals, 'Aprovada'),
                      _buildKanbanColumn(context, ref, userRole, 'Rejeitada', AppColors.cancelado, proposals, 'Rejeitada'),
                      _buildKanbanColumn(context, ref, userRole, 'Concluída', AppColors.primary, proposals, 'Concluída'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Align(
          alignment: Alignment.topCenter,
          child: LinearProgressIndicator(),
        ),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }

  /// Calcula e retorna um widget de badge SLA com cor baseada nos dias restantes
  Widget? _buildSlaBadge(Proposal proposal) {
    if (proposal.slaDeadline == null) return null;
    
    final now = DateTime.now();
    final remaining = proposal.slaDeadline!.difference(now).inDays;
    
    Color bgColor;
    Color textColor;
    String label;
    
    if (remaining > 3) {
      bgColor = AppColors.disponivelBg;
      textColor = AppColors.disponivel;
      label = '$remaining dias restantes';
    } else if (remaining > 0) {
      bgColor = AppColors.reservadoBg;
      textColor = AppColors.reservado;
      label = '$remaining dia${remaining > 1 ? 's' : ''} restante${remaining > 1 ? 's' : ''}';
    } else {
      bgColor = AppColors.canceladoBg;
      textColor = AppColors.cancelado;
      label = 'SLA vencido';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, WidgetRef ref, UserRole userRole, String title, Color color, List<Proposal> allProposals, String filterStatus) {
    final filtered = allProposals.where((p) => p.status == filterStatus).toList();
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      width: 320,
      margin: const EdgeInsets.only(left: 8, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('${filtered.length}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final proposal = filtered[index];
                // Exibe Lote · Quadra · Nome do Loteamento (se disponível)
                final lotNumber = proposal.lot?['number'] ?? '?';
                final lotBlock = proposal.lot?['block'] ?? '?';
                final landName = proposal.lot?['landName'];
                final lotDesc = landName != null
                    ? 'Lote $lotNumber · Quadra $lotBlock · $landName'
                    : 'Lote $lotNumber · Quadra $lotBlock';

                // Badge SLA para propostas "Em Análise"
                final slaBadge = (filterStatus == 'Em Análise') ? _buildSlaBadge(proposal) : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                    )],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primary,
                            child: Text(
                              proposal.customerName.isNotEmpty ? proposal.customerName[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              proposal.customerName,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.landscape_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lotDesc,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Badge SLA (apenas para "Em Análise")
                      if (slaBadge != null) ...[
                        const SizedBox(height: 8),
                        slaBadge,
                      ],
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Valor da Proposta', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text(
                            currencyFormatter.format(proposal.offeredPrice ?? 0),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      // Corretor responsável
                      if (proposal.responsibleUserName != null && proposal.responsibleUserName!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              proposal.responsibleUserName!,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                      // Botões de Ação
                      if ((filterStatus == 'Nova' || filterStatus == 'Em Análise') && userRole.canApprove) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  final justification = await showJustificationDialog(context, 'Rejeitar Proposta');
                                  if (justification != null) {
                                    ref.read(proposalsControllerProvider.notifier).updateProposalStatus(proposal.id, 'Rejeitada');
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.cancelado,
                                  side: const BorderSide(color: AppColors.cancelado),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: const Text('Rejeitar'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () async {
                                  final justification = await showJustificationDialog(context, 'Aprovar Proposta');
                                  if (justification != null) {
                                    ref.read(proposalsControllerProvider.notifier).updateProposalStatus(proposal.id, 'Aprovada');
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.disponivel,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: const Text('Aprovar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
