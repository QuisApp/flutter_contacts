import '../../../../models/contact/contact.dart';
import '../../../../models/properties/organization.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';
import '../../utils/encoding/encoding.dart';

/// Writes organization-related properties (ORG, TITLE, ROLE).
///
/// RFC sections:
/// - vCard 2.1: ORG, TITLE
/// - vCard 3.0: RFC 2426 Section 3.5 (ORG, TITLE, ROLE)
/// - vCard 4.0: RFC 6350 Section 6.6 (ORG, TITLE, ROLE)
void writeOrganizations(
  StringBuffer buffer,
  Contact contact,
  VCardVersion version,
) {
  for (final org in contact.organizations) {
    final orgValue = _buildOrgValue(org, version);
    writeProperty(buffer, 'ORG', orgValue, version: version);

    writeProperty(buffer, 'TITLE', org.jobTitle, version: version);
    writeProperty(
      buffer,
      version.isV4 ? 'ROLE' : 'X-JOB-DESCRIPTION',
      org.jobDescription,
      version: version,
    );
    writeProperty(buffer, 'X-ORG-SYMBOL', org.symbol, version: version);
    writeProperty(buffer, 'X-ORG-OFFICE', org.officeLocation, version: version);
    writeProperty(
      buffer,
      'X-PHONETIC-ORG-NAME',
      org.phoneticName,
      version: version,
    );
  }
}

/// Builds the ORG property value from organization components.
String? _buildOrgValue(Organization org, VCardVersion version) {
  final orgName = org.name ?? '';
  final dept = org.departmentName ?? '';
  if (orgName.isEmpty && dept.isEmpty) return null;

  final components = [orgName, dept];
  return version.isV3OrV4
      ? components.map((s) => escapeValue(s)).join(';')
      : components.join(';');
}
