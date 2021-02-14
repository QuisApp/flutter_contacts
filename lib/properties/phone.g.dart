// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phone _$PhoneFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const [
    'number',
    'normalizedNumber',
    'label',
    'customLabel',
    'isPrimary'
  ], requiredKeys: const [
    'number'
  ]);
  return Phone(
    json['number'] as String,
    normalizedNumber: json['normalizedNumber'] as String ?? '',
    label: _$enumDecodeNullable(_$PhoneLabelEnumMap, json['label']) ??
        PhoneLabel.mobile,
    customLabel: json['customLabel'] as String ?? '',
    isPrimary: json['isPrimary'] as bool ?? false,
  );
}

Map<String, dynamic> _$PhoneToJson(Phone instance) => <String, dynamic>{
      'number': instance.number,
      'normalizedNumber': instance.normalizedNumber,
      'label': _$PhoneLabelEnumMap[instance.label],
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

const _$PhoneLabelEnumMap = {
  PhoneLabel.assistant: 'assistant',
  PhoneLabel.callback: 'callback',
  PhoneLabel.car: 'car',
  PhoneLabel.companyMain: 'companyMain',
  PhoneLabel.faxHome: 'faxHome',
  PhoneLabel.faxOther: 'faxOther',
  PhoneLabel.faxWork: 'faxWork',
  PhoneLabel.home: 'home',
  PhoneLabel.iPhone: 'iPhone',
  PhoneLabel.isdn: 'isdn',
  PhoneLabel.main: 'main',
  PhoneLabel.mms: 'mms',
  PhoneLabel.mobile: 'mobile',
  PhoneLabel.pager: 'pager',
  PhoneLabel.radio: 'radio',
  PhoneLabel.school: 'school',
  PhoneLabel.telex: 'telex',
  PhoneLabel.ttyTtd: 'ttyTtd',
  PhoneLabel.work: 'work',
  PhoneLabel.workMobile: 'workMobile',
  PhoneLabel.workPager: 'workPager',
  PhoneLabel.other: 'other',
  PhoneLabel.custom: 'custom',
};
