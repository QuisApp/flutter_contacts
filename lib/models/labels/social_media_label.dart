import 'dart:io';

/// Social media profile label types.
///
/// | Label          | Android | iOS |
/// |----------------|:-------:|:---:|
/// | aim            | ✔       | ✔   |
/// | facebook       | ⨯       | ✔   |
/// | flickr         | ⨯       | ✔   |
/// | gameCenter     | ⨯       | ✔   |
/// | gaduGadu       | ⨯       | ✔   |
/// | googleTalk     | ✔       | ✔   |
/// | icq            | ✔       | ✔   |
/// | jabber         | ✔       | ✔   |
/// | linkedIn       | ⨯       | ✔   |
/// | msn            | ✔       | ✔   |
/// | mySpace        | ⨯       | ✔   |
/// | netmeeting     | ✔       | ⨯   |
/// | qq             | ✔       | ✔   |
/// | sinaWeibo      | ⨯       | ✔   |
/// | skype          | ✔       | ✔   |
/// | tencentWeibo   | ⨯       | ✔   |
/// | twitter        | ⨯       | ✔   |
/// | yahoo          | ✔       | ✔   |
/// | yelp           | ⨯       | ✔   |
/// | other¹         | ✔       | ✔   |
/// | custom         | ✔       | ✔   |
///
/// ¹ The other label is not natively supported on either platform and will
/// be converted to custom with "other" as the raw string value. It was included
/// to provide a default label that is not arbitrarily one of the supported
/// providers.
enum SocialMediaLabel {
  aim,
  facebook,
  flickr,
  gameCenter,
  gaduGadu,
  googleTalk,
  icq,
  jabber,
  linkedIn,
  msn,
  mySpace,
  netmeeting,
  qq,
  sinaWeibo,
  skype,
  tencentWeibo,
  twitter,
  yahoo,
  yelp,
  other,
  custom;

  static const _android = {
    SocialMediaLabel.aim,
    SocialMediaLabel.googleTalk,
    SocialMediaLabel.icq,
    SocialMediaLabel.jabber,
    SocialMediaLabel.msn,
    SocialMediaLabel.netmeeting,
    SocialMediaLabel.qq,
    SocialMediaLabel.skype,
    SocialMediaLabel.yahoo,
    SocialMediaLabel.other,
    SocialMediaLabel.custom,
  };

  static const _apple = {
    SocialMediaLabel.aim,
    SocialMediaLabel.facebook,
    SocialMediaLabel.flickr,
    SocialMediaLabel.gameCenter,
    SocialMediaLabel.gaduGadu,
    SocialMediaLabel.googleTalk,
    SocialMediaLabel.icq,
    SocialMediaLabel.jabber,
    SocialMediaLabel.linkedIn,
    SocialMediaLabel.msn,
    SocialMediaLabel.mySpace,
    SocialMediaLabel.qq,
    SocialMediaLabel.sinaWeibo,
    SocialMediaLabel.skype,
    SocialMediaLabel.tencentWeibo,
    SocialMediaLabel.twitter,
    SocialMediaLabel.yahoo,
    SocialMediaLabel.yelp,
    SocialMediaLabel.other,
    SocialMediaLabel.custom,
  };

  bool get isSupported {
    if (Platform.isAndroid) return _android.contains(this);
    if (Platform.isIOS || Platform.isMacOS) return _apple.contains(this);
    return true;
  }
}
