import 'package:flutter_contacts/vcard.dart';

/// Labeled website.
class Website {
  /// Website URL.
  String url;

  /// Label (default [WebsiteLabel.homepage]).
  WebsiteLabel label;

  /// Custom label, if [label] is [WebsiteLabel.custom].
  String customLabel;

  Website(this.url,
      {this.label = WebsiteLabel.homepage, this.customLabel = ''});

  factory Website.fromJson(Map<String, dynamic> json) => Website(
        (json['url'] as String?) ?? '',
        label: _stringToWebsiteLabel[json['label'] as String? ?? ''] ??
            WebsiteLabel.homepage,
        customLabel: (json['customLabel'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': url,
        'label': _websiteLabelToString[label],
        'customLabel': customLabel,
      };

  @override
  int get hashCode => url.hashCode ^ label.hashCode ^ customLabel.hashCode;

  @override
  bool operator ==(Object o) =>
      o is Website &&
      o.url == url &&
      o.label == label &&
      o.customLabel == customLabel;

  @override
  String toString() =>
      'Website(url=$url, label=$label, customLabel=$customLabel)';

  List<String> toVCard() {
    // URL (V3): https://tools.ietf.org/html/rfc2426#section-3.6.8
    // URL (V4): https://tools.ietf.org/html/rfc6350#section-6.7.8
    return ['URL:${vCardEncode(url)}'];
  }
}

/// Website labels.
///
/// | Label    | Android | iOS |
/// |----------|:-------:|:---:|
/// | blog     | ✔       | ⨯   |
/// | ftp      | ✔       | ⨯   |
/// | home     | ✔       | ✔   |
/// | homepage | ✔       | ✔   |
/// | profile  | ✔       | ⨯   |
/// | school   | ⨯       | ✔   |
/// | work     | ✔       | ✔   |
/// | other    | ✔       | ✔   |
/// | custom   | ✔       | ✔   |
enum WebsiteLabel {
  blog,
  ftp,
  home,
  homepage,
  profile,
  school,
  work,
  other,
  custom,
}

final _websiteLabelToString = {
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

final _stringToWebsiteLabel = {
  'blog': WebsiteLabel.blog,
  'ftp': WebsiteLabel.ftp,
  'home': WebsiteLabel.home,
  'homepage': WebsiteLabel.homepage,
  'profile': WebsiteLabel.profile,
  'school': WebsiteLabel.school,
  'work': WebsiteLabel.work,
  'other': WebsiteLabel.other,
  'custom': WebsiteLabel.custom,
};
