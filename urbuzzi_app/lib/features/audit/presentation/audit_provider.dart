import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/audit_repository.dart';
import '../domain/models/audit_entry.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository();
});

final auditControllerProvider = StateNotifierProvider<AuditController, AsyncValue<List<AuditEntry>>>((ref) {
  final repository = ref.watch(auditRepositoryProvider);
  return AuditController(repository);
});

class AuditController extends StateNotifier<AsyncValue<List<AuditEntry>>> {
  final AuditRepository _repository;

  AuditController(this._repository) : super(const AsyncValue.loading()) {
    fetchEntries();
  }

  Future<void> fetchEntries({
    String? userId,
    String? action,
    String? startDate,
    String? endDate,
  }) async {
    try {
      state = const AsyncValue.loading();
      final entries = await _repository.fetchAuditEntries(
        userId: userId,
        action: action,
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(entries);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final lotAuditProvider = FutureProvider.family<List<AuditEntry>, String>((ref, lotId) async {
  final repository = ref.watch(auditRepositoryProvider);
  return repository.fetchAuditByLotId(lotId);
});
