import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../projects/presentation/projects_provider.dart';

class KanbanColumnModel {
  final String id;
  final String name;
  final int order;
  final String color;
  final bool isFinal;
  final bool isCancellation;

  KanbanColumnModel({
    required this.id,
    required this.name,
    required this.order,
    required this.color,
    this.isFinal = false,
    this.isCancellation = false,
  });

  factory KanbanColumnModel.fromJson(Map<String, dynamic> json) {
    return KanbanColumnModel(
      id: json['id'],
      name: json['name'],
      order: json['order'],
      color: json['color'] ?? '#C2650A',
      isFinal: json['isFinal'] ?? false,
      isCancellation: json['isCancellation'] ?? false,
    );
  }
}

final kanbanProvider = StateNotifierProvider<KanbanNotifier, AsyncValue<List<KanbanColumnModel>>>((ref) {
  final projectId = ref.watch(selectedProjectIdProvider);
  return KanbanNotifier(projectId);
});

class KanbanNotifier extends StateNotifier<AsyncValue<List<KanbanColumnModel>>> {
  final _dio = DioClient().dio;
  final String? projectId;

  KanbanNotifier(this.projectId) : super(const AsyncValue.loading()) {
    fetchColumns();
  }

  Future<void> fetchColumns() async {
    try {
      state = const AsyncValue.loading();
      final params = <String, dynamic>{};
      if (projectId != null) params['projectId'] = projectId;
      final response = await _dio.get('/kanban', queryParameters: params);
      final data = (response.data as List).map((e) => KanbanColumnModel.fromJson(e)).toList();
      
      if (data.isEmpty && projectId != null) {
        await _dio.post('/kanban/seed', data: {'projectId': projectId});
        await fetchColumns();
        return;
      }
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addColumn({required String name, required String color}) async {
    final stages = state.valueOrNull ?? [];
    final maxOrder = stages.isEmpty ? 0 : stages.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1;
    await _dio.post('/kanban', data: {
      'name': name,
      'color': color,
      'order': maxOrder,
      'projectId': projectId,
    });
    await fetchColumns();
  }

  Future<void> updateColumn(String id, {String? name, String? color}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (color != null) data['color'] = color;
    await _dio.patch('/kanban/$id', data: data);
    await fetchColumns();
  }

  Future<void> removeColumn(String id) async {
    await _dio.delete('/kanban/$id');
    await fetchColumns();
  }

  Future<void> reorderColumns(List<KanbanColumnModel> reordered) async {
    final batch = reordered.asMap().entries.map((e) => {'id': e.value.id, 'order': e.key}).toList();
    await _dio.patch('/kanban/reorder/batch', data: batch);
    await fetchColumns();
  }
}
