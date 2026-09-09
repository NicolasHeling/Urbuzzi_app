import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class AnalyticsSummary {
  final Map<String, dynamic> lotStatus;
  final Map<String, dynamic> proposalsPerColumn;

  AnalyticsSummary({
    required this.lotStatus,
    required this.proposalsPerColumn,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      lotStatus: json['lotStatus'] as Map<String, dynamic>? ?? {},
      proposalsPerColumn: json['proposalsPerColumn'] as Map<String, dynamic>? ?? {},
    );
  }
}

final analyticsSummaryProvider = FutureProvider.autoDispose<AnalyticsSummary>((ref) async {
  final dio = DioClient().dio;
  final response = await dio.get('/analytics/summary');
  return AnalyticsSummary.fromJson(response.data);
});
