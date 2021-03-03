import 'package:flutter_contacts/config.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_contacts/vcard.dart';

/// Labeled phone.
class Phone {
  /// Raw phone number.
  String number;

  /// Normalized number, e.g. +12345678900 for +1 (234) 567-8900 (android only).
  String normalizedNumber;

  /// Label (default [PhoneLabel.mobile]).
  PhoneLabel label;

  /// Custom label, if [label] is [PhoneLabel.custom].
  String customLabel;

  /// Whether this is the phone number to call by default for that contact
  /// (Android only).
  bool isPrimary;

  Phone(
    this.number, {
    this.normalizedNumber = '',
    this.label = PhoneLabel.mobile,
    this.customLabel = '',
    this.isPrimary = false,
  });

  factory Phone.fromJson(Map<String, dynamic> json) => Phone(
        (json['number'] as String?) ?? '',
        normalizedNumber: (json['normalizedNumber'] as String?) ?? '',
        label: _stringToPhoneLabel[json['label'] as String? ?? ''] ??
            PhoneLabel.mobile,
        customLabel: (json['customLabel'] as String?) ?? '',
        isPrimary: (json['isPrimary'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'number': number,
        'normalizedNumber': normalizedNumber,
        'label': _phoneLabelToString[label],
        'customLabel': customLabel,
        'isPrimary': isPrimary,
      };

  @override
  int get hashCode =>
      number.hashCode ^
      normalizedNumber.hashCode ^
      label.hashCode ^
      customLabel.hashCode ^
      isPrimary.hashCode;

  @override
  bool operator ==(Object o) =>
      o is Phone &&
      o.number == number &&
      o.normalizedNumber == normalizedNumber &&
      o.label == label &&
      o.customLabel == customLabel &&
      o.isPrimary == isPrimary;

  @override
  String toString() =>
      'Phone(number=$number, normalizedNumber=$normalizedNumber, label=$label, '
      'customLabel=$customLabel, isPrimary=$isPrimary)';

  List<String> toVCard() {
    // TEL (V3): https://tools.ietf.org/html/rfc2426#section-3.3.1
    // TEL (V4): https://tools.ietf.org/html/rfc6350#section-6.4.1
    final v4 = FlutterContacts.config.vCardVersion == VCardVersion.v4;
    var s = v4 ? 'TEL;VALUE=uri' : 'TEL';
    var types = <String>[];
    switch (label) {
      case PhoneLabel.faxHome:
        types.add('fax');
        types.add('home');
        break;
      case PhoneLabel.faxOther:
        types.add('fax');
        break;
      case PhoneLabel.faxWork:
        types.add('fax');
        types.add('work');
        break;
      case PhoneLabel.home:
        types.add('home');
        break;
      case PhoneLabel.iPhone:
      case PhoneLabel.main:
        types.add('voice');
        types.add(v4 ? 'text' : 'msg');
        break;
      case PhoneLabel.mms:
      case PhoneLabel.mobile:
        types.add('cell');
        types.add(v4 ? 'text' : 'msg');
        break;
      case PhoneLabel.workMobile:
        types.add('cell');
        types.add(v4 ? 'text' : 'msg');
        types.add('work');
        break;
      case PhoneLabel.pager:
        types.add('pager');
        break;
      case PhoneLabel.workPager:
        types.add('pager');
        types.add('work');
        break;
      default:
    }
    if (!v4 && isPrimary) {
      types.add('pref');
    }
    if (types.length == 1) {
      s += ';TYPE=${types.first}';
    } else if (types.length > 1) {
      if (v4) {
        s += ';TYPE="${types.join(',')}"';
      } else {
        s += ';TYPE=${types.join(',')}';
      }
    }
    if (v4 && isPrimary) {
      s += ';PREF=1';
    }
    if (v4) {
      s += ':tel:${vCardEncode(number)}';
    } else {
      s += ':${vCardEncode(number)}';
    }
    return [s];
  }
}

/// Phone labels.
///
/// | Label       | Android | iOS |
/// |-------------|:-------:|:---:|
/// | assistant   | ✔       | ⨯   |
/// | callback    | ✔       | ⨯   |
/// | car         | ✔       | ⨯   |
/// | companyMain | ✔       | ⨯   |
/// | faxHome     | ✔       | ✔   |
/// | faxOther    | ✔       | ✔   |
/// | faxWork     | ✔       | ✔   |
/// | home        | ✔       | ✔   |
/// | iPhone      | ⨯       | ✔   |
/// | isdn        | ✔       | ⨯   |
/// | main        | ✔       | ✔   |
/// | mms         | ✔       | ⨯   |
/// | mobile      | ✔       | ✔   |
/// | pager       | ✔       | ✔   |
/// | radio       | ✔       | ⨯   |
/// | school      | ⨯       | ✔   |
/// | telex       | ✔       | ⨯   |
/// | ttyTtd      | ✔       | ⨯   |
/// | work        | ✔       | ✔   |
/// | workMobile  | ✔       | ⨯   |
/// | workPager   | ✔       | ⨯   |
/// | other       | ✔       | ✔   |
/// | custom      | ✔       | ✔   |
enum PhoneLabel {
  assistant,
  callback,
  car,
  companyMain,
  faxHome,
  faxOther,
  faxWork,
  home,
  iPhone,
  isdn,
  main,
  mms,
  mobile,
  pager,
  radio,
  school,
  telex,
  ttyTtd,
  work,
  workMobile,
  workPager,
  other,
  custom,
}

final _phoneLabelToString = {
  PhoneLabel.assistant: 'assistant',
  PhoneLabel.callback: 'callback',
  PhoneLabel.car: 'car',
  PhoneLabel.companyMain: 'companyMain',
  PhoneLabel.faxHome: 'faxHome',
  PhoneLabel.faxOther: 'faxOther',
  PhoneLabel.faxWork: 'faxWork',
  PhoneLabel.home: 'home',
  PhoneLabel.iPhone: 'iPhone',
  PhoneLabel.isdn: 'isdn',
  PhoneLabel.main: 'main',
  PhoneLabel.mms: 'mms',
  PhoneLabel.mobile: 'mobile',
  PhoneLabel.pager: 'pager',
  PhoneLabel.radio: 'radio',
  PhoneLabel.school: 'school',
  PhoneLabel.telex: 'telex',
  PhoneLabel.ttyTtd: 'ttyTtd',
  PhoneLabel.work: 'work',
  PhoneLabel.workMobile: 'workMobile',
  PhoneLabel.workPager: 'workPager',
  PhoneLabel.other: 'other',
  PhoneLabel.custom: 'custom',
};

final _stringToPhoneLabel = {
  'assistant': PhoneLabel.assistant,
  'callback': PhoneLabel.callback,
  'car': PhoneLabel.car,
  'companyMain': PhoneLabel.companyMain,
  'faxHome': PhoneLabel.faxHome,
  'faxOther': PhoneLabel.faxOther,
  'faxWork': PhoneLabel.faxWork,
  'home': PhoneLabel.home,
  'iPhone': PhoneLabel.iPhone,
  'isdn': PhoneLabel.isdn,
  'main': PhoneLabel.main,
  'mms': PhoneLabel.mms,
  'mobile': PhoneLabel.mobile,
  'pager': PhoneLabel.pager,
  'radio': PhoneLabel.radio,
  'school': PhoneLabel.school,
  'telex': PhoneLabel.telex,
  'ttyTtd': PhoneLabel.ttyTtd,
  'work': PhoneLabel.work,
  'workMobile': PhoneLabel.workMobile,
  'workPager': PhoneLabel.workPager,
  'other': PhoneLabel.other,
  'custom': PhoneLabel.custom,
};
