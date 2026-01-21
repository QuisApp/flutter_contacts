/// Enumeration of contact properties that can be fetched.
///
/// Property type for specifying which contact data to fetch or update.
///
/// Used in [FlutterContacts.get] and [FlutterContacts.getAll] to specify which
/// properties to fetch. Also used internally by [FlutterContacts.update] and
/// [FlutterContacts.updateAll] to determine which properties to update/delete
/// and which to leave intact.
///
/// Properties not supported on a platform (e.g., [ContactProperty.favorite] on iOS)
/// are ignored if included in the property list.
///
/// [ContactProperty.debugData] returns the entire database content for that contact
/// for debugging purposes.
///
/// See [ContactProperties] for pre-defined property sets.
///
/// Example usage:
/// ```dart
/// // Fetch all properties with thumbnail photo
/// final contact = await FlutterContacts.get(
///   id,
///   properties: {...ContactProperties.allProperties, ContactProperty.photoThumbnail},
/// );
///
/// // Fetch only name and phone
/// final contacts = await FlutterContacts.getAll(
///   properties: {ContactProperty.name, ContactProperty.phone},
/// );
/// ```
///
/// Note: The contact's ID and display name are always fetched.
///
/// | Property         | Android | iOS |
/// |------------------|:-------:|:---:|
/// | name             | ✔       | ✔   |
/// | phone            | ✔       | ✔   |
/// | email            | ✔       | ✔   |
/// | address          | ✔       | ✔   |
/// | organization     | ✔       | ✔   |
/// | website          | ✔       | ✔   |
/// | socialMedia      | ✔       | ✔   |
/// | event            | ✔       | ✔   |
/// | relation         | ✔       | ✔   |
/// | note             | ✔       | ✔   |
/// | favorite         | ✔       | ⨯   |
/// | ringtone         | ✔       | ⨯   |
/// | sendToVoicemail  | ✔       | ⨯   |
/// | photoThumbnail   | ✔       | ✔   |
/// | photoFullRes     | ✔       | ✔   |
/// | debugData        | ✔       | ⨯   |
enum ContactProperty {
  /// Structured name property.
  name,

  /// Phone numbers.
  phone,

  /// Email addresses.
  email,

  /// Postal addresses.
  address,

  /// Organization information.
  organization,

  /// Website URLs.
  website,

  /// Social media profiles.
  socialMedia,

  /// Events (e.g., birthdays, anniversaries).
  event,

  /// Relationships to other people.
  relation,

  /// Notes. On iOS, it requires `FlutterContacts.config.enableIosNotes = true`.
  /// See [Apple's documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.contacts.notes).
  note,

  /// Whether contact is starred/favorited (Android only).
  favorite,

  /// URI for custom ringtone (Android only).
  ringtone,

  /// Whether to send calls to voicemail (Android only).
  sendToVoicemail,

  /// Contact photo thumbnail.
  photoThumbnail,

  /// Contact photo full resolution.
  photoFullRes,

  /// All data mimetypes for debugging (Android only).
  debugData,
}
