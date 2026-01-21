import '../../../../models/contact/contact.dart';
import '../../../../models/properties/name.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';
import '../../utils/encoding/encoding.dart';

/// Writes name-related properties (N, FN, NICKNAME, phonetic names).
///
/// RFC sections:
/// - vCard 2.1: N and FN are required
/// - vCard 3.0: RFC 2426 Section 3.1 (N, FN, NICKNAME)
/// - vCard 4.0: RFC 6350 Section 6.2 (N, FN, NICKNAME)
void writeNameProperties(
  StringBuffer buffer,
  Contact contact,
  VCardVersion version,
) {
  // Name (required)
  final nameValue = _buildNameValue(contact.name, version);
  writeProperty(buffer, 'N', nameValue, version: version);

  // Formatted Name (required)
  final fnValue = _buildFormattedName(contact.displayName, contact.name);
  writeProperty(buffer, 'FN', fnValue, version: version);

  final name = contact.name;
  if (name != null) {
    writeProperty(
      buffer,
      version.isV4 ? 'NICKNAME' : 'X-NICKNAME',
      name.nickname,
      version: version,
    );
    writeProperty(
      buffer,
      'X-PHONETIC-FIRST-NAME',
      name.phoneticFirst,
      version: version,
    );
    writeProperty(
      buffer,
      'X-PHONETIC-MIDDLE-NAME',
      name.phoneticMiddle,
      version: version,
    );
    writeProperty(
      buffer,
      'X-PHONETIC-LAST-NAME',
      name.phoneticLast,
      version: version,
    );
  }
}

/// Builds the N (Name) property value from name components.
String _buildNameValue(Name? name, VCardVersion version) {
  if (name == null) return ';;;;';

  final components = [
    name.last ?? '',
    name.first ?? '',
    name.middle ?? '',
    name.prefix ?? '',
    name.suffix ?? '',
  ];
  return version.isV3OrV4
      ? components.map((s) => escapeValue(s)).join(';')
      : components.join(';');
}

/// Builds the FN (Formatted Name) property value.
///
/// Uses [displayName] if available, otherwise constructs from name components.
String _buildFormattedName(String? displayName, Name? name) {
  if (displayName?.isNotEmpty == true) return displayName!;
  if (name == null) return '';

  final parts = [
    name.prefix,
    name.first,
    name.middle,
    name.last,
    name.suffix,
  ].where((s) => s?.isNotEmpty == true).cast<String>();

  return parts.join(' ');
}
