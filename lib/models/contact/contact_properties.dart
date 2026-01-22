import 'contact_property.dart';

/// Predefined sets of contact properties for common use cases.
///
/// **Note:** Contact IDs and display names are always fetched regardless of the properties specified.
///
/// Provides convenient static instances for common property combinations:
/// - [none] - No properties (just IDs and display names)
/// - [all] - All properties including thumbnail and full-resolution photos
/// - [allProperties] - All properties without photos
///
/// You can also use Set literals directly in API calls:
/// ```dart
/// FlutterContacts.get(id, properties: {ContactProperty.phone, ContactProperty.email});
/// ```
///
/// Or use predefined sets:
/// ```dart
/// FlutterContacts.get(id, properties: ContactProperties.all);
/// ```
class ContactProperties {
  ContactProperties._();

  /// No properties (just IDs and display names).
  static const Set<ContactProperty> none = <ContactProperty>{};

  /// All properties including both thumbnail and full-resolution photos.
  static const Set<ContactProperty> all = {
    ContactProperty.name,
    ContactProperty.phone,
    ContactProperty.email,
    ContactProperty.address,
    ContactProperty.organization,
    ContactProperty.website,
    ContactProperty.socialMedia,
    ContactProperty.event,
    ContactProperty.relation,
    ContactProperty.note,
    ContactProperty.favorite,
    ContactProperty.ringtone,
    ContactProperty.sendToVoicemail,
    ContactProperty.photoThumbnail,
    ContactProperty.photoFullRes,
    ContactProperty.timestamp,
  };

  /// All properties without any photos (excludes both thumbnail and full-resolution).
  static const Set<ContactProperty> allProperties = {
    ContactProperty.name,
    ContactProperty.phone,
    ContactProperty.email,
    ContactProperty.address,
    ContactProperty.organization,
    ContactProperty.website,
    ContactProperty.socialMedia,
    ContactProperty.event,
    ContactProperty.relation,
    ContactProperty.note,
    ContactProperty.favorite,
    ContactProperty.ringtone,
    ContactProperty.sendToVoicemail,
    ContactProperty.timestamp,
  };
}
