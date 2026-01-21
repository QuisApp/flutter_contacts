/// Configuration API for plugin settings.
class ConfigApi {
  ConfigApi._();

  static final instance = ConfigApi._();

  /// Whether iOS notes are enabled.
  ///
  /// Notes require special entitlements on iOS. Set to true to enable note access.
  /// See [Apple's documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.contacts.notes).
  bool enableIosNotes = false;
}
