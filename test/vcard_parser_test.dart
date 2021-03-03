import 'dart:convert';
import 'dart:io';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('android default contact app', () {
    final vcfFile =
        File('test/testdata/vcards/android-default-contact-app.vcf');
    final jsonFile =
        File('test/testdata/vcards/android-default-contact-app.json');
    final actual = Contact.fromVCard(vcfFile.readAsStringSync()).toJson();
    final expected = json.decode(jsonFile.readAsStringSync());
    expect(actual, expected);
  });

  test('ios', () {
    final vcfFile = File('test/testdata/vcards/ios.vcf');
    final jsonFile = File('test/testdata/vcards/ios.json');
    final actual = Contact.fromVCard(vcfFile.readAsStringSync()).toJson();
    final expected = json.decode(jsonFile.readAsStringSync());
    expect(actual, expected);
  });

  test('mac os', () {
    final vcfFile = File('test/testdata/vcards/macos.vcf');
    final jsonFile = File('test/testdata/vcards/macos.json');
    final actual = Contact.fromVCard(vcfFile.readAsStringSync()).toJson();
    final expected = json.decode(jsonFile.readAsStringSync());
    expect(actual, expected);
  });

  test('whatsapp', () {
    final vcfFile = File('test/testdata/vcards/whatsapp.vcf');
    final jsonFile = File('test/testdata/vcards/whatsapp.json');
    final actual = Contact.fromVCard(vcfFile.readAsStringSync()).toJson();
    final expected = json.decode(jsonFile.readAsStringSync());
    expect(actual, expected);
  });

  test('https://vcardmaker.com/', () {
    final vcfFile = File('test/testdata/vcards/vcardmaker.com.vcf');
    final jsonFile = File('test/testdata/vcards/vcardmaker.com.json');
    final actual = Contact.fromVCard(vcfFile.readAsStringSync()).toJson();
    final expected = json.decode(jsonFile.readAsStringSync());
    expect(actual, expected);
  });

  test('https://bvcard.com/', () {
    final vcfFile = File('test/testdata/vcards/bvcard.com.vcf');
    final jsonFile = File('test/testdata/vcards/bvcard.com.json');
    final actual = Contact.fromVCard(vcfFile.readAsStringSync()).toJson();
    final expected = json.decode(jsonFile.readAsStringSync());
    expect(actual, expected);
  });

  test('https://app.qr-code-generator.com/', () {
    final vcfFile = File('test/testdata/vcards/qr-code-generator.com.vcf');
    final jsonFile = File('test/testdata/vcards/qr-code-generator.com.json');
    final actual = Contact.fromVCard(vcfFile.readAsStringSync()).toJson();
    final expected = json.decode(jsonFile.readAsStringSync());
    expect(actual, expected);
  });

  test('empty vcard', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'END:VCARD',
    ].join('\n'));
    expect(contact.id, '');
    expect(contact.displayName, '');
    expect(contact.photo, null);
    expect(contact.thumbnail, null);
    expect(contact.name.first, '');
    expect(contact.phones, []);
    expect(contact.emails, []);
    expect(contact.accounts, []);
  });

  test('name', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'N:Last;First;Middle;Prefix;Suffix',
      'NICKNAME:Nick,John',
      'X-PHONETIC-FIRST-NAME:[First]',
      'X-PHONETIC-LAST-NAME:[Last]',
      'END:VCARD',
    ].join('\n'));
    expect(contact.name.first, 'First');
    expect(contact.name.last, 'Last');
    expect(contact.name.middle, 'Middle');
    expect(contact.name.prefix, 'Prefix');
    expect(contact.name.suffix, 'Suffix');
    expect(contact.name.nickname, 'Nick');
    expect(contact.name.firstPhonetic, '[First]');
    expect(contact.name.lastPhonetic, '[Last]');
  });

  test('display name', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'FN:Display Name',
      'END:VCARD',
    ].join('\n'));
    expect(contact.displayName, 'Display Name');
  });

  test('escaping', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'FN:Display\\nName\\,With\\;Escaping',
      'END:VCARD',
    ].join('\n'));
    expect(contact.displayName, 'Display\nName,With;Escaping');
  });

  test('folding', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'FN:Display ',
      ' Name',
      'END:VCARD',
    ].join('\n'));
    expect(contact.displayName, 'Display Name');
  });

  test('quoted printable encoding', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'FN;ENCODING=QUOTED-PRINTABLE:=30=31=32=',
      '=33=34=35=',
      '=36=37=38',
      'END:VCARD',
    ].join('\n'));
    expect(contact.displayName, '012345678');
  });

  test('photo', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'PHOTO;anything;can;go;here:Zm9vYmFy',
      'END:VCARD',
    ].join('\n'));
    expect(contact.photo, base64Decode('Zm9vYmFy'));
    expect(contact.thumbnail, null);
  });

  test('phones', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'PHONE:555-111-1111',
      'TEL:555-222-2222',
      'TEL:555-333-3333;ext=333',
      'TEL;TYPE=voice;TYPE=pager:555-444-4444',
      'TEL;TYPE=voice,work,pref:555-555-5555',
      'TEL;TYPE="fax,other":555-666-6666',
      'TEL;TYPE=main;PREF=1:555-777-7777',
      'PHONE;PREF:555-888-8888',
      'TEL;type=IPHONE:555-999-9999',
      'END:VCARD',
    ].join('\n'));
    expect(contact.phones, [
      Phone('555-111-1111'),
      Phone('555-222-2222'),
      Phone('555-333-3333;333'),
      Phone('555-444-4444', label: PhoneLabel.pager),
      Phone('555-555-5555', label: PhoneLabel.work, isPrimary: true),
      Phone('555-666-6666', label: PhoneLabel.faxOther),
      Phone('555-777-7777', label: PhoneLabel.main, isPrimary: true),
      Phone('555-888-8888', isPrimary: true),
      Phone('555-999-9999', label: PhoneLabel.iPhone),
    ]);
  });

  test('emails', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'EMAIL:a@a.com',
      'EMAIL;TYPE=MOBILE:b@b.com',
      'EMAIL;type=work,pref:c@c.com',
      'EMAIL;type=Not A Type;Pref=1:d@d.com',
      'END:VCARD',
    ].join('\n'));
    expect(contact.emails, [
      Email('a@a.com'),
      Email('b@b.com', label: EmailLabel.mobile),
      Email('c@c.com', label: EmailLabel.work, isPrimary: true),
      Email('d@d.com', isPrimary: true),
    ]);
  });

  test('addresses', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'ADR:;;123 main st;;;;',
      'ADR;type=work:pobox;extended;street;city;state;postalCode;country',
      'END:VCARD',
    ].join('\n'));
    expect(contact.addresses, [
      Address('123 main st'),
      Address('pobox extended street city state postalCode country',
          label: AddressLabel.work,
          pobox: 'pobox',
          street: 'street',
          city: 'city',
          state: 'state',
          postalCode: 'postalCode',
          country: 'country'),
    ]);
  });

  test('organization', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'ORG:company;division;subdivision',
      'TITLE:software engineer',
      'ROLE:writing code',
      'X-PHONETIC-ORG:[kompani]',
      'END:VCARD',
    ].join('\n'));
    expect(contact.organizations, [
      Organization(
        company: 'company',
        department: 'division',
        title: 'software engineer',
        jobDescription: 'writing code',
        phoneticName: '[kompani]',
      ),
    ]);
  });

  test('websites', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'URL:www.a.com',
      'URL;type=home:www.b.com',
      'URL;type=homepage:www.c.com',
      'URL;type=work:www.d.com',
      'URL;type=other:www.e.com',
      'END:VCARD',
    ].join('\n'));
    expect(contact.websites, [
      Website('www.a.com'),
      Website('www.b.com', label: WebsiteLabel.home),
      Website('www.c.com', label: WebsiteLabel.homepage),
      Website('www.d.com', label: WebsiteLabel.work),
      Website('www.e.com', label: WebsiteLabel.other),
    ]);
  });

  test('social medias', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'IMPP:aim:@aim',
      'IMPP:twitter:@twitter',
      'IMPP;X-SERVICE-TYPE=yahoo:protocol:@yahoo',
      'X-SOCIALPROFILE;type=linkedin:@linkedin',
      'X-SKYPE-USERNAME:@skype',
      'END:VCARD',
    ].join('\n'));
    expect(contact.socialMedias, [
      SocialMedia('@aim', label: SocialMediaLabel.aim),
      SocialMedia('@twitter', label: SocialMediaLabel.twitter),
      SocialMedia('@yahoo', label: SocialMediaLabel.yahoo),
      SocialMedia('@linkedin', label: SocialMediaLabel.linkedIn),
      SocialMedia('@skype', label: SocialMediaLabel.skype),
    ]);
  });

  test('events', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'BDAY:--0121',
      'BDAY:--02-22',
      'BDAY:19930323',
      'BDAY:1994-04-24',
      'BDAY:1995-05-25T01:02:03Z',
      'BDAY;X-APPLE-OMIT-YEAR=1604:1604-06-26',
      'ANNIVERSARY:1997-07-27',
      'END:VCARD',
    ].join('\n'));
    expect(contact.events, [
      Event(year: null, month: 1, day: 21, label: EventLabel.birthday),
      Event(year: null, month: 2, day: 22, label: EventLabel.birthday),
      Event(year: 1993, month: 3, day: 23, label: EventLabel.birthday),
      Event(year: 1994, month: 4, day: 24, label: EventLabel.birthday),
      Event(year: 1995, month: 5, day: 25, label: EventLabel.birthday),
      Event(year: null, month: 6, day: 26, label: EventLabel.birthday),
      Event(year: 1997, month: 7, day: 27, label: EventLabel.anniversary),
    ]);
  });

  test('notes', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'NOTE:line1\\nline2',
      'END:VCARD',
    ].join('\n'));
    expect(contact.notes, [
      Note('line1\nline2'),
    ]);
  });

  test('android custom', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'X-ANDROID-CUSTOM:vnd.android.cursor.item/contact_event;--01-21;1;;;',
      'X-ANDROID-CUSTOM:vnd.android.cursor.item/contact_event;--02-22;2;;;',
      'X-ANDROID-CUSTOM:vnd.android.cursor.item/contact_event;--03-23;0;Custom Event;;',
      'X-ANDROID-CUSTOM:vnd.android.cursor.item/nickname;Nick;;;;',
      'END:VCARD',
    ].join('\n'));
    expect(contact.events, [
      Event(year: null, month: 1, day: 21, label: EventLabel.anniversary),
      Event(year: null, month: 2, day: 22, label: EventLabel.other),
      Event(
          year: null,
          month: 3,
          day: 23,
          label: EventLabel.custom,
          customLabel: 'Custom Event'),
    ]);
  });

  test('grouping and custom labels', () {
    final contact = Contact.fromVCard([
      'BEGIN:VCARD',
      'item1.TEL:555-123-4567',
      'item1.X-ABLABEL:_\$!<Other>!\$_',
      'item2.EMAIL:a@a.com',
      'item2.X-ABLabel:Email Label',
      'END:VCARD',
    ].join('\n'));
    expect(contact.phones, [
      Phone('555-123-4567', label: PhoneLabel.other),
    ]);
    expect(contact.emails, [
      Email('a@a.com', label: EmailLabel.custom, customLabel: 'Email Label'),
    ]);
  });
}
