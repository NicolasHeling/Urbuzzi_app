import 'package:freezed_annotation/freezed_annotation.dart';

part 'proposal.freezed.dart';

/// Modelo imutável de Proposta, gerado com Freezed.
@freezed
abstract class Proposal with _$Proposal {
  const factory Proposal({
    required String id,
    required String customerName,
    required String customerDocument,
    required String status,
    required DateTime createdAt,
    double? offeredPrice,
    Map<String, dynamic>? lot, // Relacionamento com Lote
    String? responsibleUserName, // Corretor responsável
    DateTime? slaDeadline, // Prazo SLA (7 dias)
    String? rejectionReason,
  }) = _Proposal;

  /// Factory customizado para manter parsing robusto de campos numéricos e datas.
  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerDocument: json['customerDocument'] as String,
      status: json['status'] as String,
      offeredPrice: json['offeredPrice'] != null
          ? double.tryParse(json['offeredPrice'].toString())
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lot: json['lot'] as Map<String, dynamic>?,
      responsibleUserName: json['responsibleUserName'] as String?,
      slaDeadline: json['slaDeadline'] != null
          ? DateTime.tryParse(json['slaDeadline'].toString())
          : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}
