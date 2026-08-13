import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'proposals_provider.dart';
import '../domain/models/proposal.dart';

class ProposalsPage extends ConsumerWidget {
  const ProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsState = ref.watch(proposalsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quadro de Propostas (SLA)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(proposalsControllerProvider.notifier).fetchProposals();
            },
          )
        ],
      ),
      body: proposalsState.when(
        data: (proposals) => _buildKanbanList(context, ref, proposals),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro ao carregar propostas:\n$error', textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildKanbanList(BuildContext context, WidgetRef ref, List<Proposal> proposals) {
    if (proposals.isEmpty) {
      return const Center(child: Text('Nenhuma proposta encontrada.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: proposals.length,
      itemBuilder: (context, index) {
        final proposal = proposals[index];
        final lotDesc = proposal.lot != null
            ? 'Quadra ${proposal.lot!['block']} - Lote ${proposal.lot!['number']}'
            : 'Lote não especificado';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: _getStatusColor(proposal.status), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            leading: Icon(_getStatusIcon(proposal.status), color: _getStatusColor(proposal.status), size: 36),
            title: Text(proposal.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Status: ${proposal.status} | Oferta: R\$ ${proposal.offeredPrice?.toStringAsFixed(2) ?? '0.00'}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Documento do Cliente: ${proposal.customerDocument}'),
                    const SizedBox(height: 4),
                    Text('Lote de Interesse: $lotDesc'),
                    const SizedBox(height: 4),
                    Text('Data da Proposta: ${proposal.createdAt.toLocal().toString().split('.')[0]}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatusButton(ref, proposal.id, 'Nova', Colors.grey),
                        _buildStatusButton(ref, proposal.id, 'Em Análise', Colors.blue),
                        _buildStatusButton(ref, proposal.id, 'Aprovada', Colors.green),
                        _buildStatusButton(ref, proposal.id, 'Rejeitada', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(WidgetRef ref, String id, String statusLabel, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () {
        ref.read(proposalsControllerProvider.notifier).updateProposalStatus(id, statusLabel);
      },
      child: Text(statusLabel, style: const TextStyle(fontSize: 12)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Nova':
        return Colors.grey.shade600;
      case 'Em Análise':
        return Colors.blue;
      case 'Aprovada':
        return Colors.green;
      case 'Rejeitada':
        return Colors.red;
      case 'Concluída':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Nova':
        return Icons.inbox;
      case 'Em Análise':
        return Icons.analytics;
      case 'Aprovada':
        return Icons.thumb_up_alt;
      case 'Rejeitada':
        return Icons.cancel;
      case 'Concluída':
        return Icons.done_all;
      default:
        return Icons.receipt_long;
    }
  }
}
