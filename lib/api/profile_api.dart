import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import '../utils/json_helpers.dart';
import '../models/contact/contact.dart';
import '../models/contact/contact_property.dart';
import '../models/contact/contact_properties.dart';
import '../models/contact/contact_property_extension.dart';

/// User Profile / "Me" Card API.
///
/// Fetches the user's own profile:
/// - macOS: Returns the "Me" card.
/// - Android: Returns the device owner's profile.
///
/// Returns null if no profile is set on the device.
/// Not available on iOS.
class ProfileApi {
  const ProfileApi._();

  static const instance = ProfileApi._();
  static const _channel = MethodChannel('flutter_contacts');

  /// Fetches the user's own profile.
  ///
  /// - **macOS**: Returns the "Me" card.
  /// - **Android**: Returns the device owner's profile (ContactsContract.Profile).
  ///
  /// Returns null if no profile is set on the device. On some Android devices (especially
  /// heavily customized OEM skins), the profile may not be available even if set.
  ///
  /// Not available on iOS.
  ///
  /// [properties] - Properties to fetch. Defaults to none (only ID and display name).
  Future<Contact?> get({Set<ContactProperty>? properties}) async {
    if (Platform.isIOS) {
      throw PlatformException(
        code: 'not_available',
        message: 'Profile API is not available on iOS.',
      );
    }
    final props = properties ?? ContactProperties.none;
    final result = await _channel.invokeMethod<Map>('profile.get', {
      'properties': props.toJson(),
    });
    return JsonHelpers.decode(result, Contact.fromJson);
  }
}
