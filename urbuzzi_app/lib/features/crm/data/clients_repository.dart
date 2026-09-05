import '../../../core/network/dio_client.dart';
import '../models/client.dart';

class ClientsRepository {
  final _dio = DioClient().dio;

  Future<List<Client>> getClients() async {
    try {
      final response = await _dio.get('/clients');
      final List<dynamic> data = response.data;
      return data.map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Falha ao conectar com o servidor para buscar clientes: $e');
    }
  }

  Future<Client> createClient(Client client) async {
    try {
      final response = await _dio.post('/clients', data: client.toJson());
      return Client.fromJson(response.data);
    } catch (e) {
      throw Exception('Falha ao conectar com o servidor para criar cliente: $e');
    }
  }

  Future<void> updateClientStage(String id, String newStage) async {
    try {
      await _dio.patch('/clients/$id', data: {'funnelStage': newStage});
    } catch (e) {
      throw Exception('Falha ao atualizar estágio: $e');
    }
  }
}
