import '../../utils/json_helpers.dart';

/// Structured name property.
///
/// [Contact.displayName] is computed automatically from these components by the
/// platform after saving.
///
/// Android allows multiple names per contact; iOS allows only one. This plugin
/// only supports one name per contact for simplicity.
///
/// | Field                | Android | iOS |
/// |----------------------|:-------:|:---:|
/// | first                | ✔       | ✔   |
/// | middle               | ✔       | ✔   |
/// | last                 | ✔       | ✔   |
/// | prefix               | ✔       | ✔   |
/// | suffix               | ✔       | ✔   |
/// | phoneticFirst        | ✔       | ✔   |
/// | phoneticMiddle       | ✔       | ✔   |
/// | phoneticLast         | ✔       | ✔   |
/// | previousFamilyName   | ⨯       | ✔   |
/// | nickname             | ✔       | ✔   |
class Name {
  /// First name.
  final String? first;

  /// Middle name.
  final String? middle;

  /// Last name.
  final String? last;

  /// Name prefix.
  final String? prefix;

  /// Name suffix.
  final String? suffix;

  /// Phonetic first name.
  final String? phoneticFirst;

  /// Phonetic middle name.
  final String? phoneticMiddle;

  /// Phonetic last name.
  final String? phoneticLast;

  /// Previous family name (iOS only, e.g., maiden name).
  final String? previousFamilyName;

  /// Nickname.
  final String? nickname;

  const Name({
    this.first,
    this.middle,
    this.last,
    this.prefix,
    this.suffix,
    this.phoneticFirst,
    this.phoneticMiddle,
    this.phoneticLast,
    this.previousFamilyName,
    this.nickname,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    JsonHelpers.encode(json, 'first', first);
    JsonHelpers.encode(json, 'middle', middle);
    JsonHelpers.encode(json, 'last', last);
    JsonHelpers.encode(json, 'prefix', prefix);
    JsonHelpers.encode(json, 'suffix', suffix);
    JsonHelpers.encode(json, 'phoneticFirst', phoneticFirst);
    JsonHelpers.encode(json, 'phoneticMiddle', phoneticMiddle);
    JsonHelpers.encode(json, 'phoneticLast', phoneticLast);
    JsonHelpers.encode(json, 'previousFamilyName', previousFamilyName);
    JsonHelpers.encode(json, 'nickname', nickname);
    return json;
  }

  static Name fromJson(Map json) {
    return Name(
      first: JsonHelpers.decode<String>(json['first']),
      middle: JsonHelpers.decode<String>(json['middle']),
      last: JsonHelpers.decode<String>(json['last']),
      prefix: JsonHelpers.decode<String>(json['prefix']),
      suffix: JsonHelpers.decode<String>(json['suffix']),
      phoneticFirst: JsonHelpers.decode<String>(json['phoneticFirst']),
      phoneticMiddle: JsonHelpers.decode<String>(json['phoneticMiddle']),
      phoneticLast: JsonHelpers.decode<String>(json['phoneticLast']),
      previousFamilyName: JsonHelpers.decode<String>(
        json['previousFamilyName'],
      ),
      nickname: JsonHelpers.decode<String>(json['nickname']),
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('Name', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Name &&
          first == other.first &&
          middle == other.middle &&
          last == other.last &&
          prefix == other.prefix &&
          suffix == other.suffix &&
          phoneticFirst == other.phoneticFirst &&
          phoneticMiddle == other.phoneticMiddle &&
          phoneticLast == other.phoneticLast &&
          previousFamilyName == other.previousFamilyName &&
          nickname == other.nickname);

  @override
  int get hashCode => Object.hash(
    first,
    middle,
    last,
    prefix,
    suffix,
    phoneticFirst,
    phoneticMiddle,
    phoneticLast,
    previousFamilyName,
    nickname,
  );

  Name copyWith({
    String? first,
    String? middle,
    String? last,
    String? prefix,
    String? suffix,
    String? phoneticFirst,
    String? phoneticMiddle,
    String? phoneticLast,
    String? previousFamilyName,
    String? nickname,
  }) => Name(
    first: first ?? this.first,
    middle: middle ?? this.middle,
    last: last ?? this.last,
    prefix: prefix ?? this.prefix,
    suffix: suffix ?? this.suffix,
    phoneticFirst: phoneticFirst ?? this.phoneticFirst,
    phoneticMiddle: phoneticMiddle ?? this.phoneticMiddle,
    phoneticLast: phoneticLast ?? this.phoneticLast,
    previousFamilyName: previousFamilyName ?? this.previousFamilyName,
    nickname: nickname ?? this.nickname,
  );
}
