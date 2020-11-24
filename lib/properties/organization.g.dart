// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organization _$OrganizationFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const [
    'company',
    'title',
    'department',
    'jobDescription',
    'symbol',
    'phoneticName',
    'officeLocation'
  ]);
  return Organization(
    company: json['company'] as String ?? '',
    title: json['title'] as String ?? '',
    department: json['department'] as String ?? '',
    jobDescription: json['jobDescription'] as String ?? '',
    symbol: json['symbol'] as String ?? '',
    phoneticName: json['phoneticName'] as String ?? '',
    officeLocation: json['officeLocation'] as String ?? '',
  );
}

Map<String, dynamic> _$OrganizationToJson(Organization instance) =>
    <String, dynamic>{
      'company': instance.company,
      'title': instance.title,
      'department': instance.department,
      'jobDescription': instance.jobDescription,
      'symbol': instance.symbol,
      'phoneticName': instance.phoneticName,
      'officeLocation': instance.officeLocation,
    };
