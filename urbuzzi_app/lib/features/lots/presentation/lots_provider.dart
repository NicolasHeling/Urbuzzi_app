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
  static const int _pageSize = 50;
  int _totalOnServer = 0;
  bool _isLoadingMore = false;

  String _searchQuery = '';
  String _selectedStatus = 'Todos';

  LotsController(this._repository) : super(const AsyncValue.loading()) {
    fetchLots();
  }

  /// Total de lotes no servidor (para saber se há mais páginas)
  int get totalOnServer => _totalOnServer;
  bool get hasMore => (state.valueOrNull?.length ?? 0) < _totalOnServer;
  bool get isLoadingMore => _isLoadingMore;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchLots();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
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
      final page = await _repository.fetchLots(
        limit: _pageSize, 
        offset: 0,
        search: _searchQuery,
        status: _selectedStatus,
      );
      _totalOnServer = page.total;
      state = AsyncValue.data(page.data);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar lotes: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Carrega a próxima página de lotes (scroll infinito / botão "carregar mais")
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;

    try {
      final currentLots = state.valueOrNull ?? [];
      final page = await _repository.fetchLots(
        limit: _pageSize, 
        offset: currentLots.length,
        search: _searchQuery,
        status: _selectedStatus,
      );
      _totalOnServer = page.total;
      state = AsyncValue.data([...currentLots, ...page.data]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar mais lotes: $e');
      }
    } finally {
      _isLoadingMore = false;
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
