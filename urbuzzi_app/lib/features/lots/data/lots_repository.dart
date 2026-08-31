import '../../../core/network/dio_client.dart';
import '../domain/models/lot.dart';

class LotsPage {
  final List<Lot> data;
  final int total;

  LotsPage({required this.data, required this.total});
}

class LotsRepository {
  final _dio = DioClient().dio;

  /// Busca lotes com paginação. Retorna dados + total para scroll infinito.
  Future<LotsPage> fetchLots({int limit = 50, int offset = 0, String? search, String? status}) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (status != null && status != 'Todos') {
        queryParams['status'] = status;
      }

      final response = await _dio.get('/lots', queryParameters: queryParams);
      
      List<dynamic> items;
      int total;

      if (response.data is List) {
        items = response.data as List;
        total = items.length;
      } else {
        final Map<String, dynamic> body = response.data;
        items = body['data'];
        total = body['total'] as int;
      }

      return LotsPage(
        data: items.map((json) => Lot.fromJson(json)).toList(),
        total: total,
      );
    } catch (e) {
      throw Exception('Falha ao buscar lotes: $e');
    }
  }

  Future<List<Lot>> fetchPublicLots() async {
    try {
      final response = await _dio.get('/lots/public'); 
      final List<dynamic> data = response.data;
      return data.map((json) => Lot.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Falha ao buscar lotes públicos: $e');
    }
  }

  Future<Lot> fetchLotById(String id) async {
    try {
      final response = await _dio.get('/lots/$id');
      return Lot.fromJson(response.data);
    } catch (e) {
      throw Exception('Falha ao buscar detalhes do lote: $e');
    }
  }

  Future<void> updateLotStatus(String id, String newStatus, {String? justification}) async {
    try {
      final payload = <String, dynamic>{'status': newStatus};
      if (justification != null) {
        payload['justification'] = justification;
      }
      await _dio.patch('/lots/$id/status', data: payload);
    } catch (e) {
      throw Exception('Falha ao atualizar o status do lote: $e');
    }
  }
}
