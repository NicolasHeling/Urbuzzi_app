import '../domain/models/audit_entry.dart';
import '../../../core/network/dio_client.dart';

class AuditRepository {
  final _dio = DioClient().dio;

  Future<List<AuditEntry>> fetchAuditEntries({
    int limit = 50,
    int offset = 0,
    String? userId,
    String? action,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> query = {
      'limit': limit,
      'offset': offset,
    };
    if (userId != null && userId.isNotEmpty) query['userId'] = userId;
    if (action != null && action.isNotEmpty) query['action'] = action;
    if (startDate != null && startDate.isNotEmpty) query['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) query['endDate'] = endDate;

    final response = await _dio.get('/audit', queryParameters: query);
    final List<dynamic> data = response.data;
    return data.map((json) => AuditEntry.fromJson(json)).toList();
  }
}
