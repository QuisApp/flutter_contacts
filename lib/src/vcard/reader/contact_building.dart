import '../../../models/contact/contact.dart';
import '../core/property.dart';
import '../utils/encoding/encoding.dart';
import 'contact_builder.dart';
import '../properties/address/address_parser.dart';
import '../properties/name/name_parser.dart';
import '../properties/phone/phone_parser.dart';
import '../properties/email/email_parser.dart';
import '../properties/organization/organization_parser.dart';
import '../properties/event/event_parser.dart';
import '../properties/relation/relation_parser.dart';
import '../properties/social_media/social_media_parser.dart';
import '../properties/photo/photo_parser.dart';
import '../properties/website/website_parser.dart';
import '../properties/note/note_parser.dart';

/// Builds a Contact from parsed properties.
///
/// Handles grouped properties (item1.TEL, item1.X-ABLabel) by collecting them
/// first, then processing together to match labels with their properties.
Contact buildContact(List<VCardProperty> properties) {
  final builder = ContactBuilder();
  final grouped = <String, _LabeledProperty>{};

  for (final prop in properties) {
    if (prop is RegularProperty) {
      _processRegularProperty(prop, builder);
    } else if (prop is GroupedProperty) {
      grouped.putIfAbsent(prop.group, () => _LabeledProperty()).main = prop;
    } else if (prop is LabelProperty) {
      grouped.putIfAbsent(prop.group, () => _LabeledProperty()).label = prop;
    }
  }

  // Process grouped properties after collecting all groups
  for (final group in grouped.values.where((g) => g.main != null)) {
    _processGroupedProperty(group.main!, group.label?.value, builder);
  }

  return builder.build();
}

void _processRegularProperty(RegularProperty prop, ContactBuilder builder) {
  switch (prop.name) {
    case 'UID':
      builder.id = prop.value;
    case 'FN':
      builder.displayName = unescapeValue(prop.value);
    case 'N':
      builder.name = parseName(prop.value);
    case 'NICKNAME':
    case 'X-NICKNAME':
      builder.updateName(nickname: unescapeValue(prop.value));
    case 'X-PHONETIC-FIRST-NAME':
      builder.updateName(phoneticFirst: unescapeValue(prop.value));
    case 'X-PHONETIC-MIDDLE-NAME':
      builder.updateName(phoneticMiddle: unescapeValue(prop.value));
    case 'X-PHONETIC-LAST-NAME':
      builder.updateName(phoneticLast: unescapeValue(prop.value));
    case 'TEL':
      builder.phones.add(parsePhone(prop));
    case 'EMAIL':
      builder.emails.add(parseEmail(prop));
    case 'ADR':
      builder.addresses.add(parseAddress(prop));
    case 'ORG':
      builder.organizations.add(parseOrganization(prop));
    case 'TITLE':
      builder.updateOrganization(jobTitle: unescapeValue(prop.value));
    case 'ROLE':
    case 'X-JOB-DESCRIPTION':
      builder.updateOrganization(jobDescription: unescapeValue(prop.value));
    case 'X-ORG-SYMBOL':
      builder.updateOrganization(symbol: unescapeValue(prop.value));
    case 'X-ORG-OFFICE':
      builder.updateOrganization(officeLocation: unescapeValue(prop.value));
    case 'X-PHONETIC-ORG-NAME':
      builder.updateOrganization(phoneticName: unescapeValue(prop.value));
    case 'URL':
      builder.websites.add(parseWebsite(prop));
    case 'BDAY':
    case 'X-ANNIVERSARY':
    case 'ANNIVERSARY':
    case 'X-EVENT':
      builder.events.add(parseEvent(prop));
    case 'RELATED':
    case 'X-RELATION':
      builder.relations.add(parseRelation(prop));
    case 'NOTE':
      builder.notes.add(parseNote(prop));
    case 'PHOTO':
      builder.photo = parsePhoto(prop);
    case 'X-ANDROID-STARRED':
      builder.isFavorite = prop.value == '1';
    case 'X-ANDROID-CUSTOM-RINGTONE':
      builder.customRingtone = prop.value;
    case 'X-ANDROID-SEND-TO-VOICEMAIL':
      builder.sendToVoicemail = prop.value == '1';
  }
}

void _processGroupedProperty(
  GroupedProperty prop,
  String? label,
  ContactBuilder builder,
) {
  switch (prop.name) {
    case 'TEL':
      builder.phones.add(parsePhone(prop, label));
    case 'EMAIL':
      builder.emails.add(parseEmail(prop, label));
    case 'ADR':
      builder.addresses.add(parseAddress(prop, label));
    case 'X-SOCIALPROFILE':
      builder.socialMedias.add(parseSocialMedia(prop, label));
    case 'RELATED':
    case 'X-RELATION':
      builder.relations.add(parseRelation(prop, label));
  }
}

class _LabeledProperty {
  GroupedProperty? main;
  LabelProperty? label;
}
