import '../../../../core/network/dio_client.dart';
import '../domain/models/proposal.dart';

class ProposalsRepository {
  final _dio = DioClient().dio;

  Future<List<Proposal>> fetchProposals() async {
    try {
      final response = await _dio.get('/proposals');
      final List<dynamic> data = response.data;
      return data.map((json) => Proposal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Falha ao buscar propostas: $e');
    }
  }

  Future<void> createProposal(Map<String, dynamic> proposalData) async {
    try {
      await _dio.post('/proposals', data: proposalData);
    } catch (e) {
      throw Exception('Falha ao criar proposta: $e');
    }
  }

  Future<void> updateProposalStatus(String id, String newStatus) async {
    try {
      await _dio.patch('/proposals/$id/status', data: {'status': newStatus});
    } catch (e) {
      throw Exception('Falha ao atualizar status da proposta: $e');
    }
  }
}
