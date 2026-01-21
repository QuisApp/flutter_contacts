import '../../../../models/contact/contact.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';

/// Writes URL (website) properties.
///
/// RFC sections:
/// - vCard 2.1: URL property
/// - vCard 3.0: RFC 2426 Section 3.6.8
/// - vCard 4.0: RFC 6350 Section 6.7.8
///
/// Note: The URL property does not support TYPE parameters or labels.
void writeWebsites(StringBuffer buffer, Contact contact, VCardVersion version) {
  for (final site in contact.websites) {
    writeProperty(buffer, 'URL', site.url, version: version);
  }
}
