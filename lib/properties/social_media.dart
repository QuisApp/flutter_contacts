import 'package:flutter_contacts/vcard.dart';

/// Social media / instant messaging profile.
///
/// Android and iOS define a few special account types (some of them defunct)
/// like AIM, MSN, Jabber, Netmeeting.
///
/// iOS distinguishes between instant messaging and social media, but both map
/// to [SocialMedia].
///
/// We add a few special values of our own, like Instagram, Twitter, TikTok,
/// Discord, etc. Source: https://buffer.com/library/social-media-sites/
class SocialMedia {
  /// Handle / username / login.
  String userName;

  /// Label / platform (default [SocialMediaLabel.other]).
  SocialMediaLabel label;

  /// Custom label, if [label] is [SocialMediaLabel.custom].
  String customLabel;

  SocialMedia(this.userName,
      {this.label = SocialMediaLabel.other, this.customLabel = ''});

  factory SocialMedia.fromJson(Map<String, dynamic> json) => SocialMedia(
        (json['userName'] as String?) ?? '',
        label: _stringToSocialMediaLabel[json['label'] as String? ?? ''] ??
            SocialMediaLabel.other,
        customLabel: (json['customLabel'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'label': _socialMediaLabelToString[label],
        'customLabel': customLabel,
      };

  @override
  int get hashCode => userName.hashCode ^ label.hashCode ^ customLabel.hashCode;

  @override
  bool operator ==(Object o) =>
      o is SocialMedia &&
      o.userName == userName &&
      o.label == label &&
      o.customLabel == customLabel;

  @override
  String toString() =>
      'SocialMedia(userName=$userName, label=$label, customLabel=$customLabel)';

  List<String> toVCard() {
    // IMPP (V3): https://tools.ietf.org/html/rfc4770
    // IMPP (V4): https://tools.ietf.org/html/rfc6350#section-6.4.3
    final protocol = label == SocialMediaLabel.custom
        ? customLabel
        : _socialMediaLabelToString[label]!;
    return ['IMPP:${vCardEncode(protocol)}:${vCardEncode(userName)}'];
  }
}

/// Social media labels.
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

final _socialMediaLabelToString = {
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

final _stringToSocialMediaLabel = {
  'aim': SocialMediaLabel.aim,
  'baiduTieba': SocialMediaLabel.baiduTieba,
  'discord': SocialMediaLabel.discord,
  'facebook': SocialMediaLabel.facebook,
  'flickr': SocialMediaLabel.flickr,
  'gaduGadu': SocialMediaLabel.gaduGadu,
  'gameCenter': SocialMediaLabel.gameCenter,
  'googleTalk': SocialMediaLabel.googleTalk,
  'icq': SocialMediaLabel.icq,
  'instagram': SocialMediaLabel.instagram,
  'jabber': SocialMediaLabel.jabber,
  'line': SocialMediaLabel.line,
  'linkedIn': SocialMediaLabel.linkedIn,
  'medium': SocialMediaLabel.medium,
  'messenger': SocialMediaLabel.messenger,
  'msn': SocialMediaLabel.msn,
  'mySpace': SocialMediaLabel.mySpace,
  'netmeeting': SocialMediaLabel.netmeeting,
  'pinterest': SocialMediaLabel.pinterest,
  'qqchat': SocialMediaLabel.qqchat,
  'qzone': SocialMediaLabel.qzone,
  'reddit': SocialMediaLabel.reddit,
  'sinaWeibo': SocialMediaLabel.sinaWeibo,
  'skype': SocialMediaLabel.skype,
  'snapchat': SocialMediaLabel.snapchat,
  'telegram': SocialMediaLabel.telegram,
  'tencentWeibo': SocialMediaLabel.tencentWeibo,
  'tikTok': SocialMediaLabel.tikTok,
  'tumblr': SocialMediaLabel.tumblr,
  'twitter': SocialMediaLabel.twitter,
  'viber': SocialMediaLabel.viber,
  'wechat': SocialMediaLabel.wechat,
  'whatsapp': SocialMediaLabel.whatsapp,
  'yahoo': SocialMediaLabel.yahoo,
  'yelp': SocialMediaLabel.yelp,
  'youtube': SocialMediaLabel.youtube,
  'zoom': SocialMediaLabel.zoom,
  'other': SocialMediaLabel.other,
  'custom': SocialMediaLabel.custom,
};

final lowerCaseStringToSocialMediaLabel = {
  'aim': SocialMediaLabel.aim,
  'baidu': SocialMediaLabel.baiduTieba,
  'baidutieba': SocialMediaLabel.baiduTieba,
  'discord': SocialMediaLabel.discord,
  'facebook': SocialMediaLabel.facebook,
  'flickr': SocialMediaLabel.flickr,
  'gadugadu': SocialMediaLabel.gaduGadu,
  'gamecenter': SocialMediaLabel.gameCenter,
  'googletalk': SocialMediaLabel.googleTalk,
  'icq': SocialMediaLabel.icq,
  'instagram': SocialMediaLabel.instagram,
  'jabber': SocialMediaLabel.jabber,
  'line': SocialMediaLabel.line,
  'linkedin': SocialMediaLabel.linkedIn,
  'medium': SocialMediaLabel.medium,
  'messenger': SocialMediaLabel.messenger,
  'msn': SocialMediaLabel.msn,
  'myspace': SocialMediaLabel.mySpace,
  'netmeeting': SocialMediaLabel.netmeeting,
  'pinterest': SocialMediaLabel.pinterest,
  'qq': SocialMediaLabel.qqchat,
  'qqchat': SocialMediaLabel.qqchat,
  'qzone': SocialMediaLabel.qzone,
  'reddit': SocialMediaLabel.reddit,
  'sina': SocialMediaLabel.sinaWeibo,
  'sinaweibo': SocialMediaLabel.sinaWeibo,
  'skype': SocialMediaLabel.skype,
  'snapchat': SocialMediaLabel.snapchat,
  'telegram': SocialMediaLabel.telegram,
  'tencent': SocialMediaLabel.tencentWeibo,
  'tencentweibo': SocialMediaLabel.tencentWeibo,
  'tiktok': SocialMediaLabel.tikTok,
  'tumblr': SocialMediaLabel.tumblr,
  'twitter': SocialMediaLabel.twitter,
  'viber': SocialMediaLabel.viber,
  'wechat': SocialMediaLabel.wechat,
  'whatsapp': SocialMediaLabel.whatsapp,
  'yahoo': SocialMediaLabel.yahoo,
  'yelp': SocialMediaLabel.yelp,
  'youtube': SocialMediaLabel.youtube,
  'zoom': SocialMediaLabel.zoom,
  'other': SocialMediaLabel.other,
  'custom': SocialMediaLabel.custom,
};
