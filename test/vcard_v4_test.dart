import 'dart:convert';

import 'package:flutter_contacts/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

final _complexContact = {
  'id': 'complex_contact',
  'displayName': 'Dr Complex M Contact, Jr',
  // https://tools.ietf.org/html/rfc4648#section-10
  'photo': base64Decode('Zm9vYmFy'),
  'name': {
    'first': 'Complex',
    'last': 'Contact',
    'middle': 'M',
    'prefix': 'Dr',
    'suffix': 'Jr',
    'nickname': 'Complexo',
    'first_phonetic': 'Com-Plex',
    'last_phonetic': 'Con-Tact',
    'middle_phonetic': 'Mm',
  },
  'phones': [
    {
      'number': '(555) 123-4567',
      'normalizedNumber': '+15551234567',
      'label': 'mobile',
      'customLabel': '',
      'isPrimary': true,
    },
    {
      'number': '555-000-1111',
      'normalizedNumber': '',
      'label': 'custom',
      'customLabel': 'Custom Phone',
      'isPrimary': false,
    },
  ],
  'emails': [
    {
      'address': 'complex@contact.com',
      'label': 'iCloud',
      'customLabel': '',
      'isPrimary': false,
    },
  ],
  'addresses': [
    {
      'address': '123 Main St, Portland, OR 97086',
      'label': 'home',
      'customLabel': '',
      'street': '123 Main St',
      'pobox': '',
      'neighborhood': '',
      'city': 'Portland',
      'state': 'OR',
      'postalCode': '97086',
      'country': 'USA',
      'isoCountry': 'USA',
      'subAdminArea': '',
      'subLocality': '',
    },
  ],
  'organizations': [
    {
      'company': 'Flutter',
      'title': 'Contact',
      'department': 'Contact Department',
      'jobDescription': 'Being a contact',
      'symbol': 'CNCT',
      'phoneticName': 'Flu-tter',
      'officeLocation': '1600 Amphitheatre Parkway'
    },
  ],
  'websites': [
    {
      'url': 'http://www.example.com/contact',
      'label': 'homepage',
      'customLabel': '',
    },
  ],
  'socialMedias': [
    {
      'userName': '@contact',
      'label': 'twitter',
      'customLabel': '',
    },
  ],
  'events': [
    {
      'year': null,
      'month': 7,
      'day': 23,
      'label': 'birthday',
      'customLabel': '',
    },
    {
      'year': 2010,
      'month': 4,
      'day': 9,
      'label': 'anniversary',
      'customLabel': '',
    },
  ],
  'notes': [
    {
      'note': 'Some notes about the contact',
    },
  ],
};

void main() {
  setUp(() {
    FlutterContacts.config.vCardVersion = VCardVersion.v4;
  });

  test('Empty contact', () {
    expect(
        Contact().toVCard(),
        [
          'BEGIN:VCARD',
          'VERSION:4.0',
          'END:VCARD',
        ].join('\n'));
  });

  test('Empty contact with productId and date', () {
    final vCard = Contact()
        .toVCard(
            productId: '-//Flutter Contacts//Version 1.2.3//EN',
            includeDate: true)
        .split('\n');
    expect(vCard.length, 5);
    expect(vCard[0], 'BEGIN:VCARD');
    expect(vCard[1], 'VERSION:4.0');
    expect(vCard[2], 'PRODID:-//Flutter Contacts//Version 1.2.3//EN');
    final year = DateTime.now().year;
    expect(vCard[3].substring(0, 8), 'REV:$year');
    expect(vCard[4], 'END:VCARD');
  });

  test('Complex contact', () {
    expect(
        Contact.fromJson(_complexContact).toVCard(),
        [
          'BEGIN:VCARD',
          'VERSION:4.0',
          'FN:Dr Complex M Contact\\, Jr',
          'PHOTO:data:image/jpeg;base64,Zm9vYmFy',
          'N:Contact;Complex;M;Dr;Jr',
          'NICKNAME:Complexo',
          'TEL;VALUE=uri;TYPE="cell,text";PREF=1:tel:(555) 123-4567',
          'TEL;VALUE=uri:tel:555-000-1111',
          'EMAIL:complex@contact.com',
          'ADR;LABEL=home:;;123 Main St;Portland;OR;97086;USA',
          'ORG:Flutter;Contact Department',
          'TITLE:Contact',
          'ROLE:Being a contact',
          'URL:http://www.example.com/contact',
          'IMPP:twitter:@contact',
          'BDAY:--0723',
          'ANNIVERSARY:20100409',
          'NOTE:Some notes about the contact',
          'END:VCARD',
        ].join('\n'));
  });
}
