import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class ProposalHistoryEvent {
  final String id;
  final String action;
  final String timestamp;
  final String? userName;
  final String? notes;

  ProposalHistoryEvent({
    required this.id,
    required this.action,
    required this.timestamp,
    this.userName,
    this.notes,
  });

  factory ProposalHistoryEvent.fromJson(Map<String, dynamic> json) {
    return ProposalHistoryEvent(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? 'Ação desconhecida',
      timestamp: json['timestamp']?.toString() ?? '',
      userName: json['userName']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}

final proposalHistoryProvider = FutureProvider.family.autoDispose<List<ProposalHistoryEvent>, String>((ref, proposalId) async {
  final dio = DioClient().dio;
  final response = await dio.get('/proposals/$proposalId/history');
  final list = response.data as List;
  return list.map((e) => ProposalHistoryEvent.fromJson(e)).toList();
});
