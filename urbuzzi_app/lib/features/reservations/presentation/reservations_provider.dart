import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reservations_repository.dart';
import '../models/reservation.dart';

import '../../lots/presentation/lots_provider.dart';

final reservationsRepositoryProvider = Provider<ReservationsRepository>((ref) => ReservationsRepository());

final createReservationProvider = FutureProvider.family<Reservation, Map<String, String>>((ref, params) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  return repository.createReservation(params['clientId']!, params['lotId']!);
});

final pendingReservationsProvider = StateNotifierProvider<PendingReservationsController, AsyncValue<List<Reservation>>>((ref) {
  return PendingReservationsController(ref.watch(reservationsRepositoryProvider), ref);
});

class PendingReservationsController extends StateNotifier<AsyncValue<List<Reservation>>> {
  final ReservationsRepository _repository;
  final Ref _ref;

  PendingReservationsController(this._repository, this._ref) : super(const AsyncValue.loading()) {
    fetchPending();
  }

  Future<void> fetchPending() async {
    try {
      state = const AsyncValue.loading();
      final all = await _repository.getReservations();
      final pending = all.where((r) => r.status == 'PENDING').toList();
      state = AsyncValue.data(pending);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approve(String id, String lotId) async {
    try {
      await _repository.approveReservation(id);
      await fetchPending(); // refresh list
      // Atualizar o lote para Vendido para reatividade instantânea no Dashboard
      _ref.read(lotsControllerProvider.notifier).updateLotInState(lotId, 'Vendido');
    } catch (e) {
      // Ignore or log error
    }
  }

  Future<void> cancel(String id, String lotId) async {
    try {
      await _repository.cancelReservation(id);
      await fetchPending();
      // Retornar lote para Disponível se cancelado
      _ref.read(lotsControllerProvider.notifier).updateLotInState(lotId, 'Disponível');
    } catch (e) {
      // Ignore or log error
    }
  }
}
