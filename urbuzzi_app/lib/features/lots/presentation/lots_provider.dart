import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lots/data/lots_repository.dart';
import '../../lots/domain/models/lot.dart';
import '../../home/presentation/map_data.dart';

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

  Future<void> fetchLots() async {
    try {
      state = const AsyncValue.loading();
      final lots = await _repository.fetchLots();
      state = AsyncValue.data(lots);
    } catch (e, stackTrace) {
      print('Erro ao carregar lotes: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateLotStatus(String lotId, String newStatus) async {
    try {
      await _repository.updateLotStatus(lotId, newStatus);
      // Atualiza a lista localmente para refletir na UI instantaneamente
      state = state.whenData((lots) {
        return lots.map((lot) {
          if (lot.id == lotId) {
            return Lot(
              id: lot.id,
              block: lot.block,
              number: lot.number,
              area: lot.area,
              price: lot.price,
              status: newStatus,
              svgCoordinates: lot.svgCoordinates,
            );
          }
          return lot;
        }).toList();
      });
    } catch (e) {
      // Ignora erro por enquanto. Em um app real, mostraríamos um SnackBar.
      print('Erro ao atualizar status: $e');
    }
  }
}
