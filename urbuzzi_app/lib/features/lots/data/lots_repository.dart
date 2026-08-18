import '../../../core/network/dio_client.dart';
import '../domain/models/lot.dart';

class LotsRepository {
  final _dio = DioClient().dio;

  Future<List<Lot>> fetchLots() async {
    try {
      // O token já é injetado automaticamente pelo interceptor do DioClient.
      // Não injetar aqui de novo — isso duplicava o header Authorization
      // (um em maiúsculo vindo daqui, outro em minúsculo do interceptor),
      // e em ambientes web o XHR concatenava os dois valores num único
      // header corrompido, derrubando a verificação do JWT no gateway (401).
      final response = await _dio.get('/lots');
      final List<dynamic> data = response.data;
      return data.map((json) => Lot.fromJson(json)).toList();
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

  Future<void> updateLotStatus(String id, String newStatus) async {
    try {
      await _dio.patch('/lots/$id/status', data: {'status': newStatus});
    } catch (e) {
      throw Exception('Falha ao atualizar o status do lote: $e');
    }
  }
}
