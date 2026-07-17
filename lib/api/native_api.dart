import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import '../models/contact/contact.dart';
import '../models/contact/contact_properties.dart';
import '../models/contact/contact_property.dart';
import '../models/contact/contact_property_extension.dart';
import '../utils/json_helpers.dart';
import 'config_api.dart';

/// Native system UI for picking, viewing, editing, and creating contacts
/// (Android & iOS only).
///
/// Most calls avoid the contacts permission by handing off to the system UI.
/// See each method for exceptions.
class NativeApi {
  const NativeApi._();

  static const instance = NativeApi._();
  static const _channel = MethodChannel('flutter_contacts');

  static void _checkPlatform() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw PlatformException(
        code: 'not_available',
        message: 'Native API is only available on Android and iOS.',
      );
    }
  }

  static Future<T?> _invoke<T>(String method, [Map<String, dynamic>? args]) {
    _checkPlatform();
    return _channel.invokeMethod<T>(method, args);
  }

  /// Shows the native contact viewer for [contactId].
  ///
  /// Permissionless on Android. On iOS requires `NSContactsUsageDescription`
  /// in `Info.plist` and a granted read permission.
  Future<void> showViewer(String contactId) async {
    await _invoke<void>('native.showViewer', {'contactId': contactId});
  }

  /// Shows the native contact picker dialog. Returns the picked contact, or
  /// null if the user cancelled.
  ///
  /// The picker itself is permissionless on both platforms. Calling without
  /// [properties] always returns a [Contact] populated with `id` and
  /// `displayName`.
  ///
  /// Passing non-empty [properties] asks for additional fields:
  /// - iOS: always works.
  /// - Android: requires `READ_CONTACTS`; throws a [PlatformException] otherwise.
  Future<Contact?> showPicker({Set<ContactProperty>? properties}) async {
    final result = await _invoke<Map>('native.showPicker', {
      'properties': (properties ?? ContactProperties.none).toJson(),
      if (Platform.isIOS) 'enableIosNotes': ConfigApi.instance.enableIosNotes,
    });
    return JsonHelpers.decode(result, Contact.fromJson);
  }

  /// Shows the native contact editor for [contactId]. Returns the saved
  /// contact's ID, or null if the user cancelled.
  ///
  /// Same permissions as [showViewer].
  Future<String?> showEditor(String contactId) =>
      _invoke<String>('native.showEditor', {'contactId': contactId});

  /// Shows the native contact creator, optionally pre-filled with [contact].
  /// Returns the new contact's ID, or null if the user cancelled.
  ///
  /// Permissionless on both platforms. On Android, the system editor doesn't
  /// display pre-filled photos; if the app holds `WRITE_CONTACTS`, the photo is
  /// applied to the contact after creation (unless the user picked one in the
  /// editor).
  Future<String?> showCreator({Contact? contact}) => _invoke<String>(
    'native.showCreator',
    {if (contact != null) 'contact': contact.toJson()},
  );
}
