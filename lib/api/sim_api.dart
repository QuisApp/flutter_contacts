import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import '../utils/json_helpers.dart';
import '../models/contact/contact.dart';

/// SIM card storage API (Android only).
class SimApi {
  const SimApi._();

  static const instance = SimApi._();
  static const _channel = MethodChannel('flutter_contacts');

  /// Fetches contacts stored on the SIM card.
  ///
  /// Android only. Throws [PlatformException] on other platforms.
  Future<List<Contact>> get() async {
    if (!Platform.isAndroid) {
      throw PlatformException(
        code: 'not_available',
        message: 'SIM API is not available on this platform.',
      );
    }
    final result = await _channel.invokeMethod<List>('sim.get');
    return JsonHelpers.decodeList(result, Contact.fromJson);
  }
}
