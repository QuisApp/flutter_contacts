// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Website _$WebsiteFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      allowedKeys: const ['url', 'label', 'customLabel'],
      requiredKeys: const ['url']);
  return Website(
    json['url'] as String,
    label: _$enumDecodeNullable(_$WebsiteLabelEnumMap, json['label']) ??
        WebsiteLabel.homepage,
    customLabel: json['customLabel'] as String ?? '',
  );
}

Map<String, dynamic> _$WebsiteToJson(Website instance) => <String, dynamic>{
      'url': instance.url,
      'label': _$WebsiteLabelEnumMap[instance.label],
      'customLabel': instance.customLabel,
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

const _$WebsiteLabelEnumMap = {
  WebsiteLabel.blog: 'blog',
  WebsiteLabel.ftp: 'ftp',
  WebsiteLabel.home: 'home',
  WebsiteLabel.homepage: 'homepage',
  WebsiteLabel.profile: 'profile',
  WebsiteLabel.school: 'school',
  WebsiteLabel.work: 'work',
  WebsiteLabel.other: 'other',
  WebsiteLabel.custom: 'custom',
};
