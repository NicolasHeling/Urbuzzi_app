import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reservations_repository.dart';
import '../models/reservation.dart';

final reservationsRepositoryProvider = Provider<ReservationsRepository>((ref) => ReservationsRepository());

final createReservationProvider = FutureProvider.family<Reservation, Map<String, String>>((ref, params) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  return repository.createReservation(params['clientId']!, params['lotId']!);
});
