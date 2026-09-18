// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proposal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Proposal {

 String get id; String get customerName; String get customerDocument; String get status; DateTime get createdAt; double? get offeredPrice; Map<String, dynamic>? get lot;// Relacionamento com Lote
 String? get responsibleUserName;// Corretor responsável
 DateTime? get slaDeadline;// Prazo SLA (7 dias)
 String? get rejectionReason;
/// Create a copy of Proposal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProposalCopyWith<Proposal> get copyWith => _$ProposalCopyWithImpl<Proposal>(this as Proposal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Proposal&&(identical(other.id, id) || other.id == id)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerDocument, customerDocument) || other.customerDocument == customerDocument)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&const DeepCollectionEquality().equals(other.lot, lot)&&(identical(other.responsibleUserName, responsibleUserName) || other.responsibleUserName == responsibleUserName)&&(identical(other.slaDeadline, slaDeadline) || other.slaDeadline == slaDeadline)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason));
}


@override
int get hashCode => Object.hash(runtimeType,id,customerName,customerDocument,status,createdAt,offeredPrice,const DeepCollectionEquality().hash(lot),responsibleUserName,slaDeadline,rejectionReason);

@override
String toString() {
  return 'Proposal(id: $id, customerName: $customerName, customerDocument: $customerDocument, status: $status, createdAt: $createdAt, offeredPrice: $offeredPrice, lot: $lot, responsibleUserName: $responsibleUserName, slaDeadline: $slaDeadline, rejectionReason: $rejectionReason)';
}


}

/// @nodoc
abstract mixin class $ProposalCopyWith<$Res>  {
  factory $ProposalCopyWith(Proposal value, $Res Function(Proposal) _then) = _$ProposalCopyWithImpl;
@useResult
$Res call({
 String id, String customerName, String customerDocument, String status, DateTime createdAt, double? offeredPrice, Map<String, dynamic>? lot, String? responsibleUserName, DateTime? slaDeadline, String? rejectionReason
});




}
/// @nodoc
class _$ProposalCopyWithImpl<$Res>
    implements $ProposalCopyWith<$Res> {
  _$ProposalCopyWithImpl(this._self, this._then);

  final Proposal _self;
  final $Res Function(Proposal) _then;

/// Create a copy of Proposal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerName = null,Object? customerDocument = null,Object? status = null,Object? createdAt = null,Object? offeredPrice = freezed,Object? lot = freezed,Object? responsibleUserName = freezed,Object? slaDeadline = freezed,Object? rejectionReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerDocument: null == customerDocument ? _self.customerDocument : customerDocument // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,offeredPrice: freezed == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double?,lot: freezed == lot ? _self.lot : lot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,responsibleUserName: freezed == responsibleUserName ? _self.responsibleUserName : responsibleUserName // ignore: cast_nullable_to_non_nullable
as String?,slaDeadline: freezed == slaDeadline ? _self.slaDeadline : slaDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Proposal].
extension ProposalPatterns on Proposal {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Proposal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Proposal() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Proposal value)  $default,){
final _that = this;
switch (_that) {
case _Proposal():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Proposal value)?  $default,){
final _that = this;
switch (_that) {
case _Proposal() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerName,  String customerDocument,  String status,  DateTime createdAt,  double? offeredPrice,  Map<String, dynamic>? lot,  String? responsibleUserName,  DateTime? slaDeadline,  String? rejectionReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Proposal() when $default != null:
return $default(_that.id,_that.customerName,_that.customerDocument,_that.status,_that.createdAt,_that.offeredPrice,_that.lot,_that.responsibleUserName,_that.slaDeadline,_that.rejectionReason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerName,  String customerDocument,  String status,  DateTime createdAt,  double? offeredPrice,  Map<String, dynamic>? lot,  String? responsibleUserName,  DateTime? slaDeadline,  String? rejectionReason)  $default,) {final _that = this;
switch (_that) {
case _Proposal():
return $default(_that.id,_that.customerName,_that.customerDocument,_that.status,_that.createdAt,_that.offeredPrice,_that.lot,_that.responsibleUserName,_that.slaDeadline,_that.rejectionReason);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerName,  String customerDocument,  String status,  DateTime createdAt,  double? offeredPrice,  Map<String, dynamic>? lot,  String? responsibleUserName,  DateTime? slaDeadline,  String? rejectionReason)?  $default,) {final _that = this;
switch (_that) {
case _Proposal() when $default != null:
return $default(_that.id,_that.customerName,_that.customerDocument,_that.status,_that.createdAt,_that.offeredPrice,_that.lot,_that.responsibleUserName,_that.slaDeadline,_that.rejectionReason);case _:
  return null;

}
}

}

/// @nodoc


class _Proposal implements Proposal {
  const _Proposal({required this.id, required this.customerName, required this.customerDocument, required this.status, required this.createdAt, this.offeredPrice, final  Map<String, dynamic>? lot, this.responsibleUserName, this.slaDeadline, this.rejectionReason}): _lot = lot;
  

@override final  String id;
@override final  String customerName;
@override final  String customerDocument;
@override final  String status;
@override final  DateTime createdAt;
@override final  double? offeredPrice;
 final  Map<String, dynamic>? _lot;
@override Map<String, dynamic>? get lot {
  final value = _lot;
  if (value == null) return null;
  if (_lot is EqualUnmodifiableMapView) return _lot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Relacionamento com Lote
@override final  String? responsibleUserName;
// Corretor responsável
@override final  DateTime? slaDeadline;
// Prazo SLA (7 dias)
@override final  String? rejectionReason;

/// Create a copy of Proposal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProposalCopyWith<_Proposal> get copyWith => __$ProposalCopyWithImpl<_Proposal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Proposal&&(identical(other.id, id) || other.id == id)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerDocument, customerDocument) || other.customerDocument == customerDocument)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&const DeepCollectionEquality().equals(other._lot, _lot)&&(identical(other.responsibleUserName, responsibleUserName) || other.responsibleUserName == responsibleUserName)&&(identical(other.slaDeadline, slaDeadline) || other.slaDeadline == slaDeadline)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason));
}


@override
int get hashCode => Object.hash(runtimeType,id,customerName,customerDocument,status,createdAt,offeredPrice,const DeepCollectionEquality().hash(_lot),responsibleUserName,slaDeadline,rejectionReason);

@override
String toString() {
  return 'Proposal(id: $id, customerName: $customerName, customerDocument: $customerDocument, status: $status, createdAt: $createdAt, offeredPrice: $offeredPrice, lot: $lot, responsibleUserName: $responsibleUserName, slaDeadline: $slaDeadline, rejectionReason: $rejectionReason)';
}


}

/// @nodoc
abstract mixin class _$ProposalCopyWith<$Res> implements $ProposalCopyWith<$Res> {
  factory _$ProposalCopyWith(_Proposal value, $Res Function(_Proposal) _then) = __$ProposalCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerName, String customerDocument, String status, DateTime createdAt, double? offeredPrice, Map<String, dynamic>? lot, String? responsibleUserName, DateTime? slaDeadline, String? rejectionReason
});




}
/// @nodoc
class __$ProposalCopyWithImpl<$Res>
    implements _$ProposalCopyWith<$Res> {
  __$ProposalCopyWithImpl(this._self, this._then);

  final _Proposal _self;
  final $Res Function(_Proposal) _then;

/// Create a copy of Proposal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerName = null,Object? customerDocument = null,Object? status = null,Object? createdAt = null,Object? offeredPrice = freezed,Object? lot = freezed,Object? responsibleUserName = freezed,Object? slaDeadline = freezed,Object? rejectionReason = freezed,}) {
  return _then(_Proposal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerDocument: null == customerDocument ? _self.customerDocument : customerDocument // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,offeredPrice: freezed == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double?,lot: freezed == lot ? _self._lot : lot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,responsibleUserName: freezed == responsibleUserName ? _self.responsibleUserName : responsibleUserName // ignore: cast_nullable_to_non_nullable
as String?,slaDeadline: freezed == slaDeadline ? _self.slaDeadline : slaDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
