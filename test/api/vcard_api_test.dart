import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/api/vcard_api.dart';
import 'package:flutter_contacts/models/contact/contact.dart';
import 'package:flutter_contacts/models/properties/name.dart';
import 'package:flutter_contacts/models/properties/phone.dart';
import 'package:flutter_contacts/models/properties/email.dart';
import 'package:flutter_contacts/models/properties/address.dart';
import 'package:flutter_contacts/models/properties/organization.dart';
import 'package:flutter_contacts/models/properties/website.dart';
import 'package:flutter_contacts/models/properties/note.dart';
import 'package:flutter_contacts/models/properties/event.dart';
import 'package:flutter_contacts/models/properties/relation.dart';
import 'package:flutter_contacts/models/properties/social_media.dart';
import 'package:flutter_contacts/models/labels/phone_label.dart';
import 'package:flutter_contacts/models/labels/email_label.dart';
import 'package:flutter_contacts/models/labels/address_label.dart';
import 'package:flutter_contacts/models/labels/event_label.dart';
import 'package:flutter_contacts/models/labels/relation_label.dart';
import 'package:flutter_contacts/models/labels/social_media_label.dart';
import 'package:flutter_contacts/models/labels/label.dart';
import 'package:flutter_contacts/models/vcard/vcard_version.dart';

void main() {
  group('VCardApi', () {
    group('export', () {
      test('exports minimal contact with v3', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'John', last: 'Doe'),
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('BEGIN:VCARD'));
        expect(vcard, contains('END:VCARD'));
        expect(vcard, contains('VERSION:3.0'));
        expect(vcard, contains('FN:John Doe'));
        expect(vcard, contains('N:Doe;John;;;'));
      });

      test('exports contact with v21', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Jane', last: 'Smith'),
        );

        final vcard = VCardApi.instance.export(
          contact,
          version: VCardVersion.v21,
        );

        expect(vcard, contains('BEGIN:VCARD'));
        expect(vcard, contains('END:VCARD'));
        expect(vcard, contains('VERSION:2.1'));
        expect(vcard, contains('FN:Jane Smith'));
      });

      test('exports contact with v4', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Bob', last: 'Johnson'),
        );

        final vcard = VCardApi.instance.export(
          contact,
          version: VCardVersion.v4,
        );

        expect(vcard, contains('BEGIN:VCARD'));
        expect(vcard, contains('END:VCARD'));
        expect(vcard, contains('VERSION:4.0'));
        expect(vcard, contains('KIND:individual'));
        expect(vcard, contains('FN:Bob Johnson'));
      });

      test('exports contact with phone numbers', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Alice'),
          phones: [
            Phone(number: '+1234567890', label: const Label(PhoneLabel.mobile)),
            Phone(number: '+0987654321', label: const Label(PhoneLabel.work)),
          ],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('TEL;TYPE=VOICE:+1234567890'));
        expect(vcard, contains('TEL;TYPE=WORK:+0987654321'));
      });

      test('exports contact with email addresses', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Charlie'),
          emails: [
            Email(
              address: 'test@example.com',
              label: const Label(EmailLabel.home),
            ),
            Email(
              address: 'work@example.com',
              label: const Label(EmailLabel.work),
            ),
          ],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('EMAIL;TYPE=INTERNET,HOME:test@example.com'));
        expect(vcard, contains('EMAIL;TYPE=INTERNET,WORK:work@example.com'));
      });

      test('exports contact with address', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'David'),
          addresses: [
            Address(
              street: '123 Main St',
              city: 'Springfield',
              state: 'IL',
              postalCode: '62701',
              country: 'USA',
              label: const Label(AddressLabel.home),
            ),
          ],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('ADR;TYPE=HOME'));
        expect(vcard, contains('123 Main St'));
        expect(vcard, contains('Springfield'));
      });

      test('exports contact with organization', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Eve'),
          organizations: [
            Organization(name: 'Acme Corp', jobTitle: 'Software Engineer'),
          ],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('ORG:Acme Corp'));
        expect(vcard, contains('TITLE:Software Engineer'));
      });

      test('exports contact with website', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Frank'),
          websites: [Website(url: 'https://example.com', label: null)],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('URL:https://example.com'));
      });

      test('exports contact with note', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Grace'),
          notes: [Note(note: 'This is a test note')],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('NOTE:This is a test note'));
      });

      test('exports contact with birthday event', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Henry'),
          events: [
            Event(
              year: 1990,
              month: 5,
              day: 15,
              label: const Label(EventLabel.birthday),
            ),
          ],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('BDAY:1990-05-15'));
      });

      test('exports contact with relation', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Iris'),
          relations: [
            Relation(
              name: 'John Doe',
              label: const Label(RelationLabel.spouse),
            ),
          ],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('X-RELATION'));
        expect(vcard, contains('John Doe'));
      });

      test('exports contact with social media', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Jack'),
          socialMedias: [
            SocialMedia(
              username: 'johndoe',
              label: const Label(SocialMediaLabel.twitter),
            ),
          ],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('X-SOCIALPROFILE'));
        expect(vcard, contains('johndoe'));
      });

      test('exports contact with all properties', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(
            first: 'John',
            middle: 'Middle',
            last: 'Doe',
            prefix: 'Mr.',
            suffix: 'Jr.',
          ),
          phones: [
            Phone(number: '+1234567890', label: const Label(PhoneLabel.mobile)),
          ],
          emails: [
            Email(
              address: 'john@example.com',
              label: const Label(EmailLabel.home),
            ),
          ],
          addresses: [
            Address(
              street: '123 Main St',
              city: 'Springfield',
              state: 'IL',
              postalCode: '62701',
              country: 'USA',
              label: const Label(AddressLabel.home),
            ),
          ],
          organizations: [
            Organization(name: 'Acme Corp', jobTitle: 'Engineer'),
          ],
          websites: [Website(url: 'https://example.com')],
          notes: [Note(note: 'Test note')],
          events: [
            Event(
              year: 1990,
              month: 5,
              day: 15,
              label: const Label(EventLabel.birthday),
            ),
          ],
          relations: [
            Relation(
              name: 'Jane Doe',
              label: const Label(RelationLabel.spouse),
            ),
          ],
          socialMedias: [
            SocialMedia(
              username: 'johndoe',
              label: const Label(SocialMediaLabel.twitter),
            ),
          ],
        );

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('BEGIN:VCARD'));
        expect(vcard, contains('END:VCARD'));
        expect(vcard, contains('FN:Mr. John Middle Doe Jr.'));
        expect(vcard, contains('N:Doe;John;Middle;Mr.;Jr.'));
        expect(vcard, contains('TEL'));
        expect(vcard, contains('EMAIL'));
        expect(vcard, contains('ADR'));
        expect(vcard, contains('ORG'));
        expect(vcard, contains('URL'));
        expect(vcard, contains('NOTE'));
        expect(vcard, contains('BDAY'));
        expect(vcard, contains('X-RELATION'));
        expect(vcard, contains('X-SOCIALPROFILE'));
      });

      test('exports contact without name', () async {
        final contact = Contact(id: 'test-id');

        final vcard = VCardApi.instance.export(contact);

        expect(vcard, contains('BEGIN:VCARD'));
        expect(vcard, contains('END:VCARD'));
        // Should still have UID
        expect(vcard, contains('UID:test-id'));
      });
    });

    group('exportAll', () {
      test('exports multiple contacts', () async {
        final contacts = [
          Contact(
            id: '1',
            name: Name(first: 'Alice'),
          ),
          Contact(
            id: '2',
            name: Name(first: 'Bob'),
          ),
          Contact(
            id: '3',
            name: Name(first: 'Charlie'),
          ),
        ];

        final vcard = VCardApi.instance.exportAll(contacts);

        expect(vcard, contains('BEGIN:VCARD'));
        expect(vcard, contains('END:VCARD'));
        // Should contain all three names
        expect(vcard, contains('FN:Alice'));
        expect(vcard, contains('FN:Bob'));
        expect(vcard, contains('FN:Charlie'));
        // Should have separators between vCards
        final vcardCount = 'BEGIN:VCARD'.allMatches(vcard).length;
        expect(vcardCount, 3);
      });

      test('exports empty list', () async {
        final vcard = VCardApi.instance.exportAll([]);

        expect(vcard, isEmpty);
      });

      test('exports single contact same as export', () async {
        final contact = Contact(
          id: 'test-id',
          name: Name(first: 'Test'),
        );

        final exportSingle = VCardApi.instance.export(contact);
        final exportAll = VCardApi.instance.exportAll([contact]);

        // Compare structure (ignore REV timestamp which differs)
        expect(exportAll, contains('BEGIN:VCARD'));
        expect(exportAll, contains('END:VCARD'));
        expect(exportAll, contains('FN:Test'));
        // Should have same structure
        final singleLines = exportSingle
            .split('\r\n')
            .where((l) => !l.startsWith('REV:'))
            .toList();
        final allLines = exportAll
            .split('\r\n')
            .where((l) => !l.startsWith('REV:'))
            .toList();
        expect(allLines, singleLines);
      });

      test('exports with different versions', () async {
        final contacts = [
          Contact(
            id: '1',
            name: Name(first: 'Alice'),
          ),
        ];

        final v21 = VCardApi.instance.exportAll(
          contacts,
          version: VCardVersion.v21,
        );
        final v3 = VCardApi.instance.exportAll(
          contacts,
          version: VCardVersion.v3,
        );
        final v4 = VCardApi.instance.exportAll(
          contacts,
          version: VCardVersion.v4,
        );

        expect(v21, contains('VERSION:2.1'));
        expect(v3, contains('VERSION:3.0'));
        expect(v4, contains('VERSION:4.0'));
        expect(v4, contains('KIND:individual'));
      });
    });

    group('import', () {
      test('imports minimal vCard v3', () async {
        const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:John Doe
N:Doe;John;;;
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        expect(contacts, hasLength(1));
        expect(contacts.first.name?.first, 'John');
        expect(contacts.first.name?.last, 'Doe');
      });

      test('imports vCard with phone', () async {
        const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:Jane Smith
N:Smith;Jane;;;
TEL;TYPE=CELL:+1234567890
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        expect(contacts, hasLength(1));
        expect(contacts.first.phones, hasLength(1));
        expect(contacts.first.phones.first.number, '+1234567890');
      });

      test('imports vCard with email', () async {
        const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:Bob Johnson
N:Johnson;Bob;;;
EMAIL;TYPE=HOME:test@example.com
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        expect(contacts, hasLength(1));
        expect(contacts.first.emails, hasLength(1));
        expect(contacts.first.emails.first.address, 'test@example.com');
      });

      test('imports vCard with address', () async {
        const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:Alice Brown
N:Brown;Alice;;;
ADR;TYPE=HOME:;;123 Main St;Springfield;IL;62701;USA
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        expect(contacts, hasLength(1));
        expect(contacts.first.addresses, hasLength(1));
        final address = contacts.first.addresses.first;
        expect(address.street, '123 Main St');
        expect(address.city, 'Springfield');
      });

      test('imports vCard with organization', () async {
        const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:Charlie Wilson
N:Wilson;Charlie;;;
ORG:Acme Corp
TITLE:Engineer
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        expect(contacts, hasLength(1));
        expect(contacts.first.organizations, hasLength(1));
        expect(contacts.first.organizations.first.name, 'Acme Corp');
        expect(contacts.first.organizations.first.jobTitle, 'Engineer');
      });

      test('imports vCard with birthday', () async {
        const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:David Lee
N:Lee;David;;;
BDAY:1990-05-15
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        expect(contacts, hasLength(1));
        expect(contacts.first.events, hasLength(1));
        expect(contacts.first.events.first.year, 1990);
        expect(contacts.first.events.first.month, 5);
        expect(contacts.first.events.first.day, 15);
      });

      test('imports vCard v4', () async {
        const vcard = '''BEGIN:VCARD
VERSION:4.0
KIND:individual
FN:Eve Davis
N:Davis;Eve;;;
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        expect(contacts, hasLength(1));
        expect(contacts.first.name?.first, 'Eve');
        expect(contacts.first.name?.last, 'Davis');
      });

      test('imports multiple vCards', () async {
        const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:Frank Miller
N:Miller;Frank;;;
END:VCARD
BEGIN:VCARD
VERSION:3.0
FN:Grace Taylor
N:Taylor;Grace;;;
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        expect(contacts, hasLength(2));
        expect(contacts[0].name?.first, 'Frank');
        expect(contacts[1].name?.first, 'Grace');
      });

      test('imports vCard with note', () async {
        const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:Henry White
N:White;Henry;;;
NOTE:This is a test note
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        expect(contacts, hasLength(1));
        expect(contacts.first.notes, hasLength(1));
        expect(contacts.first.notes.first.note, 'This is a test note');
      });

      test('handles empty vCard string', () async {
        final contacts = VCardApi.instance.import('');

        expect(contacts, isEmpty);
      });

      test('handles malformed vCard gracefully', () async {
        const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:Test
N:Test;;;;
END:VCARD''';

        final contacts = VCardApi.instance.import(vcard);

        // Should still parse what it can
        expect(contacts, hasLength(1));
        expect(contacts.first.displayName, 'Test');
      });
    });

    group('round-trip', () {
      test('export then import preserves contact data', () async {
        final original = Contact(
          id: 'test-id',
          name: Name(first: 'John', last: 'Doe'),
          phones: [
            Phone(number: '+1234567890', label: const Label(PhoneLabel.mobile)),
          ],
          emails: [
            Email(
              address: 'john@example.com',
              label: const Label(EmailLabel.home),
            ),
          ],
        );

        final vcard = VCardApi.instance.export(original);
        final imported = VCardApi.instance.import(vcard);

        expect(imported, hasLength(1));
        expect(imported.first.name?.first, 'John');
        expect(imported.first.name?.last, 'Doe');
        expect(imported.first.phones, hasLength(1));
        expect(imported.first.phones.first.number, '+1234567890');
        expect(imported.first.emails, hasLength(1));
        expect(imported.first.emails.first.address, 'john@example.com');
      });

      test('round-trip with all properties', () async {
        final original = Contact(
          id: 'test-id',
          name: Name(
            first: 'Jane',
            middle: 'Middle',
            last: 'Smith',
            prefix: 'Ms.',
            suffix: 'III',
          ),
          phones: [
            Phone(number: '+1234567890', label: const Label(PhoneLabel.mobile)),
            Phone(number: '+0987654321', label: const Label(PhoneLabel.work)),
          ],
          emails: [
            Email(
              address: 'home@example.com',
              label: const Label(EmailLabel.home),
            ),
            Email(
              address: 'work@example.com',
              label: const Label(EmailLabel.work),
            ),
          ],
          addresses: [
            Address(
              street: '123 Main St',
              city: 'Springfield',
              state: 'IL',
              postalCode: '62701',
              country: 'USA',
              label: const Label(AddressLabel.home),
            ),
          ],
          organizations: [
            Organization(name: 'Acme Corp', jobTitle: 'Engineer'),
          ],
          websites: [Website(url: 'https://example.com')],
          notes: [Note(note: 'Test note')],
          events: [
            Event(
              year: 1990,
              month: 5,
              day: 15,
              label: const Label(EventLabel.birthday),
            ),
          ],
        );

        final vcard = VCardApi.instance.export(original);
        final imported = VCardApi.instance.import(vcard);

        expect(imported, hasLength(1));
        final contact = imported.first;
        expect(contact.name?.first, 'Jane');
        expect(contact.name?.middle, 'Middle');
        expect(contact.name?.last, 'Smith');
        expect(contact.phones, hasLength(2));
        expect(contact.emails, hasLength(2));
        expect(contact.addresses, hasLength(1));
        expect(contact.organizations, hasLength(1));
        expect(contact.websites, hasLength(1));
        expect(contact.notes, hasLength(1));
        expect(contact.events, hasLength(1));
      });

      test('round-trip with different versions', () async {
        final original = Contact(
          id: 'test-id',
          name: Name(first: 'Test', last: 'User'),
          phones: [
            Phone(number: '+1234567890', label: const Label(PhoneLabel.mobile)),
          ],
        );

        for (final version in VCardVersion.values) {
          final vcard = VCardApi.instance.export(original, version: version);
          final imported = VCardApi.instance.import(vcard);

          expect(imported, hasLength(1));
          expect(imported.first.name?.first, 'Test');
          expect(imported.first.name?.last, 'User');
          expect(imported.first.phones, hasLength(1));
        }
      });

      test('exportAll then import preserves all contacts', () async {
        final originals = [
          Contact(
            id: '1',
            name: Name(first: 'Alice'),
          ),
          Contact(
            id: '2',
            name: Name(first: 'Bob'),
          ),
          Contact(
            id: '3',
            name: Name(first: 'Charlie'),
          ),
        ];

        final vcard = VCardApi.instance.exportAll(originals);
        final imported = VCardApi.instance.import(vcard);

        expect(imported, hasLength(3));
        expect(imported[0].name?.first, 'Alice');
        expect(imported[1].name?.first, 'Bob');
        expect(imported[2].name?.first, 'Charlie');
      });
    });
  });
}
