import 'package:flutter/services.dart';
import '../utils/json_helpers.dart';
import '../models/groups/group.dart';
import '../models/accounts/account.dart';

/// Group management API.
///
/// Handles operations for contact groups (e.g., "Family", "Work", "Friends").
class GroupsApi {
  const GroupsApi._();

  static const instance = GroupsApi._();
  static const _channel = MethodChannel('flutter_contacts');

  /// Gets a single group by ID.
  ///
  /// [groupId] - The ID of the group to fetch.
  /// [withContactCount] - Whether to include the number of contacts in the group.
  Future<Group?> get(String groupId, {bool withContactCount = false}) async {
    final result = await _channel.invokeMethod<Map>('groups.get', {
      'groupId': groupId,
      'withContactCount': withContactCount,
    });
    return JsonHelpers.decode(result, Group.fromJson);
  }

  /// Gets all contact groups.
  ///
  /// [accounts] - Optional list of accounts filter. If null, returns groups from all accounts.
  /// [withContactCount] - Whether to include the number of contacts in each group.
  Future<List<Group>> getAll({
    List<Account>? accounts,
    bool withContactCount = false,
  }) async {
    final result = await _channel.invokeMethod<List>('groups.getAll', {
      if (accounts != null)
        'accounts': accounts.map((e) => e.toJson()).toList(),
      'withContactCount': withContactCount,
    });
    return JsonHelpers.decodeList(result, Group.fromJson);
  }

  /// Creates a new contact group.
  ///
  /// [account] - Optional account. If null, uses the default account.
  ///
  /// Returns the created group with its assigned ID.
  Future<Group> create(String name, {Account? account}) async {
    final result = await _channel.invokeMethod<Map>('groups.create', {
      'name': name,
      if (account != null) 'account': account.toJson(),
    });
    return JsonHelpers.decode(result, Group.fromJson)!;
  }

  /// Updates a group.
  ///
  /// Group must include the ID and new name.
  Future<void> update(Group group) async {
    await _channel.invokeMethod('groups.update', {
      'groupId': group.id,
      'name': group.name,
    });
  }

  /// Deletes a group.
  ///
  /// Does not delete the contacts in the group, only removes the group association.
  Future<void> delete(String groupId) async {
    await _channel.invokeMethod('groups.delete', {'groupId': groupId});
  }

  /// Adds contacts to a group.
  Future<void> addContacts({
    required String groupId,
    required List<String> contactIds,
  }) async {
    await _channel.invokeMethod('groups.addContacts', {
      'groupId': groupId,
      'contactIds': contactIds,
    });
  }

  /// Removes contacts from a group.
  Future<void> removeContacts({
    required String groupId,
    required List<String> contactIds,
  }) async {
    await _channel.invokeMethod('groups.removeContacts', {
      'groupId': groupId,
      'contactIds': contactIds,
    });
  }

  /// Gets all groups that contain the specified contact.
  Future<List<Group>> getOf(String contactId) async {
    final result = await _channel.invokeMethod<List>('groups.getOf', {
      'contactId': contactId,
    });
    return JsonHelpers.decodeList(result, Group.fromJson);
  }
}
