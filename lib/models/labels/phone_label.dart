import 'dart:io';

/// Phone number label types.
///
/// | Label         | Android | iOS |
/// |---------------|:-------:|:---:|
/// | appleWatch    | ⨯       | ✔   |
/// | assistant     | ✔       | ⨯   |
/// | callback      | ✔       | ⨯   |
/// | car           | ✔       | ⨯   |
/// | companyMain   | ✔       | ⨯   |
/// | home          | ✔       | ✔   |
/// | homeFax       | ✔       | ✔   |
/// | iPhone        | ⨯       | ✔   |
/// | isdn          | ✔       | ⨯   |
/// | main          | ✔       | ✔   |
/// | mobile        | ✔       | ✔   |
/// | mms           | ✔       | ⨯   |
/// | other         | ✔       | ✔   |
/// | otherFax      | ✔       | ✔   |
/// | pager         | ✔       | ✔   |
/// | radio         | ✔       | ⨯   |
/// | school        | ⨯       | ✔   |
/// | telex         | ✔       | ⨯   |
/// | ttyTdd        | ✔       | ⨯   |
/// | work          | ✔       | ✔   |
/// | workFax       | ✔       | ✔   |
/// | workMobile    | ✔       | ⨯   |
/// | workPager     | ✔       | ⨯   |
/// | custom        | ✔       | ✔   |
enum PhoneLabel {
  appleWatch,
  assistant,
  callback,
  car,
  companyMain,
  home,
  homeFax,
  iPhone,
  isdn,
  main,
  mobile,
  mms,
  other,
  otherFax,
  pager,
  radio,
  school,
  telex,
  ttyTdd,
  work,
  workFax,
  workMobile,
  workPager,
  custom;

  static const _android = {
    PhoneLabel.assistant,
    PhoneLabel.callback,
    PhoneLabel.car,
    PhoneLabel.companyMain,
    PhoneLabel.home,
    PhoneLabel.homeFax,
    PhoneLabel.isdn,
    PhoneLabel.main,
    PhoneLabel.mobile,
    PhoneLabel.mms,
    PhoneLabel.other,
    PhoneLabel.otherFax,
    PhoneLabel.pager,
    PhoneLabel.radio,
    PhoneLabel.telex,
    PhoneLabel.ttyTdd,
    PhoneLabel.work,
    PhoneLabel.workFax,
    PhoneLabel.workMobile,
    PhoneLabel.workPager,
    PhoneLabel.custom,
  };

  static const _apple = {
    PhoneLabel.appleWatch,
    PhoneLabel.home,
    PhoneLabel.homeFax,
    PhoneLabel.iPhone,
    PhoneLabel.main,
    PhoneLabel.mobile,
    PhoneLabel.other,
    PhoneLabel.otherFax,
    PhoneLabel.pager,
    PhoneLabel.school,
    PhoneLabel.work,
    PhoneLabel.workFax,
    PhoneLabel.custom,
  };

  bool get isSupported {
    if (Platform.isAndroid) return _android.contains(this);
    if (Platform.isIOS || Platform.isMacOS) return _apple.contains(this);
    return true;
  }
}
