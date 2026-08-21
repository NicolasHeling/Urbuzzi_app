import '../domain/models/audit_entry.dart';
import '../../../core/network/dio_client.dart';

class AuditRepository {
  final _dio = DioClient().dio;

  Future<List<AuditEntry>> fetchAuditEntries() async {
    final response = await _dio.get('/audit');
    final List<dynamic> data = response.data;
    return data.map((json) => AuditEntry.fromJson(json)).toList();
  }
}
