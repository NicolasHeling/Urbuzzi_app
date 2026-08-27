import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reservations_repository.dart';
import '../models/reservation.dart';

final reservationsRepositoryProvider = Provider<ReservationsRepository>((ref) => ReservationsRepository());

final createReservationProvider = FutureProvider.family<Reservation, Map<String, String>>((ref, params) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  return repository.createReservation(params['clientId']!, params['lotId']!);
});

final pendingReservationsProvider = StateNotifierProvider<PendingReservationsController, AsyncValue<List<Reservation>>>((ref) {
  return PendingReservationsController(ref.watch(reservationsRepositoryProvider));
});

class PendingReservationsController extends StateNotifier<AsyncValue<List<Reservation>>> {
  final ReservationsRepository _repository;

  PendingReservationsController(this._repository) : super(const AsyncValue.loading()) {
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

  Future<void> approve(String id) async {
    try {
      await _repository.approveReservation(id);
      await fetchPending(); // refresh list
    } catch (e) {
      // Ignore or log error
    }
  }
}
