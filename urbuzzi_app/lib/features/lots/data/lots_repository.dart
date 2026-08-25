import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/lot.dart';

class LotsRepository {
  final _dio = DioClient().dio;

  Future<List<Lot>> fetchLots() async {
    try {
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
