import '../../utils/json_helpers.dart';

/// Organization property.
///
/// Android allows multiple organizations per contact; iOS/macOS allows only one.
///
/// | Field           | Android | iOS |
/// |-----------------|:-------:|:---:|
/// | name            | ✔       | ✔   |
/// | jobTitle        | ✔       | ✔   |
/// | departmentName  | ✔       | ✔   |
/// | phoneticName    | ✔       | ✔   |
/// | jobDescription  | ✔       | ⨯   |
/// | symbol          | ✔       | ⨯   |
/// | officeLocation  | ✔       | ⨯   |
class Organization {
  /// Company or organization name.
  final String? name;

  /// Job title.
  final String? jobTitle;

  /// Department name.
  final String? departmentName;

  /// Phonetic company name.
  final String? phoneticName;

  /// Job description (Android only).
  final String? jobDescription;

  /// Company symbol or ticker (Android only).
  final String? symbol;

  /// Office location (Android only).
  final String? officeLocation;

  const Organization({
    this.name,
    this.jobTitle,
    this.departmentName,
    this.phoneticName,
    this.jobDescription,
    this.symbol,
    this.officeLocation,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    JsonHelpers.encode(json, 'name', name);
    JsonHelpers.encode(json, 'jobTitle', jobTitle);
    JsonHelpers.encode(json, 'departmentName', departmentName);
    JsonHelpers.encode(json, 'phoneticName', phoneticName);
    JsonHelpers.encode(json, 'jobDescription', jobDescription);
    JsonHelpers.encode(json, 'symbol', symbol);
    JsonHelpers.encode(json, 'officeLocation', officeLocation);
    return json;
  }

  static Organization fromJson(Map json) {
    return Organization(
      name: JsonHelpers.decode<String>(json['name']),
      jobTitle: JsonHelpers.decode<String>(json['jobTitle']),
      departmentName: JsonHelpers.decode<String>(json['departmentName']),
      phoneticName: JsonHelpers.decode<String>(json['phoneticName']),
      jobDescription: JsonHelpers.decode<String>(json['jobDescription']),
      symbol: JsonHelpers.decode<String>(json['symbol']),
      officeLocation: JsonHelpers.decode<String>(json['officeLocation']),
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('Organization', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Organization &&
          name == other.name &&
          jobTitle == other.jobTitle &&
          departmentName == other.departmentName &&
          phoneticName == other.phoneticName &&
          jobDescription == other.jobDescription &&
          symbol == other.symbol &&
          officeLocation == other.officeLocation);

  @override
  int get hashCode => Object.hash(
    name,
    jobTitle,
    departmentName,
    phoneticName,
    jobDescription,
    symbol,
    officeLocation,
  );

  Organization copyWith({
    String? name,
    String? jobTitle,
    String? departmentName,
    String? phoneticName,
    String? jobDescription,
    String? symbol,
    String? officeLocation,
  }) => Organization(
    name: name ?? this.name,
    jobTitle: jobTitle ?? this.jobTitle,
    departmentName: departmentName ?? this.departmentName,
    phoneticName: phoneticName ?? this.phoneticName,
    jobDescription: jobDescription ?? this.jobDescription,
    symbol: symbol ?? this.symbol,
    officeLocation: officeLocation ?? this.officeLocation,
  );
}
