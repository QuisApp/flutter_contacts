import '../../../../models/contact/contact.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';
import 'phone_label.dart';

/// Writes TEL (phone) properties.
///
/// RFC sections:
/// - vCard 2.1: TEL property
/// - vCard 3.0: RFC 2426 Section 3.3.1
/// - vCard 4.0: RFC 6350 Section 6.4.1
///
/// Handles custom/non-standard labels using grouping (vCard 3.0+) or fallback (vCard 2.1).
void writePhones(
  StringBuffer buffer,
  Contact contact,
  VCardVersion version, {
  required int Function() incrementGroup,
}) {
  for (final phone in contact.phones) {
    final phoneValue = version.isV4 ? 'tel:${phone.number}' : phone.number;
    writeLabeledProperty(
      buffer,
      'TEL',
      phoneValue,
      label: phone.label,
      shouldGroup: shouldGroupPhone(phone.label.label, version),
      types: getPhoneTypes(phone.label.label, version),
      version: version,
      incrementGroup: incrementGroup,
      additionalParams: version.isV4 ? ['value=uri'] : [],
      isPrimary: phone.isPrimary == true,
    );
  }
}
