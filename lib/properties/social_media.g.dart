// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialMedia _$SocialMediaFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      allowedKeys: const ['userName', 'label', 'customLabel'],
      requiredKeys: const ['userName']);
  return SocialMedia(
    json['userName'] as String,
    label: _$enumDecodeNullable(_$SocialMediaLabelEnumMap, json['label']) ??
        SocialMediaLabel.other,
    customLabel: json['customLabel'] as String ?? '',
  );
}

Map<String, dynamic> _$SocialMediaToJson(SocialMedia instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'label': _$SocialMediaLabelEnumMap[instance.label],
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

const _$SocialMediaLabelEnumMap = {
  SocialMediaLabel.aim: 'aim',
  SocialMediaLabel.baiduTieba: 'baiduTieba',
  SocialMediaLabel.discord: 'discord',
  SocialMediaLabel.facebook: 'facebook',
  SocialMediaLabel.flickr: 'flickr',
  SocialMediaLabel.gaduGadu: 'gaduGadu',
  SocialMediaLabel.gameCenter: 'gameCenter',
  SocialMediaLabel.googleTalk: 'googleTalk',
  SocialMediaLabel.icq: 'icq',
  SocialMediaLabel.instagram: 'instagram',
  SocialMediaLabel.jabber: 'jabber',
  SocialMediaLabel.line: 'line',
  SocialMediaLabel.linkedIn: 'linkedIn',
  SocialMediaLabel.medium: 'medium',
  SocialMediaLabel.messenger: 'messenger',
  SocialMediaLabel.msn: 'msn',
  SocialMediaLabel.mySpace: 'mySpace',
  SocialMediaLabel.netmeeting: 'netmeeting',
  SocialMediaLabel.pinterest: 'pinterest',
  SocialMediaLabel.qqchat: 'qqchat',
  SocialMediaLabel.qzone: 'qzone',
  SocialMediaLabel.reddit: 'reddit',
  SocialMediaLabel.sinaWeibo: 'sinaWeibo',
  SocialMediaLabel.skype: 'skype',
  SocialMediaLabel.snapchat: 'snapchat',
  SocialMediaLabel.telegram: 'telegram',
  SocialMediaLabel.tencentWeibo: 'tencentWeibo',
  SocialMediaLabel.tikTok: 'tikTok',
  SocialMediaLabel.tumblr: 'tumblr',
  SocialMediaLabel.twitter: 'twitter',
  SocialMediaLabel.viber: 'viber',
  SocialMediaLabel.wechat: 'wechat',
  SocialMediaLabel.whatsapp: 'whatsapp',
  SocialMediaLabel.yahoo: 'yahoo',
  SocialMediaLabel.yelp: 'yelp',
  SocialMediaLabel.youtube: 'youtube',
  SocialMediaLabel.zoom: 'zoom',
  SocialMediaLabel.other: 'other',
  SocialMediaLabel.custom: 'custom',
};
