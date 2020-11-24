// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Email _$EmailFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      allowedKeys: const ['address', 'label', 'customLabel', 'isPrimary'],
      requiredKeys: const ['address']);
  return Email(
    json['address'] as String,
    label: _$enumDecodeNullable(_$EmailLabelEnumMap, json['label']) ??
        EmailLabel.home,
    customLabel: json['customLabel'] as String ?? '',
    isPrimary: json['isPrimary'] as bool ?? false,
  );
}

Map<String, dynamic> _$EmailToJson(Email instance) => <String, dynamic>{
      'address': instance.address,
      'label': _$EmailLabelEnumMap[instance.label],
      'customLabel': instance.customLabel,
      'isPrimary': instance.isPrimary,
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

const _$EmailLabelEnumMap = {
  EmailLabel.home: 'home',
  EmailLabel.iCloud: 'iCloud',
  EmailLabel.mobile: 'mobile',
  EmailLabel.school: 'school',
  EmailLabel.work: 'work',
  EmailLabel.other: 'other',
  EmailLabel.custom: 'custom',
};
