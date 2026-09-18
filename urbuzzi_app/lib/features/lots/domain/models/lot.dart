import 'package:freezed_annotation/freezed_annotation.dart';

part 'lot.freezed.dart';

/// Modelo imutável de Lote, gerado com Freezed.
///
/// Benefícios: copyWith completo, ==, hashCode, toString automáticos.
/// O fromJson/toJson continua customizado para manter compatibilidade
/// com nomes alternativos de campos do backend.
@freezed
abstract class Lot with _$Lot {
  const Lot._(); // Permite métodos customizados

  const factory Lot({
    required String id,
    required String block,
    required String number,
    required double area,
    required double price,
    required String status,
    String? svgCoordinates,
    // Campos adicionais para paridade com o design de referência.
    String? landName, // nome do loteamento, ex: "Loteamento Biopark"
    String? registration, // matrícula do imóvel
    double? frontMeasure, // "frente" em metros
    double? backMeasure, // "fundo" em metros
    String? clientName, // nome do cliente (se reservado/vendido)
    String? clientDocument, // documento do cliente
    String? whatsappNumber, // WhatsApp comercial do loteamento
    List<String>? documents, // Documentos anexados
    List<List<double>>? mapPolygons, // Coordenadas dos polígonos para o mapa interativo
  }) = _Lot;

  /// Factory customizado para manter compatibilidade com nomes alternativos
  /// de campos retornados pelo backend (land_name, loteamento, etc.).
  factory Lot.fromJson(Map<String, dynamic> json) {
    return Lot(
      id: json['id'] as String,
      block: json['block'] as String,
      number: json['number'] as String,
      area: double.tryParse(json['area'].toString()) ?? 0.0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      status: json['status'] as String,
      svgCoordinates: json['svgCoordinates'] as String?,
      landName: (json['landName'] ?? json['land_name'] ?? json['loteamento']) as String?,
      registration: (json['registration'] ?? json['matricula']) as String?,
      frontMeasure: json['frontMeasure'] != null
          ? double.tryParse(json['frontMeasure'].toString())
          : (json['frente'] != null ? double.tryParse(json['frente'].toString()) : null),
      backMeasure: json['backMeasure'] != null
          ? double.tryParse(json['backMeasure'].toString())
          : (json['fundo'] != null ? double.tryParse(json['fundo'].toString()) : null),
      clientName: (json['clientName'] ?? json['client']?['name'] ?? json['customerName']) as String?,
      clientDocument: (json['clientDocument'] ?? json['client']?['document'] ?? json['customerDocument']) as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      documents: json['documents'] != null ? List<String>.from(json['documents'] as List) : null,
      mapPolygons: json['mapPolygons'] != null
          ? (json['mapPolygons'] as List)
              .map((pair) => (pair as List).map((v) => (v as num).toDouble()).toList())
              .toList()
          : null,
    );
  }

  /// Serialização customizada para o backend.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'block': block,
      'number': number,
      'area': area,
      'price': price,
      'status': status,
      'svgCoordinates': svgCoordinates,
      'landName': landName,
      'registration': registration,
      'frontMeasure': frontMeasure,
      'backMeasure': backMeasure,
      'clientName': clientName,
      'clientDocument': clientDocument,
      'whatsappNumber': whatsappNumber,
      'documents': documents,
      'mapPolygons': mapPolygons,
    };
  }
}
