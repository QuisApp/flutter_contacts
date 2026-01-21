import '../accounts/account.dart';

/// A contact group.
///
/// Groups allow users to organize contacts into collections. On Android,
/// groups are called "labels" but we use "group" terminology for consistency
/// across platforms.
///
/// Groups always belong to an account. On Android, [account] being null means
/// the group belongs to the local device.
class Group {
  /// The stable identifier for this group.
  final String? id;

  /// The display name of the group.
  final String name;

  /// The account this group belongs to.
  ///
  /// On Android, null means the group belongs to the local device.
  /// On iOS, groups always belong to a container/account.
  final Account? account;

  /// The number of contacts in this group.
  ///
  /// Null unless explicitly requested (e.g., via `withContactCount: true`)
  /// since computing the count requires another query.
  final int? contactCount;

  const Group({this.id, required this.name, this.account, this.contactCount});

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (account != null) 'account': account!.toJson(),
      if (contactCount != null) 'contactCount': contactCount,
    };
  }

  static Group fromJson(Map json) {
    return Group(
      id: json['id'] as String?,
      name: json['name'] as String,
      account: json['account'] != null
          ? Account.fromJson(json['account'] as Map)
          : null,
      contactCount: json['contactCount'] as int?,
    );
  }
}
