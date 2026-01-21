/// Detailed permission status for contacts access.
///
/// Permission states:
/// - Yes: [granted], [limited]
/// - No but can ask again: [denied], [notDetermined]
/// - No, don't ask again: [restricted], [permanentlyDenied]
///
/// Note: Denying permission once leads to [permanentlyDenied] on iOS but [denied] on Android.
/// Denying twice leads to [permanentlyDenied] on Android.
enum PermissionStatus {
  /// Permission is fully granted.
  granted,

  /// Permission is granted with limited access (iOS 18+ only).
  ///
  /// On iOS, this means the user has selected specific contacts to share.
  limited,

  /// Permission was denied by the user, but can still be requested again.
  denied,

  /// Permission was permanently denied (Android: "Don't ask again").
  ///
  /// User must grant permission through system settings.
  permanentlyDenied,

  /// Permission is restricted by system policy (e.g., parental controls).
  restricted,

  /// Permission has not been requested yet.
  notDetermined,
}
