import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'proposals_provider.dart';
import '../domain/models/proposal.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/widgets/justification_dialog.dart';
import '../../../core/widgets/status_badge.dart';

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
                child: _buildResponsiveProposals(context, ref, userRole, proposals),
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

  Widget _buildResponsiveProposals(BuildContext context, WidgetRef ref, UserRole userRole, List<Proposal> proposals) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop: DataTable
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Card(
              color: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: constraints.maxWidth - 48,
                  child: DataTable(
                    headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    columns: const [
                      DataColumn(label: Text('Cliente')),
                      DataColumn(label: Text('Lote')),
                      DataColumn(label: Text('Valor')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('SLA')),
                      DataColumn(label: Text('Ações')),
                    ],
                    rows: proposals.map((proposal) {
                      final lotNumber = proposal.lot?['number'] ?? '?';
                      final lotBlock = proposal.lot?['block'] ?? '?';
                      final slaBadge = proposal.status == 'Em Análise' ? _buildSlaBadge(proposal) : null;
                      
                      return DataRow(
                        cells: [
                          DataCell(Text(proposal.customerName)),
                          DataCell(Text('Q$lotBlock - Lote $lotNumber')),
                          DataCell(Text(currencyFormatter.format(proposal.offeredPrice ?? 0))),
                          DataCell(StatusBadge(status: proposal.status)),
                          DataCell(slaBadge ?? const Text('-')),
                          DataCell(Row(
                            children: [
                              if ((proposal.status == 'Nova' || proposal.status == 'Em Análise') && userRole.canApprove) ...[
                                TextButton(
                                  onPressed: () async {
                                    final justification = await showJustificationDialog(context, 'Rejeitar Proposta');
                                    if (justification != null) {
                                      ref.read(proposalsControllerProvider.notifier).updateProposalStatus(proposal.id, 'Rejeitada');
                                    }
                                  },
                                  style: TextButton.styleFrom(foregroundColor: AppColors.cancelado),
                                  child: const Text('Rejeitar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final justification = await showJustificationDialog(context, 'Aprovar Proposta');
                                    if (justification != null) {
                                      ref.read(proposalsControllerProvider.notifier).updateProposalStatus(proposal.id, 'Aprovada');
                                    }
                                  },
                                  style: TextButton.styleFrom(foregroundColor: AppColors.disponivel),
                                  child: const Text('Aprovar'),
                                ),
                              ] else
                                const Text('-'),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        }

        // Mobile: ListView
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: proposals.length,
          itemBuilder: (context, index) {
            final proposal = proposals[index];
            final lotNumber = proposal.lot?['number'] ?? '?';
            final lotBlock = proposal.lot?['block'] ?? '?';
            final slaBadge = proposal.status == 'Em Análise' ? _buildSlaBadge(proposal) : null;

            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            proposal.customerName,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 16),
                          ),
                        ),
                        StatusBadge(status: proposal.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Quadra $lotBlock · Lote $lotNumber', style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currencyFormatter.format(proposal.offeredPrice ?? 0),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        if (slaBadge != null) slaBadge,
                      ],
                    ),
                    if ((proposal.status == 'Nova' || proposal.status == 'Em Análise') && userRole.canApprove) ...[
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
                              style: FilledButton.styleFrom(backgroundColor: AppColors.disponivel),
                              child: const Text('Aprovar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
