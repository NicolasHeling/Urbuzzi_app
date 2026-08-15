import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/lot.dart';

class LotsRepository {
  final _dio = DioClient().dio;

  Future<List<Lot>> fetchLots() async {
    try {
      final token = DioClient().currentToken ?? await const FlutterSecureStorage().read(key: 'jwt_token');
      
      final response = await _dio.get(
        '/lots',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      ); 
      final List<dynamic> data = response.data;
      return data.map((json) => Lot.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Falha ao buscar lotes: $e');
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
