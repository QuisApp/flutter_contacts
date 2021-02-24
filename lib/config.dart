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

  /// The vCard version to use when exporting to VCard. V4 is the most current,
  /// but V3 is the most commonly supported.
  VCardVersion vCardVersion = VCardVersion.v3;
}
