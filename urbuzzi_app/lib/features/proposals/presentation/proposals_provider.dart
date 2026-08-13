import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../proposals/data/proposals_repository.dart';
import '../../proposals/domain/models/proposal.dart';

// Provider para o Repositório
final proposalsRepositoryProvider = Provider<ProposalsRepository>((ref) {
  return ProposalsRepository();
});

// Provider de Estado (StateNotifier)
final proposalsControllerProvider =
    StateNotifierProvider<ProposalsController, AsyncValue<List<Proposal>>>((ref) {
  final repository = ref.watch(proposalsRepositoryProvider);
  return ProposalsController(repository);
});

class ProposalsController extends StateNotifier<AsyncValue<List<Proposal>>> {
  final ProposalsRepository _repository;

  ProposalsController(this._repository) : super(const AsyncValue.loading()) {
    fetchProposals();
  }

  Future<void> fetchProposals() async {
    try {
      state = const AsyncValue.loading();
      final proposals = await _repository.fetchProposals();
      state = AsyncValue.data(proposals);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateProposalStatus(String proposalId, String newStatus) async {
    try {
      await _repository.updateProposalStatus(proposalId, newStatus);
      // Atualiza a lista localmente
      state = state.whenData((proposals) {
        return proposals.map((p) {
          if (p.id == proposalId) {
            return Proposal(
              id: p.id,
              customerName: p.customerName,
              customerDocument: p.customerDocument,
              status: newStatus,
              offeredPrice: p.offeredPrice,
              createdAt: p.createdAt,
              lot: p.lot, // mantém os dados do lote
            );
          }
          return p;
        }).toList();
      });
    } catch (e) {
      print('Erro ao atualizar status da proposta: $e');
    }
  }
}
