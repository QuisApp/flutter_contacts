import 'dart:convert';

import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/properties/address.dart';
import 'package:flutter_contacts/properties/email.dart';
import 'package:flutter_contacts/properties/event.dart';
import 'package:flutter_contacts/properties/note.dart';
import 'package:flutter_contacts/properties/organization.dart';
import 'package:flutter_contacts/properties/phone.dart';
import 'package:flutter_contacts/properties/social_media.dart';
import 'package:flutter_contacts/properties/website.dart';

final _dateRegexp = RegExp(r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|30|31)$');
final _noYearDateRegexp =
    RegExp(r'^--(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|30|31)$');
final _dateNoDashRegexp =
    RegExp(r'^\d{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|30|31)$');
final _noYearDateNoDashRegexp =
    RegExp(r'^--(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|30|31)$');

class Param {
  final String key;
  final String? value;

  Param(this.key, this.value);

  @override
  String toString() => '$key => $value';
}

String vCardEncode(String s) =>
    s.replaceAll(',', '\\,').replaceAll(';', '\\;').replaceAll('\n', '\\n');

class VCardParser {
  String encode(String s) => s
      .replaceAll('\\,', '&fluttercontactscomma&')
      .replaceAll('\\;', '&fluttercontactssemicolon&')
      .replaceAll('\\n', '&fluttercontactsnewline&');

  String decode(String s) => s
      .replaceAll('&fluttercontactscomma&', ',')
      .replaceAll('&fluttercontactssemicolon&', ';')
      .replaceAll('&fluttercontactsnewline&', '\n');

  String unfold(String s) => s
      // https://tools.ietf.org/html/rfc2425#section-5.8.1
      .replaceAll(RegExp(r'\n[ \t]'), '')
      // Quoted-encoded contents are sometimes split on multiple lines ending and
      // starting with '='.
      .replaceAll(RegExp(r'=\n='), '=');

  void parse(String content, Contact contact) {
    var lines = encode(unfold(content)).split('\n').map((String x) => x.trim());
    for (final line in lines) {
      // In general, a vCard line is of the form
      // [<group>.]<op>[;<param>=<value>[;...]]:<content>
      final parts = line.split(':');
      if (parts.length < 2) {
        continue; // invalid line
      }
      final prefix = parts[0];
      var content = parts.sublist(1).join(':');
      if (content.isEmpty) {
        continue; // no content => nothing to do
      }
      final prefixParts = prefix.split(';');
      final groupKey = prefixParts[0].split('.');
      final op = groupKey.last.toUpperCase(); // drop the group
      final group = groupKey.length == 2 ? groupKey.first : '';
      var params = <Param>[];
      for (final p in prefixParts.sublist(1)) {
        final paramParts = p.split('=');
        if (paramParts.length < 2) {
          // Allowed wtih vCard 2.1.
          params.add(Param(paramParts[0].toUpperCase(), null));
        }
        params.add(Param(
          paramParts[0].toUpperCase(),
          paramParts.sublist(1).join('=').toUpperCase(),
        ));
      }

      // https://mathematica.stackexchange.com/questions/111637/importing-a-vcf-file-with-quoted-printable-encoding
      if (params
          .any((p) => p.key == 'ENCODING' && p.value == 'QUOTED-PRINTABLE')) {
        content = Uri.decodeFull(content.replaceAll('=', '%'));
      }

      var labelOverride = '';
      if (group.isNotEmpty) {
        final relatedLines = lines.where((x) => x.startsWith(group));
        for (final related in relatedLines) {
          if (related
              .toUpperCase()
              .startsWith('${group.toUpperCase()}.X-ABLABEL:')) {
            final label = related.split(':').last;
            if (label.startsWith('_\$!<') && label.endsWith('>!\$_')) {
              labelOverride = label.substring(4, label.length - 4);
            } else {
              labelOverride = label;
            }
          }
        }
      }

      // We ignore lines that don't represent a property, such as BEGIN, END,
      // VERSION, etc. We also ignore a few unsupported properties such as GEO,
      // SOUND, GENDER, etc.
      switch (op) {
        case 'PHOTO':
          // The content can be base64-encoded or a URL. Try to decode it, and
          // ignore the line if it fails.
          try {
            contact.photo = base64.decode(decode(content));
          } on FormatException {
            // Pass.
          }
          break;
        case 'N':
          // Format is N:<last>;<first>;<middle>;<prefix>;<suffix>
          final parts = content.split(';');
          final n = parts.length;
          if (n >= 1) contact.name.last = decode(parts[0]);
          if (n >= 2) contact.name.first = decode(parts[1]);
          if (n >= 3) contact.name.middle = decode(parts[2]);
          if (n >= 4) contact.name.prefix = decode(parts[3]);
          if (n >= 5) contact.name.suffix = decode(parts[4]);
          break;
        case 'FN':
          contact.displayName = decode(content);
          break;
        case 'NICKNAME':
          // Format is NICKNAME:<nickname 1>[,<nickname 2>[,...]]
          final parts = content.split(',');
          contact.name.nickname = decode(parts[0]);
          break;
        case 'TEL':
        case 'PHONE':
          // 2.1 uses PHONE, 3.0/4.0 use TEL. The label is denoted with
          // TYPE=<label>. Multiple labels are denoted with TYPE=<label1>,<label2>
          // or TYPE="<label1>,<label2>" or TYPE=label1;TYPE=label2. vCard 3.0
          // specifies primary number by adding type "pref", while vCard 4.0 uses
          // a separate param PREF=1 (or a higher value supposed to represent
          // higher priority). vCard 4.0 sometimes specifies VALUE=uri with a
          // value prefixed with "tel:". There are sometimes extensions, for
          // example "tel:+1-555-555-5555;ext=5555". In such cases we denote the
          // extension with a ';' – see https://www.lifewire.com/automatically-dialing-extensions-on-android-577619
          Phone phone;
          final number =
              content.startsWith('tel:') ? content.substring(4) : content;
          final numberParts = number.split(';ext=');
          if (numberParts.length == 2) {
            phone =
                Phone('${decode(numberParts[0])};${decode(numberParts[1])}');
          } else {
            phone = Phone(decode(numberParts[0]));
          }
          _parseLabel(params, labelOverride, _parsePhoneLabel, phone);
          contact.phones.add(phone);
          break;
        case 'EMAIL':
          var email = Email(decode(content));
          _parseLabel(params, labelOverride, _parseEmailLabel, email);
          contact.emails.add(email);
          break;
        case 'ADR':
          // Format is ADR:<pobox>;<extended address>;<street>;<locality (city)>;
          // <region (state/province)>;<postal code>;<country>
          var addressParts = content.split(';');
          if (addressParts.length != 7) {
            continue; // invalid line
          }
          var address = Address('');
          if (([addressParts[0]] + addressParts.sublist(3))
              .any((x) => x.isNotEmpty)) {
            address.pobox = decode(addressParts[0]);
            address.street = decode(addressParts[2]);
            address.city = decode(addressParts[3]);
            address.state = decode(addressParts[4]);
            address.postalCode = decode(addressParts[5]);
            address.country = decode(addressParts[6]);
          }
          address.address =
              addressParts.map(decode).where((x) => x.isNotEmpty).join(' ');
          _parseLabel(params, labelOverride, _parseAddressLabel, address);
          contact.addresses.add(address);
          break;
        case 'ORG':
          // Format is ORG:<company>[;<division>[:<subdivision>...]]
          if (contact.organizations.isEmpty) {
            contact.organizations = [Organization()];
          }
          final orgParts = content.split(';');
          final n = orgParts.length;
          if (n >= 1) {
            contact.organizations.first.company = decode(orgParts[0]);
          }
          if (n >= 2) {
            contact.organizations.first.department = decode(orgParts[1]);
          }
          break;
        case 'TITLE':
          if (contact.organizations.isEmpty) {
            contact.organizations = [Organization()];
          }
          contact.organizations.first.title = decode(content);
          break;
        case 'ROLE':
          if (contact.organizations.isEmpty) {
            contact.organizations = [Organization()];
          }
          contact.organizations.first.jobDescription = decode(content);
          break;
        case 'URL':
          var website = Website(decode(content));
          _parseLabel(params, labelOverride, _parseWebsiteLabel, website);
          contact.websites.add(website);
          break;
        case 'IMPP':
          // Format is IMPP:<protocol>:<username>
          final contentParts = content.split(':');
          if (contentParts.length != 2) {
            continue; // invalid line
          }
          final serviceTypes = params.where((p) => p.key == 'X-SERVICE-TYPE');
          final protocol = decode(serviceTypes.isNotEmpty
              ? serviceTypes.first.value!
              : contentParts[0]);
          // ICQ gets duplicated into an ICQ and an AIM line due to a bug:
          // https://discussions.apple.com/thread/2769242
          if (serviceTypes.isNotEmpty &&
              serviceTypes.first.value == 'ICQ' &&
              contentParts[0] == 'aim') {
            continue;
          }
          final userName = decode(contentParts[1]);
          final label =
              lowerCaseStringToSocialMediaLabel[protocol.toLowerCase()] ??
                  SocialMediaLabel.custom;
          final customLabel = label == SocialMediaLabel.custom ? protocol : '';
          contact.socialMedias.add(
              SocialMedia(userName, label: label, customLabel: customLabel));
          break;
        case 'X-SOCIALPROFILE':
          // On iOS social profiles are different from instant messaging, and
          // exported as X-SOCIALPROFILE;type=<protocol>:<username>
          var protocol = '';
          for (final param in params) {
            if (param.key == 'TYPE') {
              protocol = decode(param.value!);
            }
          }
          if (params.any((p) => p.key == 'X-USER' && p.value == 'TENCENT')) {
            protocol = 'tencent';
          }
          var userName = decode(content);
          for (final prefix in ['x-apple:', 'xmpp:']) {
            if (userName.startsWith(prefix)) {
              userName = userName.substring(prefix.length);
              break;
            }
          }
          final label =
              lowerCaseStringToSocialMediaLabel[protocol.toLowerCase()] ??
                  SocialMediaLabel.custom;
          final customLabel = label == SocialMediaLabel.custom ? protocol : '';
          contact.socialMedias.add(
              SocialMedia(userName, label: label, customLabel: customLabel));
          break;
        case 'BDAY':
        case 'ANNIVERSARY':
          final label =
              op == 'BDAY' ? EventLabel.birthday : EventLabel.anniversary;
          final date = decode(content);
          final omitYear = params.any((p) => p.key == 'X-APPLE-OMIT-YEAR');
          _tryAddEvent(contact, date, label, '', omitYear);
          break;
        case 'NOTE':
          contact.notes.add(Note(decode(content)));
          break;
        case 'X-ANDROID-CUSTOM':
          // Android default contact app exports anniversary (1), other (2),
          // and custom events (0) as:
          // X-ANDROID-CUSTOM:vnd.android.cursor.item/contact_event;--03-23;1;;;;;;;;;;;;;
          // X-ANDROID-CUSTOM:vnd.android.cursor.item/contact_event;2021-04-23;2;;;;;;;;;;;;;
          // X-ANDROID-CUSTOM:vnd.android.cursor.item/contact_event;2017-09-23;0;Custom;;;;;;;;;;;;
          // and nicknames as
          // X-ANDROID-CUSTOM:vnd.android.cursor.item/nickname;Nick;1;;;;;;;;;;;;;
          final contentParts = content.split(';');
          final n = contentParts.length;
          if (n < 2) {
            continue; // invalid line
          }
          switch (contentParts[0]) {
            case 'vnd.android.cursor.item/contact_event':
              final date = decode(contentParts[1]);
              final labelStr = n >= 3 ? contentParts[2] : '';
              var label = EventLabel.other;
              if (labelStr == '0') {
                label = EventLabel.custom;
              } else if (labelStr == '1') {
                label = EventLabel.anniversary;
              }
              final customLabel = n >= 4 && label == EventLabel.custom
                  ? decode(contentParts[3])
                  : '';
              _tryAddEvent(contact, date, label, customLabel, false);
              break;
            case 'vnd.android.cursor.item/nickname':
              contact.name.nickname = decode(contentParts[1]);
              break;
          }
          break;
        case 'X-AIM':
          contact.socialMedias
              .add(SocialMedia(decode(content), label: SocialMediaLabel.aim));
          break;
        case 'X-MSN':
          contact.socialMedias
              .add(SocialMedia(decode(content), label: SocialMediaLabel.msn));
          break;
        case 'X-YAHOO':
          contact.socialMedias
              .add(SocialMedia(decode(content), label: SocialMediaLabel.yahoo));
          break;
        case 'X-SKYPE-USERNAME':
          contact.socialMedias
              .add(SocialMedia(decode(content), label: SocialMediaLabel.skype));
          break;
        case 'X-QQ':
          contact.socialMedias.add(
              SocialMedia(decode(content), label: SocialMediaLabel.qqchat));
          break;
        case 'X-GOOGLE-TALK':
          contact.socialMedias.add(
              SocialMedia(decode(content), label: SocialMediaLabel.googleTalk));
          break;
        case 'X-ICQ':
          contact.socialMedias
              .add(SocialMedia(decode(content), label: SocialMediaLabel.icq));
          break;
        case 'X-JABBER':
          contact.socialMedias.add(
              SocialMedia(decode(content), label: SocialMediaLabel.jabber));
          break;
        case 'X-PHONETIC-FIRST-NAME':
          contact.name.firstPhonetic = decode(content);
          break;
        case 'X-PHONETIC-LAST-NAME':
          contact.name.lastPhonetic = decode(content);
          break;
        case 'X-PHONETIC-ORG':
          if (contact.organizations.isEmpty) {
            contact.organizations = [Organization()];
          }
          contact.organizations.first.phoneticName = decode(content);
          break;
        case 'X-ABDATE':
          var tempContact = Contact();
          final date = decode(content);
          final omitYear = params.any((p) => p.key == 'X-APPLE-OMIT-YEAR');
          _tryAddEvent(tempContact, date, EventLabel.birthday, '', omitYear);
          if (tempContact.events.isNotEmpty) {
            _parseEventLabel(labelOverride, tempContact.events.last, true);
            contact.events.add(tempContact.events.last);
          }
          break;
      }
    }
    // Deduplicate properties, mostly because of iOS duplicating social profiles
    // and instant messaging.
    contact.deduplicateProperties();
  }
}

void _tryAddEvent(
  Contact contact,
  String date,
  EventLabel label,
  String customLabel,
  bool omitYear,
) {
  if (_dateRegexp.hasMatch(date)) {
    contact.events.add(Event(
        year: omitYear ? null : int.parse(date.substring(0, 4)),
        month: int.parse(date.substring(5, 7)),
        day: int.parse(date.substring(8, 10)),
        label: label,
        customLabel: customLabel));
  } else if (_noYearDateRegexp.hasMatch(date)) {
    contact.events.add(Event(
        year: null,
        month: int.parse(date.substring(2, 4)),
        day: int.parse(date.substring(5, 7)),
        label: label,
        customLabel: customLabel));
  } else if (_dateNoDashRegexp.hasMatch(date)) {
    contact.events.add(Event(
        year: omitYear ? null : int.parse(date.substring(0, 4)),
        month: int.parse(date.substring(4, 6)),
        day: int.parse(date.substring(6, 8)),
        label: label,
        customLabel: customLabel));
  } else if (_noYearDateNoDashRegexp.hasMatch(date)) {
    contact.events.add(Event(
        year: null,
        month: int.parse(date.substring(2, 4)),
        day: int.parse(date.substring(4, 6)),
        label: label,
        customLabel: customLabel));
  } else {
    final dt = DateTime.tryParse(date);
    if (dt != null) {
      contact.events.add(Event(
          year: omitYear ? null : dt.year,
          month: dt.month,
          day: dt.day,
          label: label,
          customLabel: customLabel));
    }
  }
}

void _parsePhoneLabel(String label, Phone phone, bool defaultToCustom) {
  switch (label.toUpperCase()) {
    case 'HOME':
      if (phone.label != PhoneLabel.faxHome) {
        phone.label = PhoneLabel.home;
      }
      break;
    case 'CELL':
    case 'MOBILE':
      if (phone.label != PhoneLabel.iPhone) {
        phone.label = PhoneLabel.mobile;
      }
      break;
    case 'IPHONE':
      phone.label = PhoneLabel.iPhone;
      break;
    case 'MAIN':
      phone.label = PhoneLabel.main;
      break;
    case 'WORK':
      if (phone.label == PhoneLabel.faxHome) {
        phone.label = PhoneLabel.faxWork;
      } else if (phone.label == PhoneLabel.pager) {
        phone.label = PhoneLabel.workPager;
      } else {
        phone.label = PhoneLabel.work;
      }
      break;
    case 'OTHER':
      if (phone.label == PhoneLabel.faxHome) {
        phone.label = PhoneLabel.faxOther;
      } else {
        phone.label = PhoneLabel.other;
      }
      break;
    case 'PAGER':
      if (phone.label == PhoneLabel.work) {
        phone.label = PhoneLabel.workPager;
      } else {
        phone.label = PhoneLabel.pager;
      }
      break;
    case 'FAX':
      if (phone.label == PhoneLabel.work) {
        phone.label = PhoneLabel.faxWork;
      } else if (phone.label == PhoneLabel.pager) {
        phone.label = PhoneLabel.workPager;
      } else if (phone.label == PhoneLabel.other) {
        phone.label = PhoneLabel.faxOther;
      } else {
        phone.label = PhoneLabel.faxHome;
      }
      break;
    case 'PREF':
      phone.isPrimary = true;
      break;
    default:
      if (defaultToCustom) {
        phone.label = PhoneLabel.custom;
        phone.customLabel = label;
      }
  }
}

void _parseEmailLabel(String label, Email email, bool defaultToCustom) {
  switch (label.toUpperCase()) {
    case 'HOME':
      email.label = EmailLabel.home;
      break;
    case 'MOBILE':
    case 'CELL':
      email.label = EmailLabel.mobile;
      break;
    case 'WORK':
      email.label = EmailLabel.work;
      break;
    case 'OTHER':
      email.label = EmailLabel.other;
      break;
    case 'PREF':
      email.isPrimary = true;
      break;
    default:
      if (defaultToCustom) {
        email.label = EmailLabel.custom;
        email.customLabel = label;
      }
  }
}

void _parseAddressLabel(String label, Address address, bool defaultToCustom) {
  switch (label.toUpperCase()) {
    case 'HOME':
      address.label = AddressLabel.home;
      break;
    case 'WORK':
      address.label = AddressLabel.work;
      break;
    case 'OTHER':
      address.label = AddressLabel.other;
      break;
    default:
      if (defaultToCustom) {
        address.label = AddressLabel.custom;
        address.customLabel = label;
      }
  }
}

void _parseWebsiteLabel(String label, Website website, bool defaultToCustom) {
  switch (label.toUpperCase()) {
    case 'HOME':
      website.label = WebsiteLabel.home;
      break;
    case 'HOMEPAGE':
      website.label = WebsiteLabel.homepage;
      break;
    case 'WORK':
      website.label = WebsiteLabel.work;
      break;
    case 'OTHER':
      website.label = WebsiteLabel.other;
      break;
    default:
      if (defaultToCustom) {
        website.label = WebsiteLabel.custom;
        website.customLabel = label;
      }
  }
}

void _parseEventLabel(String label, Event event, bool defaultToCustom) {
  switch (label.toUpperCase()) {
    case 'BIRTHDAY':
      event.label = EventLabel.birthday;
      break;
    case 'ANNIVERSARY':
      event.label = EventLabel.anniversary;
      break;
    case 'OTHER':
      event.label = EventLabel.other;
      break;
    default:
      if (defaultToCustom) {
        event.label = EventLabel.custom;
        event.customLabel = label;
      }
  }
}

void _parseLabel<T>(
  List<Param> params,
  String labelOverride,
  void Function(String, T, bool) parseFunction,
  T property,
) {
  if (labelOverride.isNotEmpty) {
    parseFunction(labelOverride, property, true);
  } else {
    for (final param in params) {
      if (param.key == 'TYPE') {
        final types =
            (param.value!.startsWith('"') && param.value!.endsWith('"')
                    ? param.value!.substring(1, param.value!.length - 1)
                    : param.value)!
                .split(',');
        for (final type in types) {
          parseFunction(type, property, false);
        }
      } else {
        parseFunction(param.key, property, false);
      }
    }
  }
}
