import '../../../../models/contact/contact.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';

/// Writes NOTE properties.
///
/// RFC sections:
/// - vCard 2.1: NOTE property
/// - vCard 3.0: RFC 2426 Section 3.6.2
/// - vCard 4.0: RFC 6350 Section 6.7.2
void writeNotes(StringBuffer buffer, Contact contact, VCardVersion version) {
  for (final note in contact.notes) {
    writeProperty(buffer, 'NOTE', note.note, version: version);
  }
}
