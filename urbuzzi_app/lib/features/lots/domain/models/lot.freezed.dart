// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Lot {

 String get id; String get block; String get number; double get area; double get price; String get status; String? get svgCoordinates;// Campos adicionais para paridade com o design de referência.
 String? get landName;// nome do loteamento, ex: "Loteamento Biopark"
 String? get registration;// matrícula do imóvel
 double? get frontMeasure;// "frente" em metros
 double? get backMeasure;// "fundo" em metros
 String? get clientName;// nome do cliente (se reservado/vendido)
 String? get clientDocument;// documento do cliente
 String? get whatsappNumber;// WhatsApp comercial do loteamento
 List<String>? get documents;// Documentos anexados
 List<List<double>>? get mapPolygons;
/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotCopyWith<Lot> get copyWith => _$LotCopyWithImpl<Lot>(this as Lot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lot&&(identical(other.id, id) || other.id == id)&&(identical(other.block, block) || other.block == block)&&(identical(other.number, number) || other.number == number)&&(identical(other.area, area) || other.area == area)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status)&&(identical(other.svgCoordinates, svgCoordinates) || other.svgCoordinates == svgCoordinates)&&(identical(other.landName, landName) || other.landName == landName)&&(identical(other.registration, registration) || other.registration == registration)&&(identical(other.frontMeasure, frontMeasure) || other.frontMeasure == frontMeasure)&&(identical(other.backMeasure, backMeasure) || other.backMeasure == backMeasure)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.clientDocument, clientDocument) || other.clientDocument == clientDocument)&&(identical(other.whatsappNumber, whatsappNumber) || other.whatsappNumber == whatsappNumber)&&const DeepCollectionEquality().equals(other.documents, documents)&&const DeepCollectionEquality().equals(other.mapPolygons, mapPolygons));
}


@override
int get hashCode => Object.hash(runtimeType,id,block,number,area,price,status,svgCoordinates,landName,registration,frontMeasure,backMeasure,clientName,clientDocument,whatsappNumber,const DeepCollectionEquality().hash(documents),const DeepCollectionEquality().hash(mapPolygons));

@override
String toString() {
  return 'Lot(id: $id, block: $block, number: $number, area: $area, price: $price, status: $status, svgCoordinates: $svgCoordinates, landName: $landName, registration: $registration, frontMeasure: $frontMeasure, backMeasure: $backMeasure, clientName: $clientName, clientDocument: $clientDocument, whatsappNumber: $whatsappNumber, documents: $documents, mapPolygons: $mapPolygons)';
}


}

/// @nodoc
abstract mixin class $LotCopyWith<$Res>  {
  factory $LotCopyWith(Lot value, $Res Function(Lot) _then) = _$LotCopyWithImpl;
@useResult
$Res call({
 String id, String block, String number, double area, double price, String status, String? svgCoordinates, String? landName, String? registration, double? frontMeasure, double? backMeasure, String? clientName, String? clientDocument, String? whatsappNumber, List<String>? documents, List<List<double>>? mapPolygons
});




}
/// @nodoc
class _$LotCopyWithImpl<$Res>
    implements $LotCopyWith<$Res> {
  _$LotCopyWithImpl(this._self, this._then);

  final Lot _self;
  final $Res Function(Lot) _then;

/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? block = null,Object? number = null,Object? area = null,Object? price = null,Object? status = null,Object? svgCoordinates = freezed,Object? landName = freezed,Object? registration = freezed,Object? frontMeasure = freezed,Object? backMeasure = freezed,Object? clientName = freezed,Object? clientDocument = freezed,Object? whatsappNumber = freezed,Object? documents = freezed,Object? mapPolygons = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as double,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,svgCoordinates: freezed == svgCoordinates ? _self.svgCoordinates : svgCoordinates // ignore: cast_nullable_to_non_nullable
as String?,landName: freezed == landName ? _self.landName : landName // ignore: cast_nullable_to_non_nullable
as String?,registration: freezed == registration ? _self.registration : registration // ignore: cast_nullable_to_non_nullable
as String?,frontMeasure: freezed == frontMeasure ? _self.frontMeasure : frontMeasure // ignore: cast_nullable_to_non_nullable
as double?,backMeasure: freezed == backMeasure ? _self.backMeasure : backMeasure // ignore: cast_nullable_to_non_nullable
as double?,clientName: freezed == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String?,clientDocument: freezed == clientDocument ? _self.clientDocument : clientDocument // ignore: cast_nullable_to_non_nullable
as String?,whatsappNumber: freezed == whatsappNumber ? _self.whatsappNumber : whatsappNumber // ignore: cast_nullable_to_non_nullable
as String?,documents: freezed == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<String>?,mapPolygons: freezed == mapPolygons ? _self.mapPolygons : mapPolygons // ignore: cast_nullable_to_non_nullable
as List<List<double>>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Lot].
extension LotPatterns on Lot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lot value)  $default,){
final _that = this;
switch (_that) {
case _Lot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lot value)?  $default,){
final _that = this;
switch (_that) {
case _Lot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String block,  String number,  double area,  double price,  String status,  String? svgCoordinates,  String? landName,  String? registration,  double? frontMeasure,  double? backMeasure,  String? clientName,  String? clientDocument,  String? whatsappNumber,  List<String>? documents,  List<List<double>>? mapPolygons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lot() when $default != null:
return $default(_that.id,_that.block,_that.number,_that.area,_that.price,_that.status,_that.svgCoordinates,_that.landName,_that.registration,_that.frontMeasure,_that.backMeasure,_that.clientName,_that.clientDocument,_that.whatsappNumber,_that.documents,_that.mapPolygons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String block,  String number,  double area,  double price,  String status,  String? svgCoordinates,  String? landName,  String? registration,  double? frontMeasure,  double? backMeasure,  String? clientName,  String? clientDocument,  String? whatsappNumber,  List<String>? documents,  List<List<double>>? mapPolygons)  $default,) {final _that = this;
switch (_that) {
case _Lot():
return $default(_that.id,_that.block,_that.number,_that.area,_that.price,_that.status,_that.svgCoordinates,_that.landName,_that.registration,_that.frontMeasure,_that.backMeasure,_that.clientName,_that.clientDocument,_that.whatsappNumber,_that.documents,_that.mapPolygons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String block,  String number,  double area,  double price,  String status,  String? svgCoordinates,  String? landName,  String? registration,  double? frontMeasure,  double? backMeasure,  String? clientName,  String? clientDocument,  String? whatsappNumber,  List<String>? documents,  List<List<double>>? mapPolygons)?  $default,) {final _that = this;
switch (_that) {
case _Lot() when $default != null:
return $default(_that.id,_that.block,_that.number,_that.area,_that.price,_that.status,_that.svgCoordinates,_that.landName,_that.registration,_that.frontMeasure,_that.backMeasure,_that.clientName,_that.clientDocument,_that.whatsappNumber,_that.documents,_that.mapPolygons);case _:
  return null;

}
}

}

/// @nodoc


class _Lot extends Lot {
  const _Lot({required this.id, required this.block, required this.number, required this.area, required this.price, required this.status, this.svgCoordinates, this.landName, this.registration, this.frontMeasure, this.backMeasure, this.clientName, this.clientDocument, this.whatsappNumber, final  List<String>? documents, final  List<List<double>>? mapPolygons}): _documents = documents,_mapPolygons = mapPolygons,super._();
  

@override final  String id;
@override final  String block;
@override final  String number;
@override final  double area;
@override final  double price;
@override final  String status;
@override final  String? svgCoordinates;
// Campos adicionais para paridade com o design de referência.
@override final  String? landName;
// nome do loteamento, ex: "Loteamento Biopark"
@override final  String? registration;
// matrícula do imóvel
@override final  double? frontMeasure;
// "frente" em metros
@override final  double? backMeasure;
// "fundo" em metros
@override final  String? clientName;
// nome do cliente (se reservado/vendido)
@override final  String? clientDocument;
// documento do cliente
@override final  String? whatsappNumber;
// WhatsApp comercial do loteamento
 final  List<String>? _documents;
// WhatsApp comercial do loteamento
@override List<String>? get documents {
  final value = _documents;
  if (value == null) return null;
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Documentos anexados
 final  List<List<double>>? _mapPolygons;
// Documentos anexados
@override List<List<double>>? get mapPolygons {
  final value = _mapPolygons;
  if (value == null) return null;
  if (_mapPolygons is EqualUnmodifiableListView) return _mapPolygons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotCopyWith<_Lot> get copyWith => __$LotCopyWithImpl<_Lot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lot&&(identical(other.id, id) || other.id == id)&&(identical(other.block, block) || other.block == block)&&(identical(other.number, number) || other.number == number)&&(identical(other.area, area) || other.area == area)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status)&&(identical(other.svgCoordinates, svgCoordinates) || other.svgCoordinates == svgCoordinates)&&(identical(other.landName, landName) || other.landName == landName)&&(identical(other.registration, registration) || other.registration == registration)&&(identical(other.frontMeasure, frontMeasure) || other.frontMeasure == frontMeasure)&&(identical(other.backMeasure, backMeasure) || other.backMeasure == backMeasure)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.clientDocument, clientDocument) || other.clientDocument == clientDocument)&&(identical(other.whatsappNumber, whatsappNumber) || other.whatsappNumber == whatsappNumber)&&const DeepCollectionEquality().equals(other._documents, _documents)&&const DeepCollectionEquality().equals(other._mapPolygons, _mapPolygons));
}


@override
int get hashCode => Object.hash(runtimeType,id,block,number,area,price,status,svgCoordinates,landName,registration,frontMeasure,backMeasure,clientName,clientDocument,whatsappNumber,const DeepCollectionEquality().hash(_documents),const DeepCollectionEquality().hash(_mapPolygons));

@override
String toString() {
  return 'Lot(id: $id, block: $block, number: $number, area: $area, price: $price, status: $status, svgCoordinates: $svgCoordinates, landName: $landName, registration: $registration, frontMeasure: $frontMeasure, backMeasure: $backMeasure, clientName: $clientName, clientDocument: $clientDocument, whatsappNumber: $whatsappNumber, documents: $documents, mapPolygons: $mapPolygons)';
}


}

/// @nodoc
abstract mixin class _$LotCopyWith<$Res> implements $LotCopyWith<$Res> {
  factory _$LotCopyWith(_Lot value, $Res Function(_Lot) _then) = __$LotCopyWithImpl;
@override @useResult
$Res call({
 String id, String block, String number, double area, double price, String status, String? svgCoordinates, String? landName, String? registration, double? frontMeasure, double? backMeasure, String? clientName, String? clientDocument, String? whatsappNumber, List<String>? documents, List<List<double>>? mapPolygons
});




}
/// @nodoc
class __$LotCopyWithImpl<$Res>
    implements _$LotCopyWith<$Res> {
  __$LotCopyWithImpl(this._self, this._then);

  final _Lot _self;
  final $Res Function(_Lot) _then;

/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? block = null,Object? number = null,Object? area = null,Object? price = null,Object? status = null,Object? svgCoordinates = freezed,Object? landName = freezed,Object? registration = freezed,Object? frontMeasure = freezed,Object? backMeasure = freezed,Object? clientName = freezed,Object? clientDocument = freezed,Object? whatsappNumber = freezed,Object? documents = freezed,Object? mapPolygons = freezed,}) {
  return _then(_Lot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as double,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,svgCoordinates: freezed == svgCoordinates ? _self.svgCoordinates : svgCoordinates // ignore: cast_nullable_to_non_nullable
as String?,landName: freezed == landName ? _self.landName : landName // ignore: cast_nullable_to_non_nullable
as String?,registration: freezed == registration ? _self.registration : registration // ignore: cast_nullable_to_non_nullable
as String?,frontMeasure: freezed == frontMeasure ? _self.frontMeasure : frontMeasure // ignore: cast_nullable_to_non_nullable
as double?,backMeasure: freezed == backMeasure ? _self.backMeasure : backMeasure // ignore: cast_nullable_to_non_nullable
as double?,clientName: freezed == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String?,clientDocument: freezed == clientDocument ? _self.clientDocument : clientDocument // ignore: cast_nullable_to_non_nullable
as String?,whatsappNumber: freezed == whatsappNumber ? _self.whatsappNumber : whatsappNumber // ignore: cast_nullable_to_non_nullable
as String?,documents: freezed == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<String>?,mapPolygons: freezed == mapPolygons ? _self._mapPolygons : mapPolygons // ignore: cast_nullable_to_non_nullable
as List<List<double>>?,
  ));
}


}

// dart format on
