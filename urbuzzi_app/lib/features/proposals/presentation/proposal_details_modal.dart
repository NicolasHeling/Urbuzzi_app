import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/models/proposal.dart';
import 'proposal_history_provider.dart';
import '../../../core/theme/app_colors.dart';

class ProposalDetailsModal extends ConsumerWidget {
  final Proposal proposal;

  const ProposalDetailsModal({super.key, required this.proposal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Proposta: ${proposal.customerName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Detalhes'),
                Tab(text: 'Histórico'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDetailsTab(),
                  _buildHistoryTab(ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _DetailRow(label: 'Cliente', value: proposal.customerName),
        _DetailRow(label: 'Lote', value: 'Quadra ${proposal.lot?['block'] ?? '?'} · Lote ${proposal.lot?['number'] ?? '?'}'),
        _DetailRow(label: 'Preço Ofertado', value: currencyFormatter.format(proposal.offeredPrice ?? 0)),
        _DetailRow(label: 'Corretor', value: proposal.responsibleUserName ?? 'Não informado'),
        _DetailRow(label: 'Status', value: proposal.status),
      ],
    );
  }

  Widget _buildHistoryTab(WidgetRef ref) {
    final historyAsync = ref.watch(proposalHistoryProvider(proposal.id));

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Center(child: Text('Nenhum histórico encontrado.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final event = history[index];
            DateTime? date = DateTime.tryParse(event.timestamp);
            final dateStr = date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : event.timestamp;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.action,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    if (event.userName != null) ...[
                      const SizedBox(height: 8),
                      Text('Por: ${event.userName}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                    if (event.notes != null && event.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(event.notes!, style: const TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erro ao carregar histórico: $e')),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
