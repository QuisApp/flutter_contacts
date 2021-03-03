import 'package:flutter_contacts/config.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_contacts/vcard.dart';

/// Labeled email.
class Email {
  /// Email address.
  String address;

  /// Label (default [EmailLabel.home]).
  EmailLabel label;

  /// Custom label, if [label] is [EmailLabel.custom].
  String customLabel;

  /// Whether this is the email address to email by default for that contact
  /// (Android only).
  bool isPrimary;

  Email(
    this.address, {
    this.label = EmailLabel.home,
    this.customLabel = '',
    this.isPrimary = false,
  });

  factory Email.fromJson(Map<String, dynamic> json) => Email(
        (json['address'] as String?) ?? '',
        label: _stringToEmailLabel[json['label'] as String? ?? ''] ??
            EmailLabel.home,
        customLabel: (json['customLabel'] as String?) ?? '',
        isPrimary: (json['isPrimary'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address,
        'label': _emailLabelToString[label],
        'customLabel': customLabel,
        'isPrimary': isPrimary,
      };

  @override
  int get hashCode =>
      address.hashCode ^
      label.hashCode ^
      customLabel.hashCode ^
      isPrimary.hashCode;

  @override
  bool operator ==(Object o) =>
      o is Email &&
      o.address == address &&
      o.label == label &&
      o.customLabel == customLabel &&
      o.isPrimary == isPrimary;

  @override
  String toString() =>
      'Email(address=$address, label=$label, customLabel=$customLabel, '
      'isPrimary=$isPrimary)';

  List<String> toVCard() {
    // EMAIL (V3): https://tools.ietf.org/html/rfc2426#section-3.3.2
    // EMAIL (V4): https://tools.ietf.org/html/rfc6350#section-6.4.2
    var s = 'EMAIL';
    if (FlutterContacts.config.vCardVersion == VCardVersion.v3) {
      s += ';TYPE=internet';
    } else {
      switch (label) {
        case EmailLabel.home:
          s += ';TYPE=home';
          break;
        case EmailLabel.work:
          s += ';TYPE=work';
          break;
        default:
      }
    }
    if (isPrimary) {
      if (FlutterContacts.config.vCardVersion == VCardVersion.v3) {
        s += ',pref';
      } else {
        s += ';PREF=1';
      }
    }
    s += ':${vCardEncode(address)}';
    return [s];
  }
}

/// Email labels.
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
  custom,
}

final _emailLabelToString = {
  EmailLabel.home: 'home',
  EmailLabel.iCloud: 'iCloud',
  EmailLabel.mobile: 'mobile',
  EmailLabel.school: 'school',
  EmailLabel.work: 'work',
  EmailLabel.other: 'other',
  EmailLabel.custom: 'custom',
};

final _stringToEmailLabel = {
  'home': EmailLabel.home,
  'iCloud': EmailLabel.iCloud,
  'mobile': EmailLabel.mobile,
  'school': EmailLabel.school,
  'work': EmailLabel.work,
  'other': EmailLabel.other,
  'custom': EmailLabel.custom,
};
