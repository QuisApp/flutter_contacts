// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const [
    'address',
    'label',
    'customLabel',
    'street',
    'pobox',
    'neighborhood',
    'city',
    'state',
    'postalCode',
    'country',
    'isoCountry',
    'subAdminArea',
    'subLocality'
  ], requiredKeys: const [
    'address'
  ]);
  return Address(
    json['address'] as String,
    label: _$enumDecodeNullable(_$AddressLabelEnumMap, json['label']) ??
        AddressLabel.home,
    customLabel: json['customLabel'] as String ?? '',
    street: json['street'] as String ?? '',
    pobox: json['pobox'] as String ?? '',
    neighborhood: json['neighborhood'] as String ?? '',
    city: json['city'] as String ?? '',
    state: json['state'] as String ?? '',
    postalCode: json['postalCode'] as String ?? '',
    country: json['country'] as String ?? '',
    isoCountry: json['isoCountry'] as String ?? '',
    subAdminArea: json['subAdminArea'] as String ?? '',
    subLocality: json['subLocality'] as String ?? '',
  );
}

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'address': instance.address,
      'label': _$AddressLabelEnumMap[instance.label],
      'customLabel': instance.customLabel,
      'street': instance.street,
      'pobox': instance.pobox,
      'neighborhood': instance.neighborhood,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'isoCountry': instance.isoCountry,
      'subAdminArea': instance.subAdminArea,
      'subLocality': instance.subLocality,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$AddressLabelEnumMap = {
  AddressLabel.home: 'home',
  AddressLabel.school: 'school',
  AddressLabel.work: 'work',
  AddressLabel.other: 'other',
  AddressLabel.custom: 'custom',
};
