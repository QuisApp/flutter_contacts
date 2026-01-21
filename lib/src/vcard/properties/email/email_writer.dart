import '../../../../models/contact/contact.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';
import 'email_label.dart';

/// Writes EMAIL properties.
///
/// RFC sections:
/// - vCard 2.1: EMAIL property
/// - vCard 3.0: RFC 2426 Section 3.3.2
/// - vCard 4.0: RFC 6350 Section 6.4.2
///
/// Handles custom/non-standard labels using grouping (vCard 3.0+) or fallback (vCard 2.1).
void writeEmails(
  StringBuffer buffer,
  Contact contact,
  VCardVersion version, {
  required int Function() incrementGroup,
}) {
  for (final email in contact.emails) {
    writeLabeledProperty(
      buffer,
      'EMAIL',
      email.address,
      label: email.label,
      shouldGroup: shouldGroupEmail(email.label.label, version),
      types: getEmailTypes(email.label.label, version),
      version: version,
      incrementGroup: incrementGroup,
      isPrimary: email.isPrimary == true,
    );
  }
}
