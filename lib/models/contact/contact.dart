import '../properties/name.dart';
import '../properties/phone.dart';
import '../properties/email.dart';
import '../properties/address.dart';
import '../properties/organization.dart';
import '../properties/website.dart';
import '../properties/social_media.dart';
import '../properties/event.dart';
import '../properties/relation.dart';
import '../properties/note.dart';
import '../properties/photo.dart';
import '../android/android_data.dart';
import '../../utils/json_helpers.dart';
import 'contact_metadata.dart';

/// Unified contact model representing a contact across all platforms.
///
/// [id] is generated automatically by the system and is read-only.
/// [displayName] is computed automatically from [name] components by the platform and is read-only.
///
/// Property lists ([phones], [emails], [addresses], etc.) contain property objects, each with a label
/// (e.g., home, work, mobile) indicating its type.
///
/// Platform limitations:
/// - iOS: Notes require entitlements and `FlutterContacts.config.enableIosNotes = true`
/// - iOS/macOS: Limits [organizations], [notes], and [events] of type birthday to one per contact
/// - Not supported on iOS: [android], [Phone.isPrimary], [Email.isPrimary], [Address.poBox],
///   [Address.neighborhood], [Organization.jobDescription], [Organization.symbol],
///   [Organization.officeLocation], some labels
/// - Not supported on Android: [Name.previousFamilyName], [Address.isoCountryCode],
///   [Address.subAdministrativeArea], [Address.subLocality], some labels
///
/// [metadata] is auto-populated when fetching and required when updating. Never edit manually.
class Contact {
  /// Stable identifier for the unified contact.
  final String? id;

  /// Auto-generated display name (read-only, system-generated).
  final String? displayName;

  /// Contact photo.
  final Photo? photo;

  /// Structured name.
  final Name? name;

  /// Phone numbers.
  final List<Phone> phones;

  /// Email addresses.
  final List<Email> emails;

  /// Postal addresses.
  final List<Address> addresses;

  /// Organizations.
  final List<Organization> organizations;

  /// Website URLs.
  final List<Website> websites;

  /// Social media profiles.
  final List<SocialMedia> socialMedias;

  /// Events (e.g., birthdays, anniversaries).
  final List<Event> events;

  /// Relationships to other people.
  final List<Relation> relations;

  /// Notes.
  final List<Note> notes;

  /// Android-specific fields.
  final AndroidData? android;

  /// Metadata about fetched properties (used internally, never edit manually).
  final ContactMetadata? metadata;

  const Contact({
    this.id,
    this.displayName,
    this.photo,
    this.name,
    this.phones = const [],
    this.emails = const [],
    this.addresses = const [],
    this.organizations = const [],
    this.websites = const [],
    this.socialMedias = const [],
    this.events = const [],
    this.relations = const [],
    this.notes = const [],
    this.android,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    JsonHelpers.encode(json, 'id', id);
    JsonHelpers.encode(json, 'displayName', displayName);
    JsonHelpers.encode(json, 'photo', photo, (p) => p.toJson());
    JsonHelpers.encode(json, 'name', name, (n) => n.toJson());
    JsonHelpers.encodeList(json, 'phones', phones, (p) => p.toJson());
    JsonHelpers.encodeList(json, 'emails', emails, (e) => e.toJson());
    JsonHelpers.encodeList(json, 'addresses', addresses, (a) => a.toJson());
    JsonHelpers.encodeList(
      json,
      'organizations',
      organizations,
      (o) => o.toJson(),
    );
    JsonHelpers.encodeList(json, 'websites', websites, (w) => w.toJson());
    JsonHelpers.encodeList(
      json,
      'socialMedias',
      socialMedias,
      (s) => s.toJson(),
    );
    JsonHelpers.encodeList(json, 'events', events, (e) => e.toJson());
    JsonHelpers.encodeList(json, 'relations', relations, (r) => r.toJson());
    JsonHelpers.encodeList(json, 'notes', notes, (n) => n.toJson());
    JsonHelpers.encode(json, 'android', android, (a) => a.toJson());
    JsonHelpers.encode(json, 'metadata', metadata, (m) => m.toJson());
    return json;
  }

  static Contact fromJson(Map json) {
    return Contact(
      id: JsonHelpers.decode<String>(json['id']),
      displayName: JsonHelpers.decode<String>(json['displayName']),
      photo: JsonHelpers.decode(json['photo'], Photo.fromJson),
      name: JsonHelpers.decode(json['name'], Name.fromJson),
      phones: JsonHelpers.decodeList(json['phones'] as List?, Phone.fromJson),
      emails: JsonHelpers.decodeList(json['emails'] as List?, Email.fromJson),
      addresses: JsonHelpers.decodeList(
        json['addresses'] as List?,
        Address.fromJson,
      ),
      organizations: JsonHelpers.decodeList(
        json['organizations'] as List?,
        Organization.fromJson,
      ),
      websites: JsonHelpers.decodeList(
        json['websites'] as List?,
        Website.fromJson,
      ),
      socialMedias: JsonHelpers.decodeList(
        json['socialMedias'] as List?,
        SocialMedia.fromJson,
      ),
      events: JsonHelpers.decodeList(json['events'] as List?, Event.fromJson),
      relations: JsonHelpers.decodeList(
        json['relations'] as List?,
        Relation.fromJson,
      ),
      notes: JsonHelpers.decodeList(json['notes'] as List?, Note.fromJson),
      android: AndroidData.fromJson(json['android'] as Map?),
      metadata: JsonHelpers.decode(json['metadata'], ContactMetadata.fromJson),
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('Contact', {
    'id': id,
    'displayName': displayName,
    'photo': photo,
    'name': name,
    'phones': phones.isNotEmpty ? phones : null,
    'emails': emails.isNotEmpty ? emails : null,
    'addresses': addresses.isNotEmpty ? addresses : null,
    'organizations': organizations.isNotEmpty ? organizations : null,
    'websites': websites.isNotEmpty ? websites : null,
    'socialMedias': socialMedias.isNotEmpty ? socialMedias : null,
    'events': events.isNotEmpty ? events : null,
    'relations': relations.isNotEmpty ? relations : null,
    'notes': notes.isNotEmpty ? notes : null,
    'android': android,
    'metadata': metadata,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          id == other.id &&
          displayName == other.displayName &&
          name == other.name &&
          phones == other.phones &&
          emails == other.emails &&
          addresses == other.addresses &&
          organizations == other.organizations &&
          websites == other.websites &&
          socialMedias == other.socialMedias &&
          events == other.events &&
          relations == other.relations &&
          notes == other.notes &&
          android == other.android &&
          photo == other.photo);

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    name,
    phones,
    emails,
    addresses,
    organizations,
    websites,
    socialMedias,
    events,
    relations,
    notes,
    android,
    photo,
  );

  Contact copyWith({
    String? id,
    String? displayName,
    Photo? photo,
    Name? name,
    List<Phone>? phones,
    List<Email>? emails,
    List<Address>? addresses,
    List<Organization>? organizations,
    List<Website>? websites,
    List<SocialMedia>? socialMedias,
    List<Event>? events,
    List<Relation>? relations,
    List<Note>? notes,
    AndroidData? android,
    ContactMetadata? metadata,
    // Set to true to explicitly clear the photo (set it to null)
    bool clearPhoto = false,
  }) {
    // Handle explicit photo clearing: if clearPhoto is true, set photo to null
    // Otherwise, if photo is provided (not null), use it; else keep existing photo
    final Photo? finalPhoto = clearPhoto ? null : (photo ?? this.photo);

    return Contact(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      photo: finalPhoto,
      name: name ?? this.name,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      addresses: addresses ?? this.addresses,
      organizations: organizations ?? this.organizations,
      websites: websites ?? this.websites,
      socialMedias: socialMedias ?? this.socialMedias,
      events: events ?? this.events,
      relations: relations ?? this.relations,
      notes: notes ?? this.notes,
      android: android ?? this.android,
      metadata: metadata ?? this.metadata,
    );
  }
}
