class Client {
  final String id;
  final String name;
  final String cpfOrCnpj;
  final String email;
  final String phone;
  final String? address;
  final DateTime? createdAt;
  final String? funnelStage;

  Client({
    required this.id,
    required this.name,
    required this.cpfOrCnpj,
    required this.email,
    required this.phone,
    this.address,
    this.createdAt,
    this.funnelStage,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cpfOrCnpj: json['cpfOrCnpj'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      funnelStage: json['funnelStage'] ?? 'Novo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpfOrCnpj': cpfOrCnpj,
      'email': email,
      'phone': phone,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
      'funnelStage': funnelStage,
    };
  }
}
