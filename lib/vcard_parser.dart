import 'dart:convert';

import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/properties/address.dart';
import 'package:flutter_contacts/properties/email.dart';
import 'package:flutter_contacts/properties/organization.dart';
import 'package:flutter_contacts/properties/phone.dart';
import 'package:flutter_contacts/properties/social_media.dart';
import 'package:flutter_contacts/properties/website.dart';

enum Version {
  V2_1,
  V3,
  V4,
}

class Param {
  final String key;
  final String value;
  Param(this.key, this.value);
  @override
  String toString() => '$key => $value';
}

class VCardParser {
  Version version = Version.V3;
  bool firstLineSeen = false;
  bool lastLineSeen = false;

  String photo;
  bool buildingPhoto = false;

  String encode(String s) => s
      .replaceAll('\\,', '&fluttercontactscomma&')
      .replaceAll('\\;', '&fluttercontactssemicolon&')
      .replaceAll('\\n', '&fluttercontactsnewline&');

  String decode(String s) => s
      .replaceAll('&fluttercontactscomma&', ',')
      .replaceAll('&fluttercontactssemicolon&', ';')
      .replaceAll('&fluttercontactsnewline&', '\n');

  void parse(String content, Contact contact) {
    var lines = encode(content).split('\n').map((String x) => x.trim());
    for (final line in lines) {
      final parts = line.split(':');

      if (parts.length >= 2 && !buildingPhoto) {
        // This is the normal case. Just go on normally.
      } else if (parts.length < 2 && !buildingPhoto) {
        // Indicates invalid line, we'll just ignore it.
        continue;
      } else if (parts.length < 2 && buildingPhoto) {
        // Continue building photo.
        photo += line;
        continue;
      } else if (parts.length >= 2 && buildingPhoto) {
        // Stop building photo, and go on normally.
        buildingPhoto = false;
        contact.photo = base64.decode(decode(photo));
      }

      final firstPart = parts[0];
      final opParts = firstPart.split(';');
      final opComplete = opParts[0].toUpperCase();
      // iOS exports repeated fields with custom labels like this:
      // TEL;type=HOME;type=VOICE;type=pref:(333) 111-2222
      // item2.TEL:(242) 164-5875
      // item2.X-ABLabel:custom_label
      // For simplicity we'll just drop the label in such cases
      final op = opComplete.split('.').last;
      var params = <Param>[];
      for (var part in opParts.sublist(1)) {
        final paramsParts = part.split('=');
        if (paramsParts.length >= 2) {
          params.add(Param(paramsParts[0].toUpperCase(),
              paramsParts.sublist(1).join('=').toUpperCase()));
        }
      }
      final val = parts.sublist(1).join(':');

      if (op == 'BEGIN') {
        // nothing to do
      } else if (op == 'END') {
        // nothing to do
      } else if (op == 'VERSION') {
        if (val == '2.1') {
          version = Version.V2_1;
        } else if (val == '3' || val == '3.' || val == '3.0') {
          version = Version.V3;
        } else if (val == '4' || val == '4.' || val == '4.0') {
          version = Version.V4;
        } else {
          // invalid version, falling back on version 3
        }
      } else if (op == 'PRODID') {
        // ignored
      } else if (op == 'N') {
        // format is N:<last>;<first>;<middle>;<prefix>;<suffix>
        final parts = val.split(';');
        if (parts.length != 5) continue;
        contact.name.last = decode(parts[0]);
        contact.name.first = decode(parts[1]);
        contact.name.middle = decode(parts[2]);
        contact.name.prefix = decode(parts[3]);
        contact.name.suffix = decode(parts[4]);
      } else if (op == 'FN') {
        // formatted name
        contact.displayName = decode(val);
      } else if (op == 'NICKNAME') {
        // format is N:<nickname 1>[,<nickname 2>[,...]]
        final parts = val.split(',');
        contact.name.nickname = decode(parts[0]);
      } else if (op == 'TEL') {
        // TEL;VALUE=uri;PREF=1;TYPE="voice,home":tel:+1-555-555-5555;ext=5555
        // TEL;type=HOME;type=VOICE;type=pref:1 (234) 567-893
        // TEL;type=WORK;type=VOICE:(987) 654-321
        // TEL;TYPE=cell:(123) 555-583
        if (val.isEmpty) continue;
        Phone phone;
        if (val.startsWith('tel:')) {
          phone = Phone(decode(val.substring(4).split(';')[0]));
        } else {
          phone = Phone(decode(val));
        }
        for (var param in params) {
          if (param.key == 'TYPE') {
            if (param.value == 'HOME') {
              phone.label = PhoneLabel.home;
            } else if (param.value == 'MOBILE' || param.value == 'CELL') {
              phone.label = PhoneLabel.mobile;
            } else if (param.value == 'WORK') {
              phone.label = PhoneLabel.work;
            } else if (param.value == 'PREF') {
              phone.isPrimary = true;
            }
          }
        }
        contact.phones.add(phone);
      } else if (op == 'EMAIL') {
        // EMAIL;TYPE=work:jqpublic@xyz.example.com
        // EMAIL;PREF=1:jane_doe@example.com
        // EMAIL;type=INTERNET;type=HOME;type=pref:e@a.com
        // EMAIL;type=INTERNET;type=WORK:e@b.com
        if (val.isEmpty) continue;
        var email = Email(decode(val));
        for (var param in params) {
          if (param.key == 'TYPE') {
            if (param.value == 'HOME') {
              email.label = EmailLabel.home;
            } else if (param.value == 'MOBILE' || param.value == 'CELL') {
              email.label = EmailLabel.mobile;
            } else if (param.value == 'WORK') {
              email.label = EmailLabel.work;
            } else if (param.value == 'PREF') {
              email.isPrimary = true;
            }
          } else if (param.key == 'PREF') {
            email.isPrimary = true;
          }
        }
        contact.emails.add(email);
      } else if (op == 'ADR') {
        // ADR;TYPE=home:;;123 Main St.;Springfield;IL;12345;USA
        // item1.ADR;type=HOME;type=pref:;;52 rue des Fleurs;Libourne;;33500;France
        // item2.ADR;type=WORK:;;22 Foo St;San Francisco;CA;94100;United States
        // Format is ADR:<pobox>:<extended address>:<street>:<locality (city)>:
        //    <region (state/province)>:<postal code>:country
        // The spec says first two should be empty to avoid problems, so we'll
        // just ignore them.
        var addressParts = val.split(';');
        if (addressParts.length != 7) continue;
        final street = addressParts[2];
        final locality = addressParts[3];
        final region = addressParts[4];
        final postal = addressParts[5];
        final country = addressParts[6];
        var components = <String>[];
        if (street.isNotEmpty) {
          components.add(street.trim());
        }
        if (locality.isNotEmpty || region.isNotEmpty || postal.isNotEmpty) {
          // e.g. San Francisco CA 94100
          // e.g. Libourne 33500
          // not perfect but good enough
          components
              .add([locality, region, postal].map((x) => x.trim()).join(' '));
        }
        if (country.isNotEmpty) components.add(country);
        if (components.isEmpty) continue;
        var address = Address(decode(components.join('\n')));
        for (var param in params) {
          if (param.key == 'TYPE') {
            if (param.value == 'HOME') {
              address.label = AddressLabel.home;
            } else if (param.value == 'WORK') {
              address.label = AddressLabel.work;
            }
          }
        }
        contact.addresses.add(address);
      } else if (op == 'ORG') {
        // Format is ORG:<company>[;<division>[:<subdivision>...]]
        var org = decode(val.split(';')[0]);
        if (org.isEmpty) continue;
        if (contact.organizations.isEmpty) {
          contact.organizations = [Organization()];
        }
        contact.organizations.first.company = decode(org);
      } else if (op == 'TITLE') {
        // Format is TITLE:<title>
        if (val.isEmpty) continue;
        if (contact.organizations.isEmpty) {
          contact.organizations = [Organization()];
        }
        contact.organizations.first.title = decode(val);
      } else if (op == 'URL') {
        // URLs have types, but we ignore them for now
        if (val.isEmpty) continue;
        contact.websites.add(Website(decode(val)));
      } else if (op == 'IMPP') {
        // IMPP;PREF=1:xmpp:alice@example.com
        // IMPP:aim:johndoe@aol.com
        // item7.IMPP;X-SERVICE-TYPE=Skype;type=pref:skype:skypehandle
        // item7.X-ABLabel:Skype
        // item8.IMPP;X-SERVICE-TYPE=QQ:x-apple:qqhandle
        // item8.X-ABLabel:QQ
        var imParts = val.split(':');
        if (imParts.length != 2) continue;
        final name = imParts[1];
        final type = imParts[0].toLowerCase();
        if (name.isEmpty) continue;
        var label = SocialMediaLabel.custom;
        var customLabel = '';
        switch (type) {
          case 'skype':
            label = SocialMediaLabel.skype;
            break;
          case 'snapchat':
            label = SocialMediaLabel.snapchat;
            break;
          case 'facebook':
            label = SocialMediaLabel.facebook;
            break;
          case 'twitter':
            label = SocialMediaLabel.twitter;
            break;
          case 'wechat':
            label = SocialMediaLabel.wechat;
            break;
          case 'qq':
          case 'qqchat':
            label = SocialMediaLabel.qqchat;
            break;
          case 'telegram':
            label = SocialMediaLabel.telegram;
            break;
          case 'discord':
            label = SocialMediaLabel.discord;
            break;
          case 'jabber':
            label = SocialMediaLabel.jabber;
            break;
          case 'yahoo':
            label = SocialMediaLabel.yahoo;
            break;
          case 'x-apple':
            customLabel = imParts[0];
            break;
          default:
            customLabel = type;
        }
        contact.socialMedias.add(
            SocialMedia(decode(name), label: label, customLabel: customLabel));
        break;
      } else if (op == 'X-SOCIALPROFILE') {
        // X-SOCIALPROFILE;type=twitter:http://twitter.com/twit
        // X-SOCIALPROFILE;type=facebook:http://www.facebook.com/fb
        if (val.isEmpty) continue;
        var label = SocialMediaLabel.custom;
        var customLabel = '';
        for (var param in params) {
          if (param.key == 'TYPE') {
            var type = param.value.toLowerCase();
            switch (type) {
              case 'skype':
                label = SocialMediaLabel.skype;
                break;
              case 'snapchat':
                label = SocialMediaLabel.snapchat;
                break;
              case 'facebook':
                label = SocialMediaLabel.facebook;
                break;
              case 'twitter':
                label = SocialMediaLabel.twitter;
                break;
              case 'wechat':
                label = SocialMediaLabel.wechat;
                break;
              case 'qqchat':
                label = SocialMediaLabel.qqchat;
                break;
              case 'telegram':
                label = SocialMediaLabel.telegram;
                break;
              case 'discord':
                label = SocialMediaLabel.discord;
                break;
              case 'jabber':
                label = SocialMediaLabel.jabber;
                break;
              case 'yahoo':
                label = SocialMediaLabel.yahoo;
                break;
              default:
                customLabel = param.value;
            }
          }
        }
        if (label == null) continue;
        contact.socialMedias.add(
            SocialMedia(decode(val), label: label, customLabel: customLabel));
      } else if (op == 'PHOTO') {
        // 2.1: PHOTO;JPEG:http://example.com/photo.jpg
        // 2.1: PHOTO;JPEG;ENCODING=BASE64:[base64-data]
        // 3.0: PHOTO;TYPE=JPEG;VALUE=URI:http://example.com/photo.jpg
        // 3.0: PHOTO;TYPE=JPEG;ENCODING=b:[base64-data]
        // 4.0: PHOTO;MEDIATYPE=image/jpeg:http://example.com/photo.jpg
        // 4.0: PHOTO:data:image/jpeg;base64,[base64-data]
        // 3.0: PHOTO;ENCODING=b;TYPE=JPEG:[bytes]
        var encoding = '';
        switch (version) {
          case Version.V2_1:
          case Version.V3:
            // Not perfect, but will do for now.
            if (val.startsWith('http') || val.startsWith('ftp')) {
              // not yet implemented
            } else {
              encoding = val;
            }
            break;
          case Version.V4:
            if (val.startsWith('http') || val.startsWith('ftp')) {
              // not yet implemented
            } else {
              encoding = val.split(',').last;
            }
        }
        if (encoding.isEmpty) continue;
        photo = encoding;
        buildingPhoto = true;
      } else if (op == 'BDAY') {
        // not yet implemented
      } else if (op == 'NOTES') {
        // not yet implemented
      } else if (op == 'X-ABDATE') {
        // not yet implemented
      } else if (op == 'X-ABRELATEDNAMES') {
        // not yet implemented
      } else if (op == 'X-ALTBDAY') {
        // not yet implemented
      } else if (op == 'NOTES') {
        // not yet implemented
      } else if (op == 'X-ABLABEL') {
        // currently ignored
      } else if (op == 'X-ABADR') {
        // currently ignored
      }
    }
  }
}
