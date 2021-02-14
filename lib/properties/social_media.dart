import 'package:json_annotation/json_annotation.dart';

part 'social_media.g.dart';

/// A social media or instant messaging account.
///
/// Android and iOS define a few special account types (some of them defunct)
/// like AIM, MSN, Jabber, Netmeeting.
///
/// iOS distinguishes between instant messaging and social media but doesn't
/// define any special account types. The default app does list a few, marked
/// with *️⃣ in the list below.
///
/// We add a few special values of our own, like Instagram, Twitter, TikTok,
/// Discord, etc. Source: https://buffer.com/library/social-media-sites/
@JsonSerializable(disallowUnrecognizedKeys: true)
class SocialMedia {
  /// The username/handle/login/URL
  @JsonKey(required: true)
  String userName;

  /// The label or type of SocialMedia it is. If `custom`, the free-form label
  /// can be found in [customLabel].
  @JsonKey(defaultValue: SocialMediaLabel.other)
  SocialMediaLabel label;

  /// If [customLabel] is [SocialMediaLabel.custom], free-form user-chosen
  /// label.
  @JsonKey(defaultValue: '')
  String customLabel;

  SocialMedia(this.userName,
      {this.label = SocialMediaLabel.other, this.customLabel = ''});

  factory SocialMedia.fromJson(Map<String, dynamic> json) =>
      _$SocialMediaFromJson(json);
  Map<String, dynamic> toJson() => _$SocialMediaToJson(this);
}

/// Social media labels
///
/// | Label        | Android | iOS |
/// |--------------|:-------:|:---:|
/// | aim          | ✔       | ✔   |
/// | baiduTieba   | ⨯       | ⨯   |
/// | discord      | ⨯       | ⨯   |
/// | facebook     | ⨯       | ✔   |
/// | flickr       | ⨯       | ✔   |
/// | gaduGadu     | ⨯       | ✔   |
/// | gameCenter   | ⨯       | ✔   |
/// | googleTalk   | ✔       | ✔   |
/// | icq          | ✔       | ✔   |
/// | instagram    | ⨯       | ⨯   |
/// | jabber       | ✔       | ✔   |
/// | line         | ⨯       | ⨯   |
/// | linkedIn     | ⨯       | ✔   |
/// | medium       | ⨯       | ⨯   |
/// | messenger    | ⨯       | ⨯   |
/// | msn          | ✔       | ✔   |
/// | myspace      | ⨯       | ✔   |
/// | netmeeting   | ✔       | ⨯   |
/// | pinterest    | ⨯       | ⨯   |
/// | qqchat       | ✔       | ✔   |
/// | qzone        | ⨯       | ⨯   |
/// | reddit       | ⨯       | ⨯   |
/// | sinaWeibo    | ⨯       | ✔   |
/// | skype        | ✔       | ✔   |
/// | snapchat     | ⨯       | ⨯   |
/// | telegram     | ⨯       | ⨯   |
/// | tencentWeibo | ⨯       | ✔   |
/// | tikTok       | ⨯       | ⨯   |
/// | tumblr       | ⨯       | ⨯   |
/// | twitter      | ⨯       | ✔   |
/// | viber        | ⨯       | ⨯   |
/// | wechat       | ⨯       | ⨯   |
/// | whatsapp     | ⨯       | ⨯   |
/// | yahoo        | ✔       | ✔   |
/// | yelp         | ✔       | ✔   |
/// | youtube      | ⨯       | ⨯   |
/// | zoom         | ⨯       | ⨯   |
/// | other        | ⨯       | ⨯   |
/// | custom       | ✔       | ✔   |
enum SocialMediaLabel {
  aim,
  baiduTieba,
  discord,
  facebook,
  flickr,
  gaduGadu,
  gameCenter,
  googleTalk,
  icq,
  instagram,
  jabber,
  line,
  linkedIn,
  medium,
  messenger,
  msn,
  mySpace,
  netmeeting,
  pinterest,
  qqchat,
  qzone,
  reddit,
  sinaWeibo,
  skype,
  snapchat,
  telegram,
  tencentWeibo,
  tikTok,
  tumblr,
  twitter,
  viber,
  wechat,
  whatsapp,
  yahoo,
  yelp,
  youtube,
  zoom,
  other,
  custom,
}
