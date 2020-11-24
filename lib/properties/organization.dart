import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';

/// An organization or job.
///
/// Android allows multiple jobs while iOS supports only one.
///
/// +--------------------+---------+-----+
/// | field              | android | iOS |
/// +--------------------+---------+-----+
/// | company            | ✅      | ✅   |
/// | title              | ✅      | ✅   |
/// | department         | ✅      | ✅   |
/// | jobDescription     | ✅      | ❌   |
/// | symbol             | ✅      | ❌   |
/// | phoneticName       | ✅      | ✅   |
/// | officeLocation     | ✅      | ❌   |
/// +--------------------+---------+-----+
@JsonSerializable(disallowUnrecognizedKeys: true)
class Organization {
  /// Company name
  @JsonKey(defaultValue: "")
  String company;

  /// Position / job title
  @JsonKey(defaultValue: "")
  String title;

  /// Department at the company
  @JsonKey(defaultValue: "")
  String department;

  /// Job description
  @JsonKey(defaultValue: "")
  String jobDescription;

  /// Ticker or stock symbol
  @JsonKey(defaultValue: "")
  String symbol;

  /// Phonetic name of the company name
  @JsonKey(defaultValue: "")
  String phoneticName;

  /// Office location as a free-form address
  @JsonKey(defaultValue: "")
  String officeLocation;

  Organization({
    this.company = "",
    this.title = "",
    this.department = "",
    this.jobDescription = "",
    this.symbol = "",
    this.phoneticName = "",
    this.officeLocation = "",
  });

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizationToJson(this);
}
