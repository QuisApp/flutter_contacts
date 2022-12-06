import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_contacts/config.dart';
import 'package:flutter_contacts/vcard.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// A contact.
///
/// A contact always has a unique [id] and a [displayName].
///
/// If the high-resolution photo was fetched and the contact has a photo,
/// [photo] will be non-null. If the low-resolution photo was fetched and the
/// contact has a photo, [thumbnail] will be non-null. To access the
/// high-resolution photo if available and the low-resolution thumbnail
/// otherwise, use the getter [photoOrThumbnail].
///
/// If properties were fetched, fields [name], [phones], [emails], etc will be
/// populated (but might be empty).
///
/// If accounts were fetched, [accounts] will also be populated on Android and
/// are not taken into account for contact equality and hash code. It is exposed
/// for three reasons:
///   - most commonly, for debug purposes
///   - [update] needs it to associate properties to the raw ID of the first
///     listed account
///   - if provided, [insert] will use the [Account.type] and [Account.name] of
///     the first listed account
/// On iOS, accounts correspond to containers and there can be only one per
/// contact.
///
/// If groups are fetched, [groups] (called labels on Android) will also be
/// populated.
///
/// In general no fields or nested fields can be null. For example if a phone is
/// present, contact.phones.first.normalizedNumber cannot be null (but might be
/// empty). Every field defaults to empty string for strings, empty list for
/// lists, 0 for integers, false for booleans, and an appropriate value for
/// label enums. The exceptions are as follows:
///   - [thumbnail] and [photo] can be null
///   - [Event.year] can be null for dates with no year
///   - [Event.month] defaults to 1
///   - [Event.day] defaults to 1
///
/// These metadata fields indicate what was fetched:
///   - [thumbnailFetched] if low-resolution thumbnail was fetched
///   - [photoFetched] if high-resolution photo was fetched
///   - [propertiesFetched] if [name], [phones], [emails], etc were fetched
///
/// Notable differences between iOS and Android:
///   - iOS only supports one note
///   - on iOS13+ the app needs to be explicitly approved by Apple (see
///     https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_contacts_notes);
///     if your app is entitled, you can use
///     `FlutterContacts.config.includeNotesOnIos13AndAbove = true` to include
///     them in the properties when fetching/inserting/updating contacts
///   - iOS supports only one [Event] of type [EventLabel.birthday]
///   - iOS doesn't support [Phone.isPrimary] and [Email.isPrimary]
///   - labels vary widely between the two platforms, meaning that, for example,
///     if you save a contact with [PhoneLabel.iPhone] on Android, under the
///     hood it will get saved as [PhoneLabel.custom] and
///     [Phone.customLabel] = 'iPhone'
///   - available fields vary widely between the two platforms, for example
///     [Address.isoCountry] is not available on Android and
///     [Address.neighborhood] is not available on iOS, so if you save a contact
///     with data for [Address.neighborhood] on iOS, that data will be lost
///   - [accounts] represent raw accounts on Android and containers on iOS
class Contact {
  /// The unique identifier of the contact.
  String id;

  /// The contact display name.
  String displayName;

  /// A low-resolution version of the [photo].
  Uint8List? thumbnail;

  /// The full-resolution contact picture.
  Uint8List? photo;

  /// Returns the full-resolution photo if available, the thumbnail otherwise.
  Uint8List? get photoOrThumbnail => photo ?? thumbnail;

  /// Whether the contact is starred (Android only).
  bool isStarred;

  /// Structured name.
  Name name;

  /// Phone numbers.
  List<Phone> phones;

  /// Email addresses.
  List<Email> emails;

  /// Postal addresses.
  List<Address> addresses;

  /// Organizations / jobs.
  List<Organization> organizations;

  /// Websites.
  List<Website> websites;

  /// Social media / instant messaging profiles.
  List<SocialMedia> socialMedias;

  /// Events / birthdays.
  List<Event> events;

  /// Notes.
  List<Note> notes;

  /// Raw accounts (Android only).
  List<Account> accounts;

  /// Groups.
  List<Group> groups;

  /// Whether the low-resolution thumbnail was fetched.
  bool thumbnailFetched = true;

  /// Whether the high-resolution photo was fetched.
  bool photoFetched = true;

  /// Whether this is a unified contact (and not a raw contact).
  bool isUnified = true;

  /// Whether properties (name, phones, emails, etc).
  bool propertiesFetched = true;

  Contact({
    this.id = '',
    this.displayName = '',
    this.thumbnail,
    this.photo,
    this.isStarred = false,
    Name? name,
    List<Phone>? phones,
    List<Email>? emails,
    List<Address>? addresses,
    List<Organization>? organizations,
    List<Website>? websites,
    List<SocialMedia>? socialMedias,
    List<Event>? events,
    List<Note>? notes,
    List<Account>? accounts,
    List<Group>? groups,
  })  : name = name ?? Name(),
        phones = phones ?? <Phone>[],
        emails = emails ?? <Email>[],
        addresses = addresses ?? <Address>[],
        organizations = organizations ?? <Organization>[],
        websites = websites ?? <Website>[],
        socialMedias = socialMedias ?? <SocialMedia>[],
        events = events ?? <Event>[],
        notes = notes ?? <Note>[],
        accounts = accounts ?? <Account>[],
        groups = groups ?? <Group>[];

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: (json['id'] as String?) ?? '',
        displayName: (json['displayName'] as String?) ?? '',
        thumbnail: json['thumbnail'] as Uint8List?,
        photo: json['photo'] as Uint8List?,
        isStarred: (json['isStarred'] as bool?) ?? false,
        name: Name.fromJson(Map<String, dynamic>.from(json['name'] ?? {})),
        phones: ((json['phones'] as List?) ?? [])
            .map((x) => Phone.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
        emails: ((json['emails'] as List?) ?? [])
            .map((x) => Email.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
        addresses: ((json['addresses'] as List?) ?? [])
            .map((x) => Address.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
        organizations: ((json['organizations'] as List?) ?? [])
            .map((x) => Organization.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
        websites: ((json['websites'] as List?) ?? [])
            .map((x) => Website.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
        socialMedias: ((json['socialMedias'] as List?) ?? [])
            .map((x) => SocialMedia.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
        events: ((json['events'] as List?) ?? [])
            .map((x) => Event.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
        notes: ((json['notes'] as List?) ?? [])
            .map((x) => Note.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
        accounts: ((json['accounts'] as List?) ?? [])
            .map((x) => Account.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
        groups: ((json['groups'] as List?) ?? [])
            .map((x) => Group.fromJson(Map<String, dynamic>.from(x)))
            .toList(),
      );

  Map<String, dynamic> toJson({
    bool withThumbnail = true,
    bool withPhoto = true,
  }) =>
      Map<String, dynamic>.from({
        'id': id,
        'displayName': displayName,
        'thumbnail': withThumbnail ? thumbnail : null,
        'photo': withPhoto ? photo : null,
        'isStarred': isStarred,
        'name': name.toJson(),
        'phones': phones.map((x) => x.toJson()).toList(),
        'emails': emails.map((x) => x.toJson()).toList(),
        'addresses': addresses.map((x) => x.toJson()).toList(),
        'organizations': organizations.map((x) => x.toJson()).toList(),
        'websites': websites.map((x) => x.toJson()).toList(),
        'socialMedias': socialMedias.map((x) => x.toJson()).toList(),
        'events': events.map((x) => x.toJson()).toList(),
        'notes': notes.map((x) => x.toJson()).toList(),
        'accounts': accounts.map((x) => x.toJson()).toList(),
        'groups': groups.map((x) => x.toJson()).toList(),
      });

  @override
  int get hashCode =>
      id.hashCode ^
      displayName.hashCode ^
      thumbnail.hashCode ^
      photo.hashCode ^
      isStarred.hashCode ^
      name.hashCode ^
      _listHashCode(phones) ^
      _listHashCode(emails) ^
      _listHashCode(addresses) ^
      _listHashCode(organizations) ^
      _listHashCode(websites) ^
      _listHashCode(socialMedias) ^
      _listHashCode(events) ^
      _listHashCode(notes);

  @override
  bool operator ==(Object o) =>
      o is Contact &&
      o.id == id &&
      o.displayName == displayName &&
      o.thumbnail == thumbnail &&
      o.photo == photo &&
      o.isStarred == isStarred &&
      o.name == name &&
      _listEqual(o.phones, phones) &&
      _listEqual(o.emails, emails) &&
      _listEqual(o.addresses, addresses) &&
      _listEqual(o.organizations, organizations) &&
      _listEqual(o.websites, websites) &&
      _listEqual(o.socialMedias, socialMedias) &&
      _listEqual(o.events, events) &&
      _listEqual(o.notes, notes);

  @override
  String toString() =>
      'Contact(id=$id, displayName=$displayName, thumbnail=$thumbnail, '
      'photo=$photo, isStarred=$isStarred, name=$name, phones=$phones, '
      'emails=$emails, addresses=$addresses, organizations=$organizations, '
      'websites=$websites, socialMedias=$socialMedias, events=$events, '
      'notes=$notes, accounts=$accounts, groups=$groups)';

  /// Inserts the contact into the database.
  Future<Contact> insert() => FlutterContacts.insertContact(this);

  /// Updates the contact in the database.
  Future<Contact> update({bool withGroups = false}) =>
      FlutterContacts.updateContact(this, withGroups: withGroups);

  /// Deletes the contact from the database.
  Future<void> delete() => FlutterContacts.deleteContact(this);

  /// Exports to vCard format.
  ///
  /// By default we use vCard format v3 (https://tools.ietf.org/html/rfc2426)
  /// which is the most widely used, but it's possible to use the more recent
  /// vCard format v4 (https://tools.ietf.org/html/rfc6350) using:
  /// ```dart
  /// FlutterContacts.config.vCardVersion = VCardVersion.v4;
  /// ```
  ///
  /// The optional [productId] specifies a product identifier, such as
  /// "-//Apple Inc.//Mac OS X 10.15.7//EN"
  String toVCard({
    bool withPhoto = true,
    String? productId,
    bool includeDate = false,
  }) {
    // BEGIN (V3): https://tools.ietf.org/html/rfc2426#section-2.1.1
    // VERSION (V3): https://tools.ietf.org/html/rfc2426#section-3.6.9
    // PRODID (V3): https://tools.ietf.org/html/rfc2426#section-3.6.3
    // REV (V3): https://tools.ietf.org/html/rfc2426#section-3.6.4
    // FN (V3): https://tools.ietf.org/html/rfc2426#section-3.1.1
    // PHOTO (V3): https://tools.ietf.org/html/rfc2426#section-3.1.4
    // END (V3): https://tools.ietf.org/html/rfc2426#section-2.1.1
    // BEGIN (V4): https://tools.ietf.org/html/rfc6350#section-6.1.1
    // VERSION (V4): https://tools.ietf.org/html/rfc6350#section-6.7.9
    // PRODID (V4): https://tools.ietf.org/html/rfc6350#section-6.7.3
    // REV (V4): https://tools.ietf.org/html/rfc6350#section-6.7.4
    // FN (V4): https://tools.ietf.org/html/rfc6350#section-6.2.1
    // PHOTO (V4): https://tools.ietf.org/html/rfc6350#section-6.2.4
    // END (V4): https://tools.ietf.org/html/rfc6350#section-6.1.2
    final v4 = FlutterContacts.config.vCardVersion == VCardVersion.v4;
    var lines = [
      'BEGIN:VCARD',
      v4 ? 'VERSION:4.0' : 'VERSION:3.0',
    ];
    if (productId != null) {
      lines.add('PRODID:$productId');
    }
    if (includeDate) {
      lines.add('REV:${DateTime.now().toIso8601String()}');
    }
    if (displayName.isNotEmpty) {
      lines.add('FN:${vCardEncode(displayName)}');
    }
    if (withPhoto && photoOrThumbnail != null) {
      final encoding = vCardEncode(base64.encode(photoOrThumbnail!));
      final prefix =
          v4 ? 'PHOTO:data:image/jpeg;base64,' : 'PHOTO;ENCODING=b;TYPE=JPEG:';
      lines.add(prefix + encoding);
    }
    lines.addAll([
      name.toVCard(),
      phones.map((x) => x.toVCard()).expand((x) => x),
      emails.map((x) => x.toVCard()).expand((x) => x),
      addresses.map((x) => x.toVCard()).expand((x) => x),
      organizations.map((x) => x.toVCard()).expand((x) => x),
      websites.map((x) => x.toVCard()).expand((x) => x),
      socialMedias.map((x) => x.toVCard()).expand((x) => x),
      events.map((x) => x.toVCard()).expand((x) => x),
      notes.map((x) => x.toVCard()).expand((x) => x),
    ].expand((x) => x));
    lines.add('END:VCARD');
    return lines.join('\n');
  }

  factory Contact.fromVCard(String vCard) {
    var c = Contact();
    VCardParser().parse(vCard, c);
    return c;
  }

  /// Deduplicates properties.
  ///
  /// Some properties sometimes appear duplicated because of third-party apps.
  /// For phones we compare them using the normalized number phone number if
  /// availalbe, falling back to the raw phone number. For emails we use the
  /// email address. By default we use the property hash code.
  void deduplicateProperties() {
    phones = _depuplicateProperty(
        phones,
        (x) => (x.normalizedNumber.isNotEmpty ? x.normalizedNumber : x.number)
            .hashCode);
    emails = _depuplicateProperty(emails, (x) => x.address.hashCode);
    addresses = _depuplicateProperty(addresses);
    organizations = _depuplicateProperty(organizations);
    websites = _depuplicateProperty(websites);
    socialMedias = _depuplicateProperty(socialMedias);
    events = _depuplicateProperty(events);
    notes = _depuplicateProperty(notes);
  }

  static List<T> _depuplicateProperty<T>(List<T> list,
      [int Function(T)? hashFn]) {
    hashFn ??= (T x) => x.hashCode;
    var deduplicated = <T>[];
    var seen = Set<int>();
    for (final o in list) {
      final h = hashFn(o);
      if (!seen.contains(h)) {
        deduplicated.add(o);
        seen.add(h);
      }
    }
    return deduplicated;
  }

  int _listHashCode(List<dynamic> elements) => elements.isEmpty
      ? 0
      : elements.map((x) => x.hashCode).reduce((x, y) => x ^ y);

  bool _listEqual(List<dynamic> aa, List<dynamic> bb) =>
      aa.length == bb.length &&
      Iterable.generate(aa.length, (i) => i).every((i) => aa[i] == bb[i]);
}
