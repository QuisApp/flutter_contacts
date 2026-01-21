import 'dart:io';
import 'package:flutter/services.dart';
import '../utils/json_helpers.dart';
import '../models/properties/phone.dart';

/// Android number blocking API.
///
/// Only available when the app is the default dialer or has system/carrier privileges.
/// Check availability with [isAvailable] before use. All other methods throw [PlatformException]
/// with code "security_error" if unavailable.
///
/// Phone numbers are matched against both original and E.164 formats automatically.
/// E.164 is the international normalized format (e.g., "+15551234567" for "(555) 123-4567").
class BlockedNumbersApi {
  const BlockedNumbersApi._();

  static const instance = BlockedNumbersApi._();
  static const _channel = MethodChannel('flutter_contacts');

  static void _checkPlatform() {
    if (!Platform.isAndroid) {
      throw PlatformException(
        code: 'not_available',
        message: 'Blocked numbers API is only available on Android.',
      );
    }
  }

  static Future<T?> _invoke<T>(String method, [Map<String, dynamic>? args]) {
    _checkPlatform();
    return _channel.invokeMethod<T>(method, args);
  }

  /// Checks if the blocking API is available.
  /// Never throws - always returns true or false.
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>(
        'blockedNumbers.isAvailable',
      );
      return result ?? false;
    } catch (e) {
      // If checking availability throws, return false instead of propagating the error
      return false;
    }
  }

  /// Checks if a phone number is blocked.
  ///
  /// Throws [PlatformException] with code "security_error" if API unavailable.
  Future<bool> isBlocked(String number) async {
    final result = await _invoke<bool>('blockedNumbers.isBlocked', {
      'number': number,
    });
    return result ?? false;
  }

  /// Gets all blocked phone numbers.
  ///
  /// Throws [PlatformException] with code "security_error" if API unavailable.
  Future<List<Phone>> getAll() async {
    final result = await _invoke<List>('blockedNumbers.getAll');
    return JsonHelpers.decodeList(result, Phone.fromJson);
  }

  /// Blocks a phone number.
  ///
  /// E.164 format is auto-generated from the number. Throws [PlatformException] with
  /// code "security_error" if API unavailable.
  Future<void> block(String number) async {
    await blockAll([number]);
  }

  /// Blocks multiple phone numbers.
  ///
  /// E.164 format is auto-generated for each number. Throws [PlatformException] with
  /// code "security_error" if API unavailable.
  Future<void> blockAll(List<String> numbers) async {
    await _invoke<void>('blockedNumbers.blockAll', {'numbers': numbers});
  }

  /// Unblocks a phone number.
  ///
  /// Throws [PlatformException] with code "security_error" if API unavailable.
  Future<void> unblock(String number) async {
    await unblockAll([number]);
  }

  /// Unblocks multiple phone numbers.
  ///
  /// Throws [PlatformException] with code "security_error" if API unavailable.
  Future<void> unblockAll(List<String> numbers) async {
    await _invoke<void>('blockedNumbers.unblockAll', {'numbers': numbers});
  }

  /// Opens the Android default app settings where the user can set the default phone app.
  Future<void> openDefaultAppSettings() async {
    await _invoke<void>('blockedNumbers.openDefaultAppSettings');
  }
}
