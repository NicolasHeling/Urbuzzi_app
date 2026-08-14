import '../../../../core/network/dio_client.dart';
import '../models/client.dart';

class ClientsRepository {
  final _dio = DioClient().dio;

  Future<List<Client>> getClients() async {
    final response = await _dio.get('/clients');
    final List<dynamic> data = response.data;
    return data.map((json) => Client.fromJson(json)).toList();
  }

  Future<Client> createClient(Client client) async {
    final response = await _dio.post('/clients', data: client.toJson());
    return Client.fromJson(response.data);
  }
}
