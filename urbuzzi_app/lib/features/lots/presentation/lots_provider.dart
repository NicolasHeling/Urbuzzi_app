import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      print('Erro ao buscar lotes, usando MOCK para o mapa aparecer: $e');
      // FALLBACK: Lotes mockados para que o usuário possa ver o mapa mesmo se der 401
      state = AsyncValue.data([
        Lot(id: '1', block: '01', number: '01', area: 360.0, price: 154000.0, status: 'Disponível'),
        Lot(id: '2', block: '01', number: '02', area: 360.0, price: 154000.0, status: 'Reservado'),
        Lot(id: '3', block: '01', number: '03', area: 360.0, price: 154000.0, status: 'Vendido'),
        Lot(id: '4', block: '01', number: '04', area: 360.0, price: 154000.0, status: 'Em Análise'),
      ]);
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
