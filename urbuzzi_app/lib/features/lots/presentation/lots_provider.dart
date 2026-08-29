import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../../lots/data/lots_repository.dart';
import '../../lots/domain/models/lot.dart';

// Provider para injetar o Repositório
final lotsRepositoryProvider = Provider<LotsRepository>((ref) {
  return LotsRepository();
});

// Provider de Estado usando AsyncValue para tratar Loading, Success e Error
final lotsControllerProvider =
    StateNotifierProvider<LotsController, AsyncValue<List<Lot>>>((ref) {
  final repository = ref.watch(lotsRepositoryProvider);
  return LotsController(repository);
});

// Provider simples para a Vitrine (dados públicos)
final publicLotsProvider = FutureProvider<List<Lot>>((ref) async {
  final repository = ref.watch(lotsRepositoryProvider);
  return repository.fetchPublicLots();
});

class LotsController extends StateNotifier<AsyncValue<List<Lot>>> {
  final LotsRepository _repository;

  LotsController(this._repository) : super(const AsyncValue.loading()) {
    fetchLots();
  }

  double get totalVendido {
    final lots = state.valueOrNull ?? [];
    return lots.where((l) => l.status == 'Vendido').fold(0.0, (sum, l) => sum + l.price);
  }

  double get totalNegociacao {
    final lots = state.valueOrNull ?? [];
    return lots.where((l) => l.status == 'Reservado' || l.status == 'Em aprovação').fold(0.0, (sum, l) => sum + l.price);
  }

  void updateLotInState(String lotId, String newStatus) {
    if (state is AsyncData) {
      final currentLots = state.value!;
      
      // Verifica se o lote existe e se o status é diferente antes de atualizar (otimização de rebuilds)
      final lotIndex = currentLots.indexWhere((l) => l.id == lotId);
      if (lotIndex == -1 || currentLots[lotIndex].status == newStatus) return;

      final updatedLots = List<Lot>.from(currentLots);
      updatedLots[lotIndex] = currentLots[lotIndex].copyWith(status: newStatus);
      
      state = AsyncValue.data(updatedLots);
    }
  }

  Future<void> fetchLots() async {
    try {
      state = const AsyncValue.loading();
      final lots = await _repository.fetchLots();
      state = AsyncValue.data(lots);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar lotes: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateLotStatus(String lotId, String newStatus, {String? justification}) async {
    try {
      await _repository.updateLotStatus(lotId, newStatus, justification: justification);
      updateLotInState(lotId, newStatus);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao atualizar status: $e');
      }
    }
  }
}


