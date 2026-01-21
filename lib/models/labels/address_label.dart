import 'dart:io';

/// Postal address label types.
///
/// | Label    | Android | iOS |
/// |----------|:-------:|:---:|
/// | home     | ✔       | ✔   |
/// | school   | ⨯       | ✔   |
/// | work     | ✔       | ✔   |
/// | other    | ✔       | ✔   |
/// | custom   | ✔       | ✔   |
enum AddressLabel {
  home,
  school,
  work,
  other,
  custom;

  static const _android = {
    AddressLabel.home,
    AddressLabel.work,
    AddressLabel.other,
    AddressLabel.custom,
  };

  static const _apple = {
    AddressLabel.home,
    AddressLabel.school,
    AddressLabel.work,
    AddressLabel.other,
    AddressLabel.custom,
  };

  bool get isSupported {
    if (Platform.isAndroid) return _android.contains(this);
    if (Platform.isIOS || Platform.isMacOS) return _apple.contains(this);
    return true;
  }
}
