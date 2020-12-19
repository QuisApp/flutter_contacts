import 'package:json_annotation/json_annotation.dart';

part 'website.g.dart';

/// A website or URL.
///
/// iOS and Android both support multiple websites with various labels.
@JsonSerializable(disallowUnrecognizedKeys: true)
class Website {
  /// The website/URL
  @JsonKey(required: true)
  String url;

  /// The label or type of URL it is. If `custom`, the free-form label can be
  /// found in [customLabel].
  @JsonKey(defaultValue: WebsiteLabel.homepage)
  WebsiteLabel label;

  /// If [customLabel] is [WebsiteLabel.custom], free-form user-chosen label.
  @JsonKey(defaultValue: "")
  String customLabel;

  Website(this.url,
      {this.label = WebsiteLabel.homepage, this.customLabel = ""});

  factory Website.fromJson(Map<String, dynamic> json) =>
      _$WebsiteFromJson(json);
  Map<String, dynamic> toJson() => _$WebsiteToJson(this);
}

/// Website labels
///
/// | Label    | Android | iOS |
/// |----------|:-------:|:---:|
/// | blog     | ✔       | ⨯   |
/// | ftp      | ✔       | ⨯   |
/// | home     | ✔       | ✔   |
/// | homepage | ✔       | ✔   |
/// | profile  | ✔       | ⨯   |
/// | school   | ⨯       | ✔   |
/// | work     | ✔       | ✔   |
/// | other    | ✔       | ✔   |
/// | custom   | ✔       | ✔   |
enum WebsiteLabel {
  blog,
  ftp,
  home,
  homepage,
  profile,
  school,
  work,
  other,
  custom,
}
