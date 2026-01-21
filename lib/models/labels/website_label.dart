import 'dart:io';

/// Website URL label types.
///
/// | Label     | Android | iOS |
/// |-----------|:-------:|:---:|
/// | blog      | ✔       | ⨯   |
/// | ftp       | ✔       | ⨯   |
/// | home      | ✔       | ✔   |
/// | homepage  | ✔       | ✔   |
/// | profile   | ✔       | ⨯   |
/// | school    | ⨯       | ✔   |
/// | work      | ✔       | ✔   |
/// | other     | ✔       | ✔   |
/// | custom    | ✔       | ✔   |
enum WebsiteLabel {
  blog,
  ftp,
  home,
  homepage,
  profile,
  school,
  work,
  other,
  custom;

  static const _android = {
    WebsiteLabel.blog,
    WebsiteLabel.ftp,
    WebsiteLabel.home,
    WebsiteLabel.homepage,
    WebsiteLabel.profile,
    WebsiteLabel.work,
    WebsiteLabel.other,
    WebsiteLabel.custom,
  };

  static const _apple = {
    WebsiteLabel.home,
    WebsiteLabel.homepage,
    WebsiteLabel.school,
    WebsiteLabel.work,
    WebsiteLabel.other,
    WebsiteLabel.custom,
  };

  bool get isSupported {
    if (Platform.isAndroid) return _android.contains(this);
    if (Platform.isIOS || Platform.isMacOS) return _apple.contains(this);
    return true;
  }
}
