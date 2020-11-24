// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      allowedKeys: const ['rawId', 'type', 'name', 'mimetypes'],
      requiredKeys: const ['rawId', 'type', 'name']);
  return Account(
    json['rawId'] as String,
    json['type'] as String,
    json['name'] as String,
    (json['mimetypes'] as List)?.map((e) => e as String)?.toList() ?? [],
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'rawId': instance.rawId,
      'type': instance.type,
      'name': instance.name,
      'mimetypes': instance.mimetypes,
    };
