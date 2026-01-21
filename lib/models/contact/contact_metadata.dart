import '../../utils/json_helpers.dart';
import 'contact_property.dart';
import 'contact_property_extension.dart';
import '../accounts/account.dart';

/// Metadata about a contact, tracking which properties were fetched and account information.
///
/// Automatically populated when fetching contacts via [FlutterContacts.get] or [FlutterContacts.getAll].
/// Required when editing contacts to identify which properties to update.
///
/// Do not edit or create manually - it's managed automatically by the plugin.
class ContactMetadata {
  /// Properties that were fetched for this contact.
  final Set<ContactProperty> properties;

  /// Accounts this contact belongs to.
  final List<Account> accounts;

  /// Last update timestamp in milliseconds since epoch (Android only).
  final int? lastUpdatedTimestamp;

  const ContactMetadata({
    required this.properties,
    required this.accounts,
    this.lastUpdatedTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'properties': properties.toJson(),
      'accounts': accounts.map((e) => e.toJson()).toList(),
      if (lastUpdatedTimestamp != null)
        'lastUpdatedTimestamp': lastUpdatedTimestamp,
    };
  }

  static ContactMetadata fromJson(Map json) {
    return ContactMetadata(
      properties: (json['properties'] as List).toProperties(),
      accounts: JsonHelpers.decodeList(
        json['accounts'] as List?,
        Account.fromJson,
      ),
      lastUpdatedTimestamp: json['lastUpdatedTimestamp'] as int?,
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('ContactMetadata', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactMetadata &&
          properties == other.properties &&
          accounts == other.accounts &&
          lastUpdatedTimestamp == other.lastUpdatedTimestamp);

  @override
  int get hashCode => Object.hash(properties, accounts, lastUpdatedTimestamp);

  ContactMetadata copyWith({
    Set<ContactProperty>? properties,
    List<Account>? accounts,
    int? lastUpdatedTimestamp,
  }) => ContactMetadata(
    properties: properties ?? this.properties,
    accounts: accounts ?? this.accounts,
    lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
  );
}
