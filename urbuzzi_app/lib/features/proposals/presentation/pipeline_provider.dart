import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/pipeline_stage.dart';
import '../../projects/presentation/projects_provider.dart';

final pipelineProvider = StateNotifierProvider<PipelineNotifier, AsyncValue<List<PipelineStage>>>((ref) {
  final projectId = ref.watch(selectedProjectIdProvider);
  return PipelineNotifier(projectId);
});

class PipelineNotifier extends StateNotifier<AsyncValue<List<PipelineStage>>> {
  final _dio = DioClient().dio;
  final String? projectId;

  PipelineNotifier(this.projectId) : super(const AsyncValue.loading()) {
    fetchStages();
  }

  Future<void> fetchStages() async {
    try {
      state = const AsyncValue.loading();
      final params = <String, dynamic>{};
      if (projectId != null) params['projectId'] = projectId;
      final response = await _dio.get('/pipeline', queryParameters: params);
      final data = (response.data as List).map((e) => PipelineStage.fromJson(e)).toList();
      
      // Se não há etapas, faz o seed das etapas padrão
      if (data.isEmpty && projectId != null) {
        await _dio.post('/pipeline/seed', data: {'projectId': projectId});
        await fetchStages();
        return;
      }

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addStage({required String name, required String color, String? projectId}) async {
    try {
      final stages = state.valueOrNull ?? [];
      final maxOrder = stages.isEmpty ? 0 : stages.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1;
      await _dio.post('/pipeline', data: {
        'name': name,
        'color': color,
        'order': maxOrder,
        'projectId': projectId ?? this.projectId,
      });
      await fetchStages();
    } catch (e) {
      throw Exception('Erro ao adicionar etapa: $e');
    }
  }

  Future<void> updateStage(String id, {String? name, String? color}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (color != null) data['color'] = color;
      await _dio.patch('/pipeline/$id', data: data);
      await fetchStages();
    } catch (e) {
      throw Exception('Erro ao atualizar etapa: $e');
    }
  }

  Future<void> removeStage(String id) async {
    try {
      await _dio.delete('/pipeline/$id');
      await fetchStages();
    } catch (e) {
      throw Exception('Erro ao remover etapa: $e');
    }
  }

  Future<void> reorderStages(List<PipelineStage> reordered) async {
    try {
      final batch = reordered.asMap().entries.map((e) => {'id': e.value.id, 'order': e.key}).toList();
      await _dio.patch('/pipeline/reorder/batch', data: batch);
      await fetchStages();
    } catch (e) {
      throw Exception('Erro ao reordenar etapas: $e');
    }
  }
}
