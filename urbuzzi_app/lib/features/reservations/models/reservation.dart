import '../../crm/models/client.dart';
import '../../lots/domain/models/lot.dart';

class Reservation {
  final String id;
  final String? clientId;
  final String? lotId;
  final DateTime? expirationDate;
  final Client? client;
  final Lot? lot;
  final String? status;

  Reservation({
    required this.id,
    this.clientId,
    this.lotId,
    this.expirationDate,
    this.client,
    this.lot,
    this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? '',
      clientId: json['clientId'],
      lotId: json['lotId'],
      status: json['status'],
      expirationDate: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : (json['expirationDate'] != null ? DateTime.parse(json['expirationDate']) : null),
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      lot: json['lot'] != null ? Lot.fromJson(json['lot']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'lotId': lotId,
      'expirationDate': expirationDate?.toIso8601String(),
    };
  }
}
