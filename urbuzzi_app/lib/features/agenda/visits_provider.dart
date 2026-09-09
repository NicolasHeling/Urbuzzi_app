import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class Visit {
  final String id;
  final String customerName;
  final String date; // 'YYYY-MM-DD' ou ISO string
  final String responsibleUserName;
  final String lotId;

  Visit({
    required this.id,
    required this.customerName,
    required this.date,
    required this.responsibleUserName,
    required this.lotId,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      responsibleUserName: json['responsibleUserName']?.toString() ?? '',
      lotId: json['lotId']?.toString() ?? '',
    );
  }
}

class VisitsController extends StateNotifier<AsyncValue<List<Visit>>> {
  VisitsController() : super(const AsyncValue.loading()) {
    fetchVisits();
  }

  Future<void> fetchVisits() async {
    try {
      state = const AsyncValue.loading();
      final dio = DioClient().dio;
      final response = await dio.get('/visits');
      final visits = (response.data as List).map((v) => Visit.fromJson(v)).toList();
      state = AsyncValue.data(visits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createVisit({
    required String customerName,
    required String date,
    required String responsibleUserName,
    required String lotId,
  }) async {
    try {
      final dio = DioClient().dio;
      final response = await dio.post('/visits', data: {
        'customerName': customerName,
        'date': date,
        'responsibleUserName': responsibleUserName,
        'lotId': lotId,
      });
      final newVisit = Visit.fromJson(response.data);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newVisit]);
      } else {
        await fetchVisits();
      }
    } catch (e) {
      rethrow;
    }
  }
}

final visitsProvider = StateNotifierProvider<VisitsController, AsyncValue<List<Visit>>>((ref) {
  return VisitsController();
});
