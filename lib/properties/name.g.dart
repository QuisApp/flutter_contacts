// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Name _$NameFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const [
    'first',
    'last',
    'middle',
    'prefix',
    'suffix',
    'nickname',
    'firstPhonetic',
    'lastPhonetic',
    'middlePhonetic'
  ]);
  return Name(
    first: json['first'] as String ?? '',
    last: json['last'] as String ?? '',
    middle: json['middle'] as String ?? '',
    prefix: json['prefix'] as String ?? '',
    suffix: json['suffix'] as String ?? '',
    nickname: json['nickname'] as String ?? '',
    firstPhonetic: json['firstPhonetic'] as String ?? '',
    lastPhonetic: json['lastPhonetic'] as String ?? '',
    middlePhonetic: json['middlePhonetic'] as String ?? '',
  );
}

Map<String, dynamic> _$NameToJson(Name instance) => <String, dynamic>{
      'first': instance.first,
      'last': instance.last,
      'middle': instance.middle,
      'prefix': instance.prefix,
      'suffix': instance.suffix,
      'nickname': instance.nickname,
      'firstPhonetic': instance.firstPhonetic,
      'lastPhonetic': instance.lastPhonetic,
      'middlePhonetic': instance.middlePhonetic,
    };
