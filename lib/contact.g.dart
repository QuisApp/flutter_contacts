// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map json) {
  $checkKeys(json, requiredKeys: const ['id', 'displayName']);
  return Contact(
    json['id'] as String,
    json['displayName'] as String,
    name: json['name'] == null
        ? null
        : Name.fromJson((json['name'] as Map)?.map(
            (k, e) => MapEntry(k as String, e),
          )),
    phones: (json['phones'] as List)
            ?.map((e) => e == null
                ? null
                : Phone.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList() ??
        [],
    emails: (json['emails'] as List)
            ?.map((e) => e == null
                ? null
                : Email.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList() ??
        [],
    addresses: (json['addresses'] as List)
            ?.map((e) => e == null
                ? null
                : Address.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList() ??
        [],
    organizations: (json['organizations'] as List)
            ?.map((e) => e == null
                ? null
                : Organization.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList() ??
        [],
    websites: (json['websites'] as List)
            ?.map((e) => e == null
                ? null
                : Website.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList() ??
        [],
    socialMedias: (json['socialMedias'] as List)
            ?.map((e) => e == null
                ? null
                : SocialMedia.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList() ??
        [],
    events: (json['events'] as List)
            ?.map((e) => e == null
                ? null
                : Event.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList() ??
        [],
    notes: (json['notes'] as List)
            ?.map((e) => e == null
                ? null
                : Note.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList() ??
        [],
    accounts: (json['accounts'] as List)
            ?.map((e) => e == null
                ? null
                : Account.fromJson((e as Map)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'name': instance.name?.toJson(),
      'phones': instance.phones?.map((e) => e?.toJson())?.toList(),
      'emails': instance.emails?.map((e) => e?.toJson())?.toList(),
      'addresses': instance.addresses?.map((e) => e?.toJson())?.toList(),
      'organizations':
          instance.organizations?.map((e) => e?.toJson())?.toList(),
      'websites': instance.websites?.map((e) => e?.toJson())?.toList(),
      'socialMedias': instance.socialMedias?.map((e) => e?.toJson())?.toList(),
      'events': instance.events?.map((e) => e?.toJson())?.toList(),
      'notes': instance.notes?.map((e) => e?.toJson())?.toList(),
      'accounts': instance.accounts?.map((e) => e?.toJson())?.toList(),
    };
