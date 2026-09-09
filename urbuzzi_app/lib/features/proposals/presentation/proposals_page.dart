import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'proposals_provider.dart';
import 'kanban_provider.dart';
import 'kanban_settings_page.dart';
import '../domain/models/proposal.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/widgets/justification_dialog.dart';
import 'proposal_details_modal.dart';

class ProposalsPage extends ConsumerWidget {
  const ProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsState = ref.watch(proposalsControllerProvider);
    final kanbanState = ref.watch(kanbanProvider);
    final userRole = ref.watch(currentUserRoleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: proposalsState.when(
        data: (proposals) {
          return kanbanState.when(
            data: (stages) {
              if (proposals.isEmpty && stages.isEmpty) {
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
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      children: [
                        Text(
                          '${proposals.length} negociações em andamento',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                        const Spacer(),
                        if (userRole.canApprove)
                          OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const KanbanSettingsPage(),
                              );
                            },
                            icon: const Icon(Icons.settings, size: 16),
                            label: const Text('Configurar Funil'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildDynamicKanban(context, ref, userRole, proposals, stages),
                  ),
                ],
              );
            },
            loading: () => const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro ao carregar funil: $e')),
          );
        },
        loading: () => const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator()),
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

  Widget _buildDynamicKanban(
    BuildContext context, 
    WidgetRef ref, 
    UserRole userRole, 
    List<Proposal> proposals,
    List<KanbanColumnModel> stages,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        Widget buildColumns() {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stages.map((stage) {
              if (isDesktop) {
                return Expanded(
                  child: _buildKanbanColumn(context, stage, proposals, userRole, ref),
                );
              } else {
                return SizedBox(
                  width: 300,
                  child: _buildKanbanColumn(context, stage, proposals, userRole, ref),
                );
              }
            }).toList(),
          );
        }

        if (isDesktop) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: buildColumns(),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: buildColumns(),
        );
      },
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context, 
    KanbanColumnModel stage,
    List<Proposal> allProposals, 
    UserRole userRole,
    WidgetRef ref,
  ) {
    final proposals = allProposals.where((p) => p.status == stage.name).toList();
    
    return DragTarget<Proposal>(
      onAcceptWithDetails: (details) {
        final proposal = details.data;
        if (proposal.status != stage.name) {
          ref.read(proposalsControllerProvider.notifier).updateProposalStatus(
            proposal.id, 
            stage.name, 
            lotId: proposal.lot?['id'],
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final stageColor = Color(int.parse(stage.color.replaceFirst('#', '0xFF')));
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovering 
                ? stageColor.withValues(alpha: 0.08) 
                : AppColors.background,
            border: Border.all(
              color: isHovering ? stageColor : AppColors.border,
              width: isHovering ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: stageColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stage.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${proposals.length}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: proposals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildDraggableCard(context, proposals[index], stage, userRole, ref);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableCard(
    BuildContext context, 
    Proposal proposal, 
    KanbanColumnModel stage,
    UserRole userRole, 
    WidgetRef ref,
  ) {
    final card = _buildKanbanCard(context, proposal, stage, userRole, ref);

    return LongPressDraggable<Proposal>(
      data: proposal,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 280,
          child: Opacity(opacity: 0.9, child: card),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }

  Widget _buildKanbanCard(BuildContext context, Proposal proposal, KanbanColumnModel stage, UserRole userRole, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final lotNumber = proposal.lot?['number'] ?? '?';
    final lotBlock = proposal.lot?['block'] ?? '?';
    final slaBadge = _buildSlaBadge(proposal);
    final brokerName = proposal.responsibleUserName ?? 'Corretor';

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FractionallySizedBox(
            heightFactor: 0.85,
            child: ProposalDetailsModal(proposal: proposal),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            proposal.customerName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Quadra $lotBlock · Lote $lotNumber',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormatter.format(proposal.offeredPrice ?? 0),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          if (slaBadge != null) ...[
            const SizedBox(height: 12),
            slaBadge,
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  brokerName,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Botões de ação para gestores/admin
          if (!stage.isFinal && !stage.isCancellation && userRole.canApprove) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final justification = await showJustificationDialog(context, 'Cancelar Proposta');
                      if (justification != null) {
                        ref.read(proposalsControllerProvider.notifier).updateProposalStatus(proposal.id, 'Rejeitada', lotId: proposal.lot?['id']);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      minimumSize: const Size(0, 32),
                      foregroundColor: AppColors.cancelado,
                      side: const BorderSide(color: AppColors.cancelado),
                    ),
                    child: const Text('Rejeitar', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final justification = await showJustificationDialog(context, 'Aprovar Venda');
                      if (justification != null) {
                        ref.read(proposalsControllerProvider.notifier).updateProposalStatus(proposal.id, 'Aprovada', lotId: proposal.lot?['id']);
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      minimumSize: const Size(0, 32),
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Aprovar', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
          // Botão para marcar como concluída
          if (stage.name == 'Aprovada' && userRole.canApprove) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final justification = await showJustificationDialog(context, 'Marcar como Concluída');
                  if (justification != null) {
                    ref.read(proposalsControllerProvider.notifier).updateProposalStatus(proposal.id, 'Concluída', lotId: proposal.lot?['id']);
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  minimumSize: const Size(0, 32),
                  backgroundColor: AppColors.emAprovacao,
                ),
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label: const Text('Concluída', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}
