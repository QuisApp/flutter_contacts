/// vCard version.
enum VCardVersion {
  /// vCard version 3.0.
  ///
  /// This is described in https://tools.ietf.org/html/rfc2426 from 1998 and is
  /// the most commonly used format.
  v3,

  /// vCard version 4.0.
  ///
  /// This is described in https://tools.ietf.org/html/rfc6350 from 2011.
  v4,

  // V2.1 (described in https://tools.ietf.org/html/rfc2425 from 1998) is not
  // yet supported.
}

class FlutterContactsConfig {
  /// Whether to include notes in the properties on iOS13 and above.
  ///
  /// On iOS13+ the app needs to be explicitly approved by Apple (see
  /// https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_contacts_notes)
  /// and the app crashes when trying to read or write notes without
  /// entitlement. If your app got entitled, you can set this to true to access
  /// notes.
  bool includeNotesOnIos13AndAbove = false;

  /// Non-visible contacts on Android are contacts that are not part of a group,
  /// and are excluded by default.
  ///
  /// See https://stackoverflow.com/questions/28665587/what-does-contactscontract-contacts-in-visible-group-mean-in-android
  bool includeNonVisibleOnAndroid = false;

  /// Return unified contacts instead of raw contacts.
  ///
  /// On both iOS and Android there is a concept of raw and unified contacts. A
  /// single person might have two raw contacts (for example from Gmail and from
  /// iCloud) but will be merged into a single view called a unified contact. In
  /// a contact app you typically want unified contacts, so this is what's
  /// returned by default. When this is false, raw contacts are returned
  /// instead.
  bool returnUnifiedContacts = true;

  /// The vCard version to use when exporting to VCard. V4 is the most current,
  /// but V3 is the most commonly supported.
  VCardVersion vCardVersion = VCardVersion.v3;
}
