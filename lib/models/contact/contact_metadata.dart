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

  const ContactMetadata({required this.properties, required this.accounts});

  Map<String, dynamic> toJson() {
    return {
      'properties': properties.toJson(),
      'accounts': accounts.map((e) => e.toJson()).toList(),
    };
  }

  static ContactMetadata fromJson(Map json) {
    return ContactMetadata(
      properties: (json['properties'] as List).toProperties(),
      accounts: JsonHelpers.decodeList(
        json['accounts'] as List?,
        Account.fromJson,
      ),
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('ContactMetadata', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactMetadata &&
          properties == other.properties &&
          accounts == other.accounts);

  @override
  int get hashCode => Object.hash(properties, accounts);

  ContactMetadata copyWith({
    Set<ContactProperty>? properties,
    List<Account>? accounts,
  }) => ContactMetadata(
    properties: properties ?? this.properties,
    accounts: accounts ?? this.accounts,
  );
}
