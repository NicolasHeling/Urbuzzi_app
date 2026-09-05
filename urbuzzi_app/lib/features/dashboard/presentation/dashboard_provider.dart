import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class FunnelMetrics {
  final int totalClients;
  final int totalReservations;
  final int totalSales;

  FunnelMetrics({
    required this.totalClients,
    required this.totalReservations,
    required this.totalSales,
  });

  factory FunnelMetrics.fromJson(Map<String, dynamic> json) {
    return FunnelMetrics(
      totalClients: json['totalClients'] as int? ?? 0,
      totalReservations: json['totalReservations'] as int? ?? 0,
      totalSales: json['totalSales'] as int? ?? 0,
    );
  }
}

final funnelMetricsProvider = FutureProvider.autoDispose<FunnelMetrics>((ref) async {
  final dio = DioClient().dio;
  final response = await dio.get('/dashboard/funnel');
  return FunnelMetrics.fromJson(response.data);
});
