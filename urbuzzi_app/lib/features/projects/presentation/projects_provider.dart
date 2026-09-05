import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/project.dart';

final selectedProjectIdProvider = StateProvider<String?>((ref) => null);

final projectsProvider = StateNotifierProvider<ProjectsNotifier, AsyncValue<List<Project>>>((ref) {
  return ProjectsNotifier(ref);
});

class ProjectsNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final _dio = DioClient().dio;
  final Ref ref;

  ProjectsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      state = const AsyncValue.loading();
      final response = await _dio.get('/projects');
      final data = (response.data as List).map((e) => Project.fromJson(e)).toList();
      
      // Auto-select first project if none is selected
      if (data.isNotEmpty && ref.read(selectedProjectIdProvider) == null) {
        ref.read(selectedProjectIdProvider.notifier).state = data.first.id;
      }

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createProject({
    required String name,
    String? description,
    String? svgMap,
    String? address,
  }) async {
    try {
      await _dio.post('/projects', data: {
        'name': name,
        'description': description,
        'svgMap': svgMap,
        'address': address,
      });
      await fetchProjects();
    } catch (e) {
      throw Exception('Erro ao criar empreendimento: $e');
    }
  }
}
