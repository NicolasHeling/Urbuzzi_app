import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';
part 'client.g.dart';

/// Modelo imutável de Cliente, gerado com Freezed + JsonSerializable.
@freezed
abstract class Client with _$Client {
  const factory Client({
    @Default('') String id,
    @Default('') String name,
    @Default('') String cpfOrCnpj,
    @Default('') String email,
    @Default('') String phone,
    String? address,
    DateTime? createdAt,
    @Default('Novo') String? funnelStage,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
}
