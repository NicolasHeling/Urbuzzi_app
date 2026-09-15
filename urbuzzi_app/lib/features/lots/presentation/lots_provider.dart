import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../../lots/data/lots_repository.dart';
import '../../lots/domain/models/lot.dart';
import 'dart:async';
import '../../../core/network/socket_service.dart';
import '../../../core/network/dio_client.dart';

// Provider para injetar o Repositório
final lotsRepositoryProvider = Provider<LotsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LotsRepository(dioClient.dio);
});

// Provider de Estado usando AsyncValue para tratar Loading, Success e Error
final lotsControllerProvider =
    StateNotifierProvider<LotsController, AsyncValue<List<Lot>>>((ref) {
  final repository = ref.watch(lotsRepositoryProvider);
  final socketService = ref.watch(socketServiceProvider);
  return LotsController(repository, socketService);
});

// Provider simples para a Vitrine (dados públicos)
final publicLotsProvider = FutureProvider<List<Lot>>((ref) async {
  final repository = ref.watch(lotsRepositoryProvider);
  return repository.fetchPublicLots();
});

// Provider para carregar polígonos dinâmicos do mapa a partir do backend.
// Se o backend não tiver polígonos configurados, retorna lista vazia
// e o mapa usará os dados estáticos de fallback (MapData.lots).
final mapPolygonsProvider = FutureProvider<List<Lot>>((ref) async {
  final repository = ref.watch(lotsRepositoryProvider);
  return repository.fetchMapPolygons();
});

class LotsController extends StateNotifier<AsyncValue<List<Lot>>> {
  final LotsRepository _repository;
  final SocketService _socketService;
  static const int _pageSize = 50;
  int _totalOnServer = 0;
  bool _isLoadingMore = false;

  String _searchQuery = '';
  String _selectedStatus = 'Todos';

  LotsController(this._repository, this._socketService) : super(const AsyncValue.loading()) {
    fetchLots();
    _initSocket();
  }

  void _initSocket() {
    _socketService.initSocket(
      onLotStatusUpdated: (lotId, newStatus) {
        updateLotInState(lotId, newStatus);
      },
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  /// Total de lotes no servidor (para saber se há mais páginas)
  int get totalOnServer => _totalOnServer;
  bool get hasMore => (state.valueOrNull?.length ?? 0) < _totalOnServer;
  bool get isLoadingMore => _isLoadingMore;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;

  Timer? _debounce;

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      fetchLots();
    });
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
      rethrow;
    }
  }

  Future<void> updateLotsStatusBulk(List<String> lotIds, String newStatus) async {
    try {
      await _repository.updateLotsStatusBulk(lotIds, newStatus);
      if (state is AsyncData) {
        final currentLots = state.value!;
        final updatedLots = currentLots.map((lot) {
          if (lotIds.contains(lot.id)) {
            return lot.copyWith(status: newStatus);
          }
          return lot;
        }).toList();
        state = AsyncValue.data(updatedLots);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao atualizar status em massa: $e');
      }
      rethrow;
    }
  }

  Future<void> uploadDocument(String lotId, List<int> bytes, String filename) async {
    try {
      final updatedLot = await _repository.uploadDocument(lotId, bytes, filename);
      if (state is AsyncData) {
        final currentLots = state.value!;
        final lotIndex = currentLots.indexWhere((l) => l.id == lotId);
        if (lotIndex != -1) {
          final updatedLots = List<Lot>.from(currentLots);
          updatedLots[lotIndex] = updatedLot;
          state = AsyncValue.data(updatedLots);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao fazer upload do documento: $e');
      }
      rethrow;
    }
  }
}
