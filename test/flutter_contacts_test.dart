import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sorting', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('github.com/QuisApp/flutter_contacts'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'select') {
          return [
            {'displayName': 'ella fitzgerald'},
            {'displayName': 'ezra koenig'},
            {'displayName': 'Elon Musk'},
            {'displayName': 'Édouart Manet'},
          ];
        }
        return null;
      },
    );
    final contacts = await FlutterContacts.getContacts();
    expect(contacts.map((x) => x.displayName).toList(), [
      'Édouart Manet',
      'ella fitzgerald',
      'Elon Musk',
      'ezra koenig',
    ]);
  });

  test('get contact', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('github.com/QuisApp/flutter_contacts'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'select') {
          return [_complexContact];
        }
        return null;
      },
    );
    final _ = await FlutterContacts.getContact('complex_contact');
  });
}

final _complexContact = {
  'id': 'complex_contact',
  'displayName': 'Dr Complex M Contact, Jr',
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
      'number': '555-123-4567',
      'normalizedNumber': '+15551234567',
      'label': 'mobile',
      'customLabel': '',
    },
    {
      'number': '555-000-1111',
      'normalizedNumber': '',
      'label': 'custom',
      'customLabel': 'Custom Phone',
    },
  ],
  'emails': [
    {
      'address': 'complex@contact.com',
      'label': 'iCloud',
      'customLabel': '',
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
