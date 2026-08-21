import '../domain/models/audit_entry.dart';
import '../../../core/network/dio_client.dart';

class AuditRepository {
  final _dio = DioClient().dio;

  Future<List<AuditEntry>> fetchAuditEntries({int limit = 50, int offset = 0}) async {
    final response = await _dio.get('/audit', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    final List<dynamic> data = response.data;
    return data.map((json) => AuditEntry.fromJson(json)).toList();
  }
}
