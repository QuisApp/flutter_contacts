import 'dart:typed_data';

import 'package:diacritic/diacritic.dart';
import 'package:flutter_contacts/vcard_exporter.dart';
import 'package:flutter_contacts/vcard_parser.dart';
import 'package:json_annotation/json_annotation.dart';

import 'properties/account.dart';
import 'properties/address.dart';
import 'properties/email.dart';
import 'properties/event.dart';
import 'properties/name.dart';
import 'properties/note.dart';
import 'properties/organization.dart';
import 'properties/phone.dart';
import 'properties/social_media.dart';
import 'properties/website.dart';

part 'contact.g.dart';

/// A contact.
///
/// [id] represents the unified contact ID (a concept shared by android and iOS:
/// e.g. a "raw contact" from Gmail and another one from WhatsApp may be merged
/// into a single unfied contact, which is what we care about most of the time).
///
/// [displayName] is the only other required field, and represents a
/// single-string representation of the contact's name.
@JsonSerializable(
    // call .toJson on nested fields
    explicitToJson: true,
    // we'd want this to be true, but can't because of the photo field
    disallowUnrecognizedKeys: false,
    // this is to expect `Map` instead of `Map<String, dynamic>`
    anyMap: true)
class Contact {
  /// Create a new contact, with empty contact ID and display name.
  ///
  /// By default an empty name is also created (as opposed to name being null),
  /// but that can be controlled with [createEmptyName].
  Contact.create({bool createEmptyName = true})
      : this('', '', name: createEmptyName ? Name() : null);

  /// Contact ID, corresponding to the native contact ID.
  @JsonKey(required: true)
  String id;

  /// Display name (name formatted into a single string). Always provided.
  @JsonKey(required: true)
  String displayName;

  /// Photo, which can be null
  ///
  /// JsonSerializer doesn't support Uint8List:
  /// https://github.com/google/json_serializable.dart/issues/572
  ///
  /// Because of that we cannot set `disallowUnrecognizedKeys` to true on the
  /// class.
  @JsonKey(ignore: true)
  Uint8List photo;

  /// Structured name of the contact
  ///
  /// Marked nullable because we can't use a default value of Name() since it's
  /// not constant, but it is effectively the default value
  @JsonKey(nullable: true /* defaultValue = Name() */)
  Name name;

  /// Phone numbers
  @JsonKey(defaultValue: [])
  List<Phone> phones;

  /// Email addresses
  @JsonKey(defaultValue: [])
  List<Email> emails;

  /// Postal addresses
  @JsonKey(defaultValue: [])
  List<Address> addresses;

  /// Company / job
  ///
  /// We support multiple entries for compatibility with Android.
  @JsonKey(defaultValue: [])
  List<Organization> organizations;

  /// Websites / URLs
  @JsonKey(defaultValue: [])
  List<Website> websites;

  /// Social media profiles and instant messaging
  @JsonKey(defaultValue: [])
  List<SocialMedia> socialMedias;

  /// Events, such as birthday and anniversary
  @JsonKey(defaultValue: [])
  List<Event> events;

  /// Notes (iOS supports only one, Android allows multiple notes)
  @JsonKey(defaultValue: [])
  List<Note> notes;

  /// Android raw accounts. Android only.
  @JsonKey(defaultValue: [])
  List<Account> accounts;

  Contact(
    this.id,
    this.displayName, {
    this.photo,
    Name name,
    List<Phone> phones,
    List<Email> emails,
    List<Address> addresses,
    List<Organization> organizations,
    List<Website> websites,
    List<SocialMedia> socialMedias,
    List<Event> events,
    List<Note> notes,
    List<Account> accounts,
  })  : name = name ?? Name(),
        phones = phones ?? <Phone>[],
        emails = emails ?? <Email>[],
        addresses = addresses ?? <Address>[],
        organizations = organizations ?? <Organization>[],
        websites = websites ?? <Website>[],
        socialMedias = socialMedias ?? <SocialMedia>[],
        events = events ?? <Event>[],
        notes = notes ?? <Note>[],
        accounts = accounts ?? <Account>[];

  /// Parse contact from vCard content
  factory Contact.fromVCard(String vCard) {
    Contact c;
    VCardParser().parse(vCard, c);
    return c;
  }

  /// Returns normalized display name, which ignores case, space and diacritics.
  String get normalizedName =>
      removeDiacritics(displayName.trim().toLowerCase());

  factory Contact.fromJson(Map json) {
    var contact = _$ContactFromJson(json);
    // photo requires special handling since it's ignored by json serialization
    contact.photo = json['photo'] as Uint8List;
    return contact;
  }

  Map<String, dynamic> toJson({
    bool includePhoto = false,
    bool includeNormalizedNumber = true,
  }) {
    var json = _$ContactToJson(this);
    // photo requires special handling since it's ignored by json serialization
    if (includePhoto) json['photo'] = photo;
    if (!includeNormalizedNumber) {
      for (var i = 0; i < json['phones'].length; ++i) {
        json['phones'][i]['normalizedNumber'] = '';
      }
    }
    return json;
  }

  /// Export contact to vCard
  String toVCard() => VCardExporter().toVCard(this);

  void deduplicatePhones() {
    var normalizedPhonesSeen = Set<String>();
    var phonesSeen = Set<String>();
    var uniquePhones = <Phone>[];
    for (var phone in phones) {
      // Don't add phone if we've already seen that number (raw or normalized)
      if (phonesSeen.contains(phone.number) ||
          (phone.normalizedNumber.isNotEmpty &&
              normalizedPhonesSeen.contains(phone.normalizedNumber))) {
        continue;
      }
      normalizedPhonesSeen.add(phone.normalizedNumber);
      phonesSeen.add(phone.number);
      uniquePhones.add(phone);
    }
    phones = uniquePhones;
  }

  void deduplicateEmails() {
    var emailsSeen = Set<String>();
    var uniqueEmails = <Email>[];
    for (var email in emails) {
      if (!emailsSeen.contains(email.address)) {
        emailsSeen.add(email.address);
        uniqueEmails.add(email);
      }
    }
    emails = uniqueEmails;
  }

  void deduplicateEvents() {
    var eventsSeen = Set<int>();
    var uniqueEvents = <Event>[];
    for (var event in events) {
      final hash = event.date.hashCode ^
          event.label.hashCode ^
          event.customLabel.hashCode ^
          event.noYear.hashCode;
      if (!eventsSeen.contains(hash)) {
        eventsSeen.add(hash);
        uniqueEvents.add(event);
      }
    }
    events = uniqueEvents;
  }
}
