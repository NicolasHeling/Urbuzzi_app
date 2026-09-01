class Lot {
  final String id;
  final String block;
  final String number;
  final double area;
  final double price;
  final String status;
  final String? svgCoordinates;

  // Campos adicionais para paridade com o design de referência.
  // Nullable/opcionais: o backend ainda não os expõe, então caem
  // graciosamente em `null` até o core-service ser atualizado
  // (ver TODO no README de backend).
  final String? landName; // nome do loteamento, ex: "Loteamento Biopark"
  final String? registration; // matrícula do imóvel
  final double? frontMeasure; // "frente" em metros
  final double? backMeasure; // "fundo" em metros
  final String? clientName; // nome do cliente (se reservado/vendido)
  final String? clientDocument; // documento do cliente
  final String? whatsappNumber; // WhatsApp comercial do loteamento
  final List<String>? documents; // Documentos anexados

  Lot({
    required this.id,
    required this.block,
    required this.number,
    required this.area,
    required this.price,
    required this.status,
    this.svgCoordinates,
    this.landName,
    this.registration,
    this.frontMeasure,
    this.backMeasure,
    this.clientName,
    this.clientDocument,
    this.whatsappNumber,
    this.documents,
  });

  // Factory Method para desserializar JSON
  factory Lot.fromJson(Map<String, dynamic> json) {
    return Lot(
      id: json['id'],
      block: json['block'],
      number: json['number'],
      area: double.tryParse(json['area'].toString()) ?? 0.0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      status: json['status'],
      svgCoordinates: json['svgCoordinates'],
      landName: json['landName'] ?? json['land_name'] ?? json['loteamento'],
      registration: json['registration'] ?? json['matricula'],
      frontMeasure: json['frontMeasure'] != null
          ? double.tryParse(json['frontMeasure'].toString())
          : (json['frente'] != null ? double.tryParse(json['frente'].toString()) : null),
      backMeasure: json['backMeasure'] != null
          ? double.tryParse(json['backMeasure'].toString())
          : (json['fundo'] != null ? double.tryParse(json['fundo'].toString()) : null),
      clientName: json['clientName'] ?? json['client']?['name'] ?? json['customerName'],
      clientDocument: json['clientDocument'] ?? json['client']?['document'] ?? json['customerDocument'],
      whatsappNumber: json['whatsappNumber'],
      documents: json['documents'] != null ? List<String>.from(json['documents']) : null,
    );
  }

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
    };
  }

  Lot copyWith({String? status, List<String>? documents}) {
    return Lot(
      id: id,
      block: block,
      number: number,
      area: area,
      price: price,
      status: status ?? this.status,
      svgCoordinates: svgCoordinates,
      landName: landName,
      registration: registration,
      frontMeasure: frontMeasure,
      backMeasure: backMeasure,
      clientName: clientName,
      clientDocument: clientDocument,
      whatsappNumber: whatsappNumber,
      documents: documents ?? this.documents,
    );
  }
}

