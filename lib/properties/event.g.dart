// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      allowedKeys: const ['date', 'label', 'customLabel', 'noYear'],
      requiredKeys: const ['date']);
  return Event(
    Event._parseDate(json['date'] as String),
    label: _$enumDecodeNullable(_$EventLabelEnumMap, json['label']) ??
        EventLabel.birthday,
    customLabel: json['customLabel'] as String ?? '',
    noYear: json['noYear'] as bool ?? false,
  );
}

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'label': _$EventLabelEnumMap[instance.label],
      'customLabel': instance.customLabel,
      'noYear': instance.noYear,
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

const _$EventLabelEnumMap = {
  EventLabel.anniversary: 'anniversary',
  EventLabel.birthday: 'birthday',
  EventLabel.other: 'other',
  EventLabel.custom: 'custom',
};
