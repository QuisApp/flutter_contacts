import '../../../models/contact/contact.dart';
import '../core/version.dart';
import 'formatter.dart';
import '../properties/name/name_writer.dart';
import '../properties/organization/organization_writer.dart';
import '../properties/phone/phone_writer.dart';
import '../properties/email/email_writer.dart';
import '../properties/address/address_writer.dart';
import '../properties/website/website_writer.dart';
import '../properties/event/event_writer.dart';
import '../properties/note/note_writer.dart';
import '../properties/photo/photo_writer.dart';
import '../properties/social_media/social_media_writer.dart';
import '../properties/relation/relation_writer.dart';
import '../properties/android/android_writer.dart';

/// Unified vCard writer supporting versions 2.1, 3.0, and 4.0.
///
/// Generates RFC-compliant vCard format strings from Contact objects.
///
/// Specifications:
/// - vCard 2.1: https://web.archive.org/web/20000815081252/http://www.imc.org/pdi/vcard-21.txt
/// - vCard 3.0: RFC 2425 (https://www.ietf.org/rfc/rfc2425.txt) and RFC 2426 (https://www.ietf.org/rfc/rfc2426.txt)
/// - vCard 4.0: RFC 6350 (https://www.rfc-editor.org/rfc/rfc6350.html)
class VCardWriter {
  VCardWriter._();

  /// Converts a Contact to a vCard string for the specified version.
  static String write(Contact contact, VCardVersion version) {
    final buffer = StringBuffer();
    final versionString = switch (version) {
      VCardVersion.v21 => '2.1',
      VCardVersion.v3 => '3.0',
      VCardVersion.v4 => '4.0',
    };

    buffer.write('BEGIN:VCARD\r\n');
    buffer.write('VERSION:$versionString\r\n');

    // KIND - Mandatory in vCard 4.0 (RFC 6350 Section 6.1.4)
    if (version.isV4) {
      writeProperty(buffer, 'KIND', 'individual', version: version);
    }

    // PRODID - Product Identifier (RFC 2426 Section 3.6.3, RFC 6350 Section 6.7.7)
    if (version.isV3OrV4) {
      writeProperty(
        buffer,
        'PRODID',
        '-//Flutter Contacts//NONSGML v1.0//EN',
        version: version,
      );
    }

    writeProperty(buffer, 'UID', contact.id, version: version);

    // Group counter for custom labels (v3.0/v4.0 use item1, item2, etc.)
    int groupCount = 0;
    writeNameProperties(buffer, contact, version);
    writeOrganizations(buffer, contact, version);
    writePhones(buffer, contact, version, incrementGroup: () => ++groupCount);
    writeEmails(buffer, contact, version, incrementGroup: () => ++groupCount);
    writeAddresses(
      buffer,
      contact,
      version,
      incrementGroup: () => ++groupCount,
    );
    writeWebsites(buffer, contact, version);
    writeEvents(buffer, contact, version);
    writeNotes(buffer, contact, version);
    writePhoto(buffer, contact, version);
    writeSocialMedia(
      buffer,
      contact,
      version,
      incrementGroup: () => ++groupCount,
    );
    writeRelations(
      buffer,
      contact,
      version,
      incrementGroup: () => ++groupCount,
    );

    writeAndroidProperties(buffer, contact, version);

    writeProperty(
      buffer,
      'REV',
      DateTime.now().toUtc().toIso8601String(),
      version: version,
    );

    buffer.write('END:VCARD\r\n');

    return buffer.toString();
  }
}
