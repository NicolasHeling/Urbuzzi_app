class AuditEntry {
  final String id;
  final String action;
  final String entityName;
  final String entityId;
  final String userId;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  AuditEntry({
    required this.id,
    required this.action,
    required this.entityName,
    required this.entityId,
    required this.userId,
    required this.details,
    required this.createdAt,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      entityName: json['entityName'] ?? '',
      entityId: json['entityId'] ?? '',
      userId: json['userId'] ?? '',
      details: json['details'] ?? {},
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
