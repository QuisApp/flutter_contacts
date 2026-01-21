import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import '../models/contact/contact.dart';

/// Native system UI API (Android & iOS only).
///
/// Provides access to native system dialogs for viewing, picking, editing, and creating contacts.
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

  /// Shows the native contact viewer dialog.
  Future<void> showViewer(String contactId) async {
    await _invoke<void>('native.showViewer', {'contactId': contactId});
  }

  /// Shows the native contact picker dialog.
  ///
  /// Returns the ID of the selected contact, or null if the user cancelled.
  Future<String?> showPicker() => _invoke<String>('native.showPicker');

  /// Shows the native contact editor dialog.
  ///
  /// Returns the ID of the contact if saved, or null if the user cancelled.
  Future<String?> showEditor(String contactId) =>
      _invoke<String>('native.showEditor', {'contactId': contactId});

  /// Shows the native contact creator dialog.
  ///
  /// [contact] - Optional contact data to pre-fill the form.
  ///
  /// Returns the ID of the newly created contact if created, or null if the user cancelled.
  Future<String?> showCreator({Contact? contact}) => _invoke<String>(
    'native.showCreator',
    {if (contact != null) 'contact': contact.toJson()},
  );
}
