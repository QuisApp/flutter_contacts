import 'package:json_annotation/json_annotation.dart';

part 'name.g.dart';

/// A structured name.
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
@JsonSerializable(disallowUnrecognizedKeys: true)
class Name {
  /// First name / given name
  @JsonKey(defaultValue: "")
  String first;

  /// Last name / surname / family name
  @JsonKey(defaultValue: "")
  String last;

  /// Middle name (US). Could mean additional names in other countries
  /// (e.g. France)
  @JsonKey(defaultValue: "")
  String middle;

  /// Prefix (US) or title, e.g. Dr, Mr, Sir, etc
  @JsonKey(defaultValue: "")
  String prefix;

  /// Suffix (US), e.g Jr or III
  @JsonKey(defaultValue: "")
  String suffix;

  /// Nickname, e.g. maiden name, short name, initials, or any other name.
  @JsonKey(defaultValue: "")
  String nickname;

  /// Phonetic version of the first name (usually for Chinese/Japanese/Korean
  /// names)
  @JsonKey(defaultValue: "")
  String firstPhonetic;

  /// Phonetic version of the last name (usually for Chinese/Japanese/Korean
  /// names)
  @JsonKey(defaultValue: "")
  String lastPhonetic;

  /// Phonetic version of the middle name (usually for Chinese/Japanese/Korean
  /// names)
  @JsonKey(defaultValue: "")
  String middlePhonetic;

  Name(
      {this.first = "",
      this.last = "",
      this.middle = "",
      this.prefix = "",
      this.suffix = "",
      this.nickname = "",
      this.firstPhonetic = "",
      this.lastPhonetic = "",
      this.middlePhonetic = ""});

  factory Name.fromJson(Map<String, dynamic> json) => _$NameFromJson(json);
  Map<String, dynamic> toJson() => _$NameToJson(this);
}
