import 'dart:io';
import 'package:flutter/services.dart';
import '../utils/json_helpers.dart';
import '../models/ringtones/ringtone_type.dart';
import '../models/ringtones/ringtone.dart';

/// Ringtones management API (Android only).
///
/// Provides access to system ringtones, notifications, and alarms.
/// Throws [PlatformException] on non-Android platforms.
class RingtonesApi {
  const RingtonesApi._();

  static const instance = RingtonesApi._();
  static const _channel = MethodChannel('flutter_contacts');

  static void _checkPlatform() {
    if (!Platform.isAndroid) {
      throw PlatformException(
        code: 'not_available',
        message: 'Ringtones API is only available on Android.',
      );
    }
  }

  static Future<T?> _invoke<T>(String method, [Map<String, dynamic>? args]) {
    _checkPlatform();
    return _channel.invokeMethod<T>(method, args);
  }

  /// Gets detailed information about a ringtone.
  ///
  /// [withMetadata] - Whether to include metadata.
  Future<Ringtone?> get(String ringtoneUri, {bool withMetadata = true}) async =>
      JsonHelpers.decode(
        await _invoke<Map>('ringtones.get', {
          'ringtoneUri': ringtoneUri,
          'withMetadata': withMetadata,
        }),
        Ringtone.fromJson,
      );

  /// Gets all available ringtones.
  ///
  /// [type] - Optional filter by ringtone type. If null, returns all types.
  /// [withMetadata] - Whether to include metadata.
  Future<List<Ringtone>> getAll({
    RingtoneType? type,
    bool withMetadata = false,
  }) async => JsonHelpers.decodeList(
    await _invoke<List>('ringtones.getAll', {
      if (type != null) 'type': type.name,
      'withMetadata': withMetadata,
    }),
    Ringtone.fromJson,
  );

  /// Opens the system ringtone picker and returns the selected ringtone URI.
  ///
  /// [existingUri] - Optional URI to pre-select in the picker.
  ///
  /// Returns null if the user cancels.
  Future<String?> pick(RingtoneType type, {String? existingUri}) =>
      _invoke<String>('ringtones.pick', {
        'type': type.name,
        if (existingUri != null) 'existingUri': existingUri,
      });

  /// Gets the default ringtone URI for the given type.
  Future<String?> getDefaultUri(RingtoneType type) =>
      _invoke<String>('ringtones.getDefaultUri', {'type': type.name});

  /// Sets the default ringtone URI for the given type.
  ///
  /// [ringtoneUri] - Ringtone URI to set as default, or null to clear.
  Future<void> setDefaultUri(RingtoneType type, String? ringtoneUri) async {
    await _invoke<void>('ringtones.setDefaultUri', {
      'type': type.name,
      'ringtoneUri': ringtoneUri,
    });
  }

  /// Plays the ringtone at the given URI.
  Future<void> play(String ringtoneUri) async {
    await _invoke<void>('ringtones.play', {'ringtoneUri': ringtoneUri});
  }

  /// Stops the currently playing ringtone.
  Future<void> stop() async {
    await _invoke<void>('ringtones.stop');
  }
}
