class Project {
  final String id;
  final String name;
  final String? description;
  final String? svgMap;
  final String? address;

  Project({
    required this.id,
    required this.name,
    this.description,
    this.svgMap,
    this.address,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      svgMap: json['svgMap'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'svgMap': svgMap,
      'address': address,
    };
  }
}
