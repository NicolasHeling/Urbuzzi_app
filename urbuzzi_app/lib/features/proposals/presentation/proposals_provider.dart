import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../../proposals/data/proposals_repository.dart';
import '../../proposals/domain/models/proposal.dart';

import '../../lots/presentation/lots_provider.dart';

// Provider para o Repositório
final proposalsRepositoryProvider = Provider<ProposalsRepository>((ref) {
  return ProposalsRepository();
});

// Provider de Estado (StateNotifier)
final proposalsControllerProvider =
    StateNotifierProvider<ProposalsController, AsyncValue<List<Proposal>>>((ref) {
  final repository = ref.watch(proposalsRepositoryProvider);
  return ProposalsController(repository, ref);
});

class ProposalsController extends StateNotifier<AsyncValue<List<Proposal>>> {
  final ProposalsRepository _repository;
  final Ref _ref;

  ProposalsController(this._repository, this._ref) : super(const AsyncValue.loading()) {
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

  Future<void> updateProposalStatus(String proposalId, String newStatus, {String? lotId}) async {
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

      if (lotId != null) {
        if (newStatus == 'Aprovada' || newStatus == 'Concluída') {
          _ref.read(lotsControllerProvider.notifier).updateLotInState(lotId, 'Vendido');
        } else if (newStatus == 'Rejeitada' || newStatus == 'Cancelada') {
          _ref.read(lotsControllerProvider.notifier).updateLotInState(lotId, 'Disponível');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao atualizar status da proposta: $e');
      }
    }
  }
}
