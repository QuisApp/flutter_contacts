import 'package:flutter_contacts/vcard.dart';

/// Structured name.
///
/// Name structure varies widely by country. See:
/// https://en.wikipedia.org/wiki/Personal_name#Structure
///
/// Data models such as those from Android and iOS are typically US-centric and
/// include middle name, prefix, suffix, etc. They also always include a
/// formatted displayed, which we recommend to use instead. That said, other
/// fields are included for compatibility, except for first and last names which
/// are common in most countries.
///
/// Since display name is always part of the top-level contact, it's not
/// included here.
///
/// Note that Android allows multiple names, while iOS allows only one. However
/// use cases for multiple names are debatable, especially since there is no
/// notion of "primary" name even on Android, and it is very common to see
/// multiple identical instances of the same name for the same contact. For all
/// those reasons, we only support one name per contact.
///
/// Note also that on iOS, nickname is included in the name fields (and again
/// only one is allowed), while on Android nickname is a separate data model and
/// one contact can have multiple nicknames, independent of their names. They
/// can also have distinct labels to indicate what type of nickname they are
/// (maiden name, short name, initials, default, other or any custom label). To
/// simplify, we only consider nickname as just another name field, and
/// disregard nickname labels.
///
/// | Field              | Android | iOS |
/// |--------------------|:-------:|:---:|
/// | first              | ✔       | ✔   |
/// | last               | ✔       | ✔   |
/// | middle             | ✔       | ✔   |
/// | prefix             | ✔       | ✔   |
/// | suffix             | ✔       | ✔   |
/// | nickname           | ✔       | ✔   |
/// | firstPhonetic      | ✔       | ✔   |
/// | lastPhonetic       | ✔       | ✔   |
/// | middlePhonetic     | ✔       | ✔   |
class Name {
  /// First name / given name.
  String first;

  /// Last name / family name.
  String last;

  /// Middle name.
  String middle;

  /// Prefix / title, e.g. "Dr" in American names.
  String prefix;

  /// Suffix, e.g. "Jr" in American names.
  String suffix;

  /// Nickname / short name.
  String nickname;

  /// Phonetic first name.
  String firstPhonetic;

  /// Phonetic last name.
  String lastPhonetic;

  /// Phonetic middle name.
  String middlePhonetic;

  Name({
    this.first = '',
    this.last = '',
    this.middle = '',
    this.prefix = '',
    this.suffix = '',
    this.nickname = '',
    this.firstPhonetic = '',
    this.lastPhonetic = '',
    this.middlePhonetic = '',
  });

  factory Name.fromJson(Map<String, dynamic> json) => Name(
        first: (json['first'] as String?) ?? '',
        last: (json['last'] as String?) ?? '',
        middle: (json['middle'] as String?) ?? '',
        prefix: (json['prefix'] as String?) ?? '',
        suffix: (json['suffix'] as String?) ?? '',
        nickname: (json['nickname'] as String?) ?? '',
        firstPhonetic: (json['firstPhonetic'] as String?) ?? '',
        lastPhonetic: (json['lastPhonetic'] as String?) ?? '',
        middlePhonetic: (json['middlePhonetic'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'first': first,
        'last': last,
        'middle': middle,
        'prefix': prefix,
        'suffix': suffix,
        'nickname': nickname,
        'firstPhonetic': firstPhonetic,
        'lastPhonetic': lastPhonetic,
        'middlePhonetic': middlePhonetic,
      };

  @override
  int get hashCode =>
      first.hashCode ^
      last.hashCode ^
      middle.hashCode ^
      prefix.hashCode ^
      suffix.hashCode ^
      nickname.hashCode ^
      firstPhonetic.hashCode ^
      lastPhonetic.hashCode ^
      middlePhonetic.hashCode;

  @override
  bool operator ==(Object o) =>
      o is Name &&
      o.first == first &&
      o.last == last &&
      o.middle == middle &&
      o.prefix == prefix &&
      o.suffix == suffix &&
      o.nickname == nickname &&
      o.firstPhonetic == firstPhonetic &&
      o.lastPhonetic == lastPhonetic &&
      o.middlePhonetic == middlePhonetic;

  @override
  String toString() =>
      'Name(first=$first, last=$last, middle=$middle, prefix=$prefix, '
      'suffix=$suffix, nickname=$nickname, firstPhonetic=$firstPhonetic, '
      'lastPhonetic=$lastPhonetic, middlePhonetic=$middlePhonetic)';

  List<String> toVCard() {
    // N (V3): https://tools.ietf.org/html/rfc2426#section-3.1.2
    // NICKNAME (V3): https://tools.ietf.org/html/rfc2426#section-3.1.3
    // N (V4): https://tools.ietf.org/html/rfc6350#section-6.2.2
    // NICKNAME (V4): https://tools.ietf.org/html/rfc6350#section-6.2.3
    var lines = <String>[];
    final components = [last, first, middle, prefix, suffix];
    if (components.any((x) => x.isNotEmpty)) {
      lines.add('N:' + components.map(vCardEncode).join(';'));
    }
    if (nickname.isNotEmpty) {
      lines.add('NICKNAME:' + vCardEncode(nickname));
    }
    return lines;
  }
}
