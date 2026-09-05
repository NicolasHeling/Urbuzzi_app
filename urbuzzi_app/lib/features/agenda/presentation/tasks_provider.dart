import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/task.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  return TasksNotifier();
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final _dio = DioClient().dio;

  TasksNotifier() : super(const AsyncValue.loading()) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      state = const AsyncValue.loading();
      final response = await _dio.get('/tasks');
      final data = (response.data as List).map((e) => Task.fromJson(e)).toList();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTask({
    required String title,
    required String date,
    required String time,
    required String clientId,
  }) async {
    try {
      await _dio.post('/tasks', data: {
        'title': title,
        'date': date,
        'time': time,
        'clientId': clientId,
        'status': 'Pendente',
      });
      await fetchTasks();
    } catch (e) {
      throw Exception('Erro ao agendar visita: $e');
    }
  }
}
