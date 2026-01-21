import 'package:flutter/services.dart';
import '../utils/json_helpers.dart';
import '../models/accounts/account.dart';

/// Account management API.
///
/// Handles operations related to contact accounts (e.g., Google, Exchange, local).
class AccountsApi {
  const AccountsApi._();

  static const instance = AccountsApi._();
  static const _channel = MethodChannel('flutter_contacts');

  /// Gets all available accounts.
  Future<List<Account>> getAll() async => JsonHelpers.decodeList(
    await _channel.invokeMethod<List>('accounts.getAll'),
    Account.fromJson,
  );

  /// Gets the default account for storing contacts.
  Future<Account?> getDefault() async => JsonHelpers.decode(
    await _channel.invokeMethod<Map>('accounts.getDefault'),
    Account.fromJson,
  );

  /// Shows the system account picker to select a default account.
  ///
  /// Android only. Throws [PlatformException] on other platforms.
  Future<void> showDefaultPicker() =>
      _channel.invokeMethod('accounts.showDefaultPicker');
}
