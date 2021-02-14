import 'dart:convert';
import 'dart:math';

import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/properties/address.dart';
import 'package:flutter_contacts/properties/email.dart';
import 'package:flutter_contacts/properties/event.dart';
import 'package:flutter_contacts/properties/phone.dart';
import 'package:flutter_contacts/properties/social_media.dart';

class VCardExporter {
  String toVCard(Contact c) {
    var lines = [
      'BEGIN:VCARD',
      'VERSION:3.0',
    ];

    String encode(String s) =>
        s.replaceAll(',', '\\,').replaceAll(';', '\\;').replaceAll('\n', '\\n');

    // Name
    // format is N:<last>;<first>;<middle>;<prefix>;<suffix>
    final n = c.name;
    lines.add('N:' +
        [n.last, n.first, n.middle, n.prefix, n.suffix].map(encode).join(';'));
    lines.add('FN:' + encode(c.displayName));
    if (n.nickname.isNotEmpty) lines.add('NICKNAME:' + encode(n.nickname));

    // Phones
    for (final phone in c.phones) {
      var types = <String>[];
      if (phone.label == PhoneLabel.mobile) {
        types.add('CELL');
      } else if (phone.label == PhoneLabel.work) {
        types.add('WORK');
      } else if (phone.label == PhoneLabel.home) {
        types.add('HOME');
      } else if (phone.label == PhoneLabel.custom) {
        types.add(encode(phone.customLabel));
      } else {
        types.add(
            encode(phone.label.toString().substring('PhoneLabel.'.length)));
      }
      if (phone.isPrimary) {
        types.add('PREF');
      }
      var line = 'TEL';
      if (types.isNotEmpty) {
        line += ';TYPE=${types.join(',')}';
      }
      line += ':' + encode(phone.number);
      lines.add(line);
    }

    // Emails
    for (final email in c.emails) {
      var types = <String>[];
      if (email.label == EmailLabel.mobile) {
        types.add('CELL');
      } else if (email.label == EmailLabel.work) {
        types.add('WORK');
      } else if (email.label == EmailLabel.home) {
        types.add('HOME');
      } else if (email.label == EmailLabel.custom) {
        types.add(encode(email.customLabel));
      } else {
        types.add(
            encode(email.label.toString().substring('EmailLabel.'.length)));
      }
      if (email.isPrimary) {
        types.add('PREF');
      }
      var line = 'EMAIL';
      if (types.isNotEmpty) {
        line += ';TYPE=${types.join(',')}';
      }
      line += ':' + encode(email.address);
      lines.add(line);
    }

    // Addresses
    for (final address in c.addresses) {
      var types = <String>[];
      if (address.label == AddressLabel.work) {
        types.add('WORK');
      } else if (address.label == AddressLabel.home) {
        types.add('HOME');
      } else if (address.label == AddressLabel.custom) {
        types.add(encode(address.customLabel));
      } else {
        types.add(
            encode(address.label.toString().substring('AddressLabel.'.length)));
      }
      var line = 'ADR';
      if (types.isNotEmpty) {
        line += ';TYPE=${types.join(',')}';
      }
      // Format is ADR:<pobox>:<extended address>:<street>:<locality (city)>:
      //    <region (state/province)>:<postal code>:country
      // We put everything in <street> for simplicity.
      line += ':;;' + encode(address.address) + ';;;;';
      lines.add(line);
    }

    // Organization
    if (c.organizations.isNotEmpty) {
      final org = c.organizations.first;
      if (org.company.isNotEmpty) {
        lines.add('ORG:' + encode(org.company));
      }
      if (org.title.isNotEmpty) {
        lines.add('TITLE:' + encode(org.title));
      }
    }

    // Websites
    for (final website in c.websites) {
      lines.add('URL:' + encode(website.url));
    }

    // IMs
    for (final socialMedia in c.socialMedias) {
      var label = '';
      if (socialMedia.label == SocialMediaLabel.custom) {
        label = socialMedia.customLabel;
      } else {
        label =
            socialMedia.label.toString().substring('SocialMediaLabel.'.length);
      }
      lines.add('IMPP:' + encode(label) + ':' + encode(socialMedia.userName));
    }

    // Dates
    for (final event in c.events) {
      if (event.label == EventLabel.birthday) {
        lines.add('BDAY:' + _formatDate(event.date));
      } else if (event.label == EventLabel.anniversary) {
        lines.add('ANNIVERSARY:' + _formatDate(event.date));
      } else {
        lines.add('DATE:' + _formatDate(event.date));
      }
    }

    // Notes
    for (final note in c.notes) {
      lines.add('NOTE:' + encode(note.note));
    }

    // Photo
    if (c.photo != null) {
      final encoding = encode(base64.encode(c.photo));
      // 63 chars on each line
      lines.add('PHOTO;ENCODING=b;TYPE=JPEG:' +
          encoding.substring(0, min(36, encoding.length)));
      // Subsequent lines have a leading space, and 62 chars each
      var index = 36;
      while (index < encoding.length) {
        lines.add(
            ' ' + encoding.substring(index, min(index + 62, encoding.length)));
        index += 62;
      }
    }

    lines.add('END:VCARD');
    return lines.join('\n');
  }

  // to avoid dependency on intl
  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
