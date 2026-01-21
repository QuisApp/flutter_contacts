import '../../../../models/contact/contact.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';

/// Writes X-SOCIALPROFILE properties.
///
/// Note: RFC 6350 has IMPP property for instant messaging, but X-SOCIALPROFILE
/// is more commonly used in practice.
void writeSocialMedia(
  StringBuffer buffer,
  Contact contact,
  VCardVersion version, {
  required int Function() incrementGroup,
}) {
  for (final social in contact.socialMedias) {
    // X-SOCIALPROFILE is always non-standard, so always group in v3.0/v4.0
    writeLabeledProperty(
      buffer,
      'X-SOCIALPROFILE',
      social.username,
      label: social.label,
      shouldGroup: version.isV3OrV4,
      types: [], // X-SOCIALPROFILE has no standard types
      version: version,
      incrementGroup: incrementGroup,
      additionalParams: [],
    );
  }
}
