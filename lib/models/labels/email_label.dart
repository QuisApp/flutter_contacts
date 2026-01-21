import 'dart:io';

/// Email address label types.
///
/// | Label    | Android | iOS |
/// |----------|:-------:|:---:|
/// | home     | ✔       | ✔   |
/// | iCloud   | ⨯       | ✔   |
/// | mobile   | ✔       | ⨯   |
/// | school   | ⨯       | ✔   |
/// | work     | ✔       | ✔   |
/// | other    | ✔       | ✔   |
/// | custom   | ✔       | ✔   |
enum EmailLabel {
  home,
  iCloud,
  mobile,
  school,
  work,
  other,
  custom;

  static const _android = {
    EmailLabel.home,
    EmailLabel.mobile,
    EmailLabel.work,
    EmailLabel.other,
    EmailLabel.custom,
  };

  static const _apple = {
    EmailLabel.home,
    EmailLabel.iCloud,
    EmailLabel.school,
    EmailLabel.work,
    EmailLabel.other,
    EmailLabel.custom,
  };

  bool get isSupported {
    if (Platform.isAndroid) return _android.contains(this);
    if (Platform.isIOS || Platform.isMacOS) return _apple.contains(this);
    return true;
  }
}
