class Lot {
  final String id;
  final String block;
  final String number;
  final double area;
  final double price;
  final String status;
  final String? svgCoordinates;

  Lot({
    required this.id,
    required this.block,
    required this.number,
    required this.area,
    required this.price,
    required this.status,
    this.svgCoordinates,
  });

  // Factory Method para desserializar JSON (Padrão DoseCerta)
  factory Lot.fromJson(Map<String, dynamic> json) {
    return Lot(
      id: json['id'],
      block: json['block'],
      number: json['number'],
      area: double.tryParse(json['area'].toString()) ?? 0.0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      status: json['status'],
      svgCoordinates: json['svgCoordinates'],
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
    };
  }
}
