import 'package:flutter_contacts/vcard.dart';

/// Organization / job.
class Organization {
  /// Company name.
  String company;

  /// Job title.
  String title;

  /// Department.
  String department;

  /// Job description (Android only).
  String jobDescription;

  /// Ticker symbol (Android only).
  String symbol;

  /// Phonetic company name (Android and iOS10+ only).
  String phoneticName;

  /// Office location (Android only).
  String officeLocation;

  Organization({
    this.company = '',
    this.title = '',
    this.department = '',
    this.jobDescription = '',
    this.symbol = '',
    this.phoneticName = '',
    this.officeLocation = '',
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        company: (json['company'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        department: (json['department'] as String?) ?? '',
        jobDescription: (json['jobDescription'] as String?) ?? '',
        symbol: (json['symbol'] as String?) ?? '',
        phoneticName: (json['phoneticName'] as String?) ?? '',
        officeLocation: (json['officeLocation'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'company': company,
        'title': title,
        'department': department,
        'jobDescription': jobDescription,
        'symbol': symbol,
        'phoneticName': phoneticName,
        'officeLocation': officeLocation,
      };

  @override
  int get hashCode =>
      company.hashCode ^
      title.hashCode ^
      department.hashCode ^
      jobDescription.hashCode ^
      symbol.hashCode ^
      phoneticName.hashCode ^
      officeLocation.hashCode;

  @override
  bool operator ==(Object o) =>
      o is Organization &&
      o.company == company &&
      o.title == title &&
      o.department == department &&
      o.jobDescription == jobDescription &&
      o.symbol == symbol &&
      o.phoneticName == phoneticName &&
      o.officeLocation == officeLocation;

  @override
  String toString() =>
      'Organization(company=$company, title=$title, department=$department, '
      'jobDescription=$jobDescription, symbol=$symbol, '
      'phoneticName=$phoneticName, officeLocation=$officeLocation)';

  List<String> toVCard() {
    // ORG (V3): https://tools.ietf.org/html/rfc2426#section-3.5.5
    // TITLE (V3): https://tools.ietf.org/html/rfc2426#section-3.5.1
    // ROLE (V3): https://tools.ietf.org/html/rfc2426#section-3.5.2
    // ORG (V4): https://tools.ietf.org/html/rfc6350#section-6.6.4
    // TITLE (V4): https://tools.ietf.org/html/rfc6350#section-6.6.1
    // ROLE (V4): https://tools.ietf.org/html/rfc6350#section-6.6.2
    var lines = <String>[];
    if (company.isNotEmpty || department.isNotEmpty) {
      var s = 'ORG:${vCardEncode(company)}';
      if (department.isNotEmpty) {
        s += ';${vCardEncode(department)}';
      }
      lines.add(s);
    }
    if (title.isNotEmpty) {
      lines.add('TITLE:${vCardEncode(title)}');
    }
    if (jobDescription.isNotEmpty) {
      lines.add('ROLE:${vCardEncode(jobDescription)}');
    }
    return lines;
  }
}
