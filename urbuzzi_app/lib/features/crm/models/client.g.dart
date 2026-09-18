// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Client _$ClientFromJson(Map<String, dynamic> json) => _Client(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  cpfOrCnpj: json['cpfOrCnpj'] as String? ?? '',
  email: json['email'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  address: json['address'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  funnelStage: json['funnelStage'] as String? ?? 'Novo',
);

Map<String, dynamic> _$ClientToJson(_Client instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'cpfOrCnpj': instance.cpfOrCnpj,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'createdAt': instance.createdAt?.toIso8601String(),
  'funnelStage': instance.funnelStage,
};
