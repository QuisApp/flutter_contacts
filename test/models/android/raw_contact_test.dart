import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/models/accounts/account.dart';
import 'package:flutter_contacts/models/android/raw_contact.dart';

void main() {
  group('RawContact JSON round-trip', () {
    test('decodes dataMimetypes from JSON', () {
      final raw = RawContact.fromJson({
        'rawContactId': '42',
        'sourceId': 'src-1',
        'account': {'id': '', 'name': 'user@gmail.com', 'type': 'com.google'},
        'dataMimetypes': [
          'vnd.android.cursor.item/phone_v2',
          'vnd.android.cursor.item/email_v2',
        ],
      });

      expect(raw, isNotNull);
      expect(raw!.rawContactId, '42');
      expect(raw.sourceId, 'src-1');
      expect(raw.account?.type, 'com.google');
      expect(raw.dataMimetypes, [
        'vnd.android.cursor.item/phone_v2',
        'vnd.android.cursor.item/email_v2',
      ]);
    });

    test('defaults dataMimetypes to empty when absent in JSON', () {
      final raw = RawContact.fromJson({'rawContactId': '7'});

      expect(raw, isNotNull);
      expect(raw!.rawContactId, '7');
      expect(raw.dataMimetypes, isEmpty);
    });

    test('toJson omits dataMimetypes when empty', () {
      const raw = RawContact(rawContactId: '7');
      expect(raw.toJson().containsKey('dataMimetypes'), isFalse);
    });

    test('toJson includes dataMimetypes when non-empty', () {
      const raw = RawContact(
        rawContactId: '7',
        dataMimetypes: ['vnd.com.whatsapp.profile'],
      );
      expect(raw.toJson()['dataMimetypes'], ['vnd.com.whatsapp.profile']);
    });

    test('fromJson returns null when no fields are populated', () {
      expect(RawContact.fromJson(<String, dynamic>{}), isNull);
      expect(RawContact.fromJson(null), isNull);
    });

    test('fromJson returns instance when only dataMimetypes are present', () {
      final raw = RawContact.fromJson({
        'dataMimetypes': ['vnd.android.cursor.item/phone_v2'],
      });
      expect(raw, isNotNull);
      expect(raw!.dataMimetypes, ['vnd.android.cursor.item/phone_v2']);
    });

    test('equality and hashCode consider dataMimetypes', () {
      const a = RawContact(rawContactId: '1', dataMimetypes: ['m1', 'm2']);
      const b = RawContact(rawContactId: '1', dataMimetypes: ['m1', 'm2']);
      const c = RawContact(rawContactId: '1', dataMimetypes: ['m1']);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  test('Account fromJson works (sanity)', () {
    final account = Account.fromJson({
      'id': '',
      'name': 'user@gmail.com',
      'type': 'com.google',
    });
    expect(account.name, 'user@gmail.com');
    expect(account.type, 'com.google');
  });
}
