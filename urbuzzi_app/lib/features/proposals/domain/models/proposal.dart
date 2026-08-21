class Proposal {
  final String id;
  final String customerName;
  final String customerDocument;
  final String status;
  final double? offeredPrice;
  final DateTime createdAt;
  final Map<String, dynamic>? lot; // Relacionamento com Lote
  final String? responsibleUserName; // Corretor responsável
  final DateTime? slaDeadline; // Prazo SLA (7 dias)

  Proposal({
    required this.id,
    required this.customerName,
    required this.customerDocument,
    required this.status,
    this.offeredPrice,
    required this.createdAt,
    this.lot,
    this.responsibleUserName,
    this.slaDeadline,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'],
      customerName: json['customerName'],
      customerDocument: json['customerDocument'],
      status: json['status'],
      offeredPrice: json['offeredPrice'] != null 
          ? double.tryParse(json['offeredPrice'].toString()) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      lot: json['lot'],
      responsibleUserName: json['responsibleUserName'],
      slaDeadline: json['slaDeadline'] != null 
          ? DateTime.tryParse(json['slaDeadline'].toString()) 
          : null,
    );
  }
}
