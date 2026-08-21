import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'proposals_provider.dart';
import '../domain/models/proposal.dart';
import '../../../core/theme/app_colors.dart';

class ProposalsPage extends ConsumerWidget {
  const ProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsState = ref.watch(proposalsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Propostas (SLA 7 dias)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
              ref.read(proposalsControllerProvider.notifier).fetchProposals();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: proposalsState.when(
        data: (proposals) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '${proposals.length} negociações em andamento',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKanbanColumn(context, 'Reserva Ativa', Colors.orange, proposals, 'Nova'),
                      _buildKanbanColumn(context, 'Em Análise Interna (SLA 7 Dias)', Colors.amber.shade600, proposals, 'Em Análise'),
                      _buildKanbanColumn(context, 'Aprovada', Colors.green, proposals, 'Aprovada'),
                      _buildKanbanColumn(context, 'Rejeitada', Colors.red, proposals, 'Rejeitada'),
                    ],
                  ),
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

  /// Calcula e retorna um widget de badge SLA com cor baseada nos dias restantes
  Widget? _buildSlaBadge(Proposal proposal) {
    if (proposal.slaDeadline == null) return null;
    
    final now = DateTime.now();
    final remaining = proposal.slaDeadline!.difference(now).inDays;
    
    Color bgColor;
    Color textColor;
    String label;
    
    if (remaining > 3) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      label = '$remaining dias restantes';
    } else if (remaining > 0) {
      bgColor = Colors.amber.shade50;
      textColor = Colors.amber.shade800;
      label = '$remaining dia${remaining > 1 ? 's' : ''} restante${remaining > 1 ? 's' : ''}';
    } else {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
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

  Widget _buildKanbanColumn(BuildContext context, String title, Color color, List<Proposal> allProposals, String filterStatus) {
    final filtered = allProposals.where((p) => p.status == filterStatus).toList();
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      width: 320,
      margin: const EdgeInsets.only(left: 8, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
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
                            backgroundColor: Colors.blue.shade50,
                            foregroundColor: Colors.blue,
                            child: Text(
                              proposal.customerName.isNotEmpty ? proposal.customerName[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              proposal.customerName,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.landscape_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lotDesc,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                          Text('Valor da Proposta', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          Text(
                            currencyFormatter.format(proposal.offeredPrice ?? 0),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      // Corretor responsável
                      if (proposal.responsibleUserName != null && proposal.responsibleUserName!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 13, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              proposal.responsibleUserName!,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
