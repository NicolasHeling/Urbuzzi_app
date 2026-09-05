import 'package:flutter/material.dart';

class PipelineStage {
  final String id;
  final String name;
  final int order;
  final Color color;
  final String? projectId;
  final bool isFinal;
  final bool isCancellation;

  PipelineStage({
    required this.id,
    required this.name,
    required this.order,
    required this.color,
    this.projectId,
    this.isFinal = false,
    this.isCancellation = false,
  });

  factory PipelineStage.fromJson(Map<String, dynamic> json) {
    return PipelineStage(
      id: json['id'],
      name: json['name'],
      order: json['order'] ?? 0,
      color: _parseColor(json['color'] ?? '#C2650A'),
      projectId: json['projectId'],
      isFinal: json['isFinal'] ?? false,
      isCancellation: json['isCancellation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'color': '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'projectId': projectId,
      'isFinal': isFinal,
      'isCancellation': isCancellation,
    };
  }

  static Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
