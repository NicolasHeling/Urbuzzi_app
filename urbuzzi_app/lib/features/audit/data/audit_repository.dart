import '../domain/models/audit_entry.dart';

class AuditRepository {
  // Mock data for now since we don't have the actual API endpoint integrated here
  Future<List<AuditEntry>> fetchAuditEntries() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      AuditEntry(
        id: '1',
        action: 'UPDATE_STATUS',
        entityName: 'Lot',
        entityId: 'lot-123',
        userId: 'user-1',
        details: {'oldStatus': 'Disponível', 'newStatus': 'Reservado'},
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AuditEntry(
        id: '2',
        action: 'CREATE_PROPOSAL',
        entityName: 'Proposal',
        entityId: 'prop-456',
        userId: 'user-2',
        details: {'price': 150000},
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AuditEntry(
        id: '3',
        action: 'UPDATE_STATUS',
        entityName: 'Lot',
        entityId: 'lot-789',
        userId: 'user-1',
        details: {'oldStatus': 'Em aprovação', 'newStatus': 'Vendido'},
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
