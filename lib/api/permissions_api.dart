import 'package:flutter/services.dart';
import '../utils/json_helpers.dart';
import '../models/permissions/permission_type.dart';
import '../models/permissions/permission_status.dart';

/// Permissions management API.
///
/// Handles checking and requesting contact-related permissions.
class PermissionsApi {
  const PermissionsApi._();

  static const instance = PermissionsApi._();
  static const _channel = MethodChannel('flutter_contacts');

  /// Checks if permission is granted or limited.
  Future<bool> has(PermissionType type) async => switch (await check(type)) {
    PermissionStatus.granted || PermissionStatus.limited => true,
    _ => false,
  };

  /// Checks the current permission status.
  ///
  /// Returns the current [PermissionStatus] without showing any dialogs.
  Future<PermissionStatus> check(PermissionType type) async =>
      JsonHelpers.decodeEnum(
        await _channel.invokeMethod<String>('permissions.check', {
          'type': type.name,
        }),
        PermissionStatus.values,
        PermissionStatus.notDetermined,
      );

  /// Requests permission for the given type.
  ///
  /// If permission is already granted or limited, silently returns the corresponding
  /// [PermissionStatus] without showing a dialog. Otherwise, shows the system permission dialog.
  ///
  /// Throws [PlatformException] with code "CONCURRENT_REQUEST" if another permission
  /// request is already in progress.
  Future<PermissionStatus> request(PermissionType type) async =>
      JsonHelpers.decodeEnum(
        await _channel.invokeMethod<String>('permissions.request', {
          'type': type.name,
        }),
        PermissionStatus.values,
        PermissionStatus.denied,
      );

  /// Opens the app settings page.
  ///
  /// Use this when permission is [PermissionStatus.permanentlyDenied] or
  /// [PermissionStatus.restricted], as the user must grant permission through
  /// system settings.
  Future<void> openSettings() =>
      _channel.invokeMethod('permissions.openSettings');
}
