import 'package:json_annotation/json_annotation.dart';

part 'email.g.dart';

/// An email address
///
/// | Field              | Android | iOS |
/// |--------------------|:-------:|:---:|
/// | address            | ✔       | ✔   |
/// | label              | ✔       | ✔   |
/// | customLabel        | ✔       | ✔   |
/// | isPrimary          | ✔       | ⨯   |
@JsonSerializable(disallowUnrecognizedKeys: true)
class Email {
  /// Email address.
  @JsonKey(required: true)
  String address;

  /// The label or type of email it is. If `custom`, the free-form label can be
  /// found in [customLabel].
  @JsonKey(defaultValue: EmailLabel.home)
  EmailLabel label;

  /// If [customLabel] is [EmailLabel.custom], free-form user-chosen label.
  @JsonKey(defaultValue: "")
  String customLabel;

  /// Android has a notion of primary email, so that "send an email to X" means
  /// sending an email to X's primary email, in case there are multiple. Android
  /// only.
  @JsonKey(defaultValue: false)
  bool isPrimary;

  Email(this.address,
      {this.label = EmailLabel.home,
      this.customLabel = "",
      this.isPrimary = false});

  factory Email.fromJson(Map<String, dynamic> json) => _$EmailFromJson(json);
  Map<String, dynamic> toJson() => _$EmailToJson(this);
}

/// Email labels
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
