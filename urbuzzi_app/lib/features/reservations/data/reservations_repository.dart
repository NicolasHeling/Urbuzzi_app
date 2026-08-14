import '../../../../core/network/dio_client.dart';
import '../models/reservation.dart';

class ReservationsRepository {
  final _dio = DioClient().dio;

  Future<Reservation> createReservation(String clientId, String lotId) async {
    final response = await _dio.post('/reservations', data: {
      'clientId': clientId,
      'lotId': lotId,
    });
    return Reservation.fromJson(response.data);
  }

  Future<List<Reservation>> getReservations() async {
    final response = await _dio.get('/reservations');
    final List<dynamic> data = response.data;
    return data.map((json) => Reservation.fromJson(json)).toList();
  }
}
