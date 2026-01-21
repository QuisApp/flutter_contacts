import 'api/config_api.dart';
import 'api/crud_api.dart';
import 'api/accounts_api.dart';
import 'api/groups_api.dart';
import 'api/permissions_api.dart';
import 'api/native_api.dart';
import 'api/vcard_api.dart';
import 'api/blocked_numbers_api.dart';
import 'api/ringtones_api.dart';
import 'api/listener_api.dart';
import 'api/sim_api.dart';
import 'api/profile_api.dart';
import 'models/contact/contact.dart';
import 'models/accounts/account.dart';
import 'models/contact/contact_property.dart';
import 'models/contact/contact_filter.dart';
import 'models/contact/contact_change.dart';

// Models
export 'models/contact/contact.dart';
export 'models/contact/contact_property.dart';
export 'models/contact/contact_filter.dart';
export 'models/contact/contact_change.dart';
export 'models/accounts/account.dart';
export 'models/groups/group.dart';
export 'models/permissions/permission_status.dart';
export 'models/permissions/permission_type.dart';
export 'models/properties/name.dart';
export 'models/properties/phone.dart';
export 'models/properties/email.dart';
export 'models/properties/address.dart';
export 'models/properties/organization.dart';
export 'models/properties/website.dart';
export 'models/properties/social_media.dart';
export 'models/properties/event.dart';
export 'models/properties/relation.dart';
export 'models/properties/note.dart';
export 'models/properties/photo.dart';
export 'models/labels/label.dart';
export 'models/labels/phone_label.dart';
export 'models/labels/email_label.dart';
export 'models/labels/address_label.dart';
export 'models/labels/event_label.dart';
export 'models/labels/relation_label.dart';
export 'models/labels/social_media_label.dart';
export 'models/labels/website_label.dart';
export 'models/ringtones/ringtone.dart';
export 'models/ringtones/ringtone_type.dart';
export 'models/vcard/vcard_version.dart';

/// Complete contact management with ultra-fast get, create, update, and delete
/// supporting all fields (phone, email, organization, photo, etc.). Includes
/// groups, accounts, vCard import/export, native dialogs, change listeners,
/// SIM support, and number blocking across Android, iOS, and macOS.
///
/// ```dart
/// class FlutterContacts {
///   // Core CRUD operations
///   static Future<Contact?> get(String id, {Set<ContactProperty>? properties, Account? account});
///   static Future<List<Contact>> getAll({Set<ContactProperty>? properties, ContactFilter? filter, Account? account, int? limit});
///   static Future<String> create(Contact contact, {Account? account});
///   static Future<List<String>> createAll(List<Contact> contacts, {Account? account});
///   static Future<void> update(Contact contact);
///   static Future<void> updateAll(List<Contact> contacts);
///   static Future<void> delete(String id);
///   static Future<void> deleteAll(List<String> ids);
///
///   // Sub-APIs for related functionality
///   static final config = ConfigApi();
///   static final accounts = AccountsApi();
///   static final groups = GroupsApi();
///   static final permissions = PermissionsApi();
///   static final vCard = VCardApi();
///   static final native = NativeApi(); // Android & iOS only
///   static final sim = SimApi(); // Android only
///   static final profile = ProfileApi(); // Android & macOS only
///   static final blockedNumbers = BlockedNumbersApi(); // Android only
///   static final ringtones = RingtonesApi(); // Android only
///
///   // Streams
///   static Stream<void> get onDatabaseChange;
///   static Stream<List<ContactChange>> get onContactChange;
/// }
///
/// // Configuration
/// class ConfigApi {
///   bool enableIosNotes; // Requires iOS entitlement
/// }
///
/// // Account management
/// class AccountsApi {
///   Future<List<Account>> getAll();
///   Future<Account?> getDefault();
///   Future<void> showDefaultPicker(); // Android only
/// }
///
/// // Group operations
/// class GroupsApi {
///   Future<Group?> get(String groupId, {bool withContactCount = false});
///   Future<List<Group>> getAll({List<Account>? accounts, bool withContactCount = false});
///   Future<Group> create(String name, {Account? account});
///   Future<void> update(Group group);
///   Future<void> delete(String groupId);
///   Future<void> addContacts({required String groupId, required List<String> contactIds});
///   Future<void> removeContacts({required String groupId, required List<String> contactIds});
///   Future<List<Group>> getOf(String contactId);
/// }
///
/// // Permissions
/// class PermissionsApi {
///   Future<bool> has(PermissionType type);
///   Future<PermissionStatus> check(PermissionType type);
///   Future<PermissionStatus> request(PermissionType type);
///   Future<void> openSettings();
/// }
///
/// // vCard import/export
/// class VCardApi {
///   String export(Contact contact, {VCardVersion version = VCardVersion.v3});
///   String exportAll(List<Contact> contacts, {VCardVersion version = VCardVersion.v3});
///   List<Contact> import(String vCard);
/// }
///
/// // Native dialogs (Android & iOS only)
/// class NativeApi {
///   Future<void> showViewer(String contactId);
///   Future<String?> showPicker();
///   Future<String?> showEditor(String contactId);
///   Future<String?> showCreator({Contact? contact});
/// }
///
/// // SIM card storage (Android only)
/// class SimApi {
///   Future<List<Contact>> get();
/// }
///
/// // User Profile / "Me" Card (Android & macOS only)
/// class ProfileApi {
///   Future<Contact?> get({Set<ContactProperty>? properties});
/// }
///
/// // Android number blocking
/// class BlockedNumbersApi {
///   Future<bool> isAvailable();
///   Future<bool> isBlocked(String number);
///   Future<List<Phone>> getAll();
///   Future<void> block(String number);
///   Future<void> blockAll(List<String> numbers);
///   Future<void> unblock(String number);
///   Future<void> unblockAll(List<String> numbers);
///   Future<void> openDefaultAppSettings();
/// }
///
/// // Android ringtones
/// class RingtonesApi {
///   Future<Ringtone?> get(String ringtoneUri, {bool withMetadata = true});
///   Future<List<Ringtone>> getAll({RingtoneType? type, bool withMetadata = false});
///   Future<String?> pick(RingtoneType type, {String? existingUri});
///   Future<String?> getDefaultUri(RingtoneType type);
///   Future<void> setDefaultUri(RingtoneType type, String? ringtoneUri);
///   Future<void> play(String ringtoneUri);
///   Future<void> stop();
/// }
/// ```
class FlutterContacts {
  static const _crud = CrudApi.instance;
  static const _listener = ListenerApi.instance;
  static final config = ConfigApi.instance;
  static const accounts = AccountsApi.instance;
  static const groups = GroupsApi.instance;
  static const permissions = PermissionsApi.instance;
  static const vCard = VCardApi.instance;
  static const native = NativeApi.instance;
  static const sim = SimApi.instance;
  static const profile = ProfileApi.instance;
  static const blockedNumbers = BlockedNumbersApi.instance;
  static const ringtones = RingtonesApi.instance;

  /// Gets a single contact by ID.
  ///
  /// [properties] - Properties to fetch. Defaults to none (only ID and display name).
  /// [account] - Optional account filter. Only returns contact data that exists in that account.
  static Future<Contact?> get(
    String id, {
    Set<ContactProperty>? properties,
    Account? account,
  }) => _crud.get(id, properties: properties, account: account);

  /// Gets all contacts matching the criteria.
  ///
  /// [properties] - Properties to fetch. Defaults to none (only ID and display name).
  /// [filter] - Optional filter (e.g., by name, phone, email, group).
  ///   **Note:** Phone and email filters support partial matching on Android, but only full matching on iOS.
  /// [account] - Optional account filter. Only returns contact data that exists in that account.
  /// [limit] - Optional maximum number of contacts to return.
  static Future<List<Contact>> getAll({
    Set<ContactProperty>? properties,
    ContactFilter? filter,
    Account? account,
    int? limit,
  }) => _crud.getAll(
    properties: properties,
    filter: filter,
    account: account,
    limit: limit,
  );

  /// Creates a new contact.
  ///
  /// [contact] - Contact to create.
  /// [account] - Optional account. If null, uses the default account.
  ///
/// Returns the system-generated ID. The contact's `id` and `displayName`
/// are system-generated and will be ignored if provided.
  static Future<String> create(Contact contact, {Account? account}) =>
      _crud.create(contact, account: account);

  /// Creates multiple contacts in a single batch operation.
  ///
  /// [contacts] - Contacts to create.
  /// [account] - Optional account. If null, uses the default account.
  ///
/// Returns a list of system-generated IDs in the same order as input.
/// The contact's `id` and `displayName` are system-generated and will be
/// ignored if provided.
  static Future<List<String>> createAll(
    List<Contact> contacts, {
    Account? account,
  }) => _crud.createAll(contacts, account: account);

  /// Updates a contact.
  ///
  /// Contact must have been fetched using `get()` or `getAll()` first. Only the
  /// properties that were fetched will be updated. This prevents accidentally
  /// overwriting fields that weren't loaded. For example, if you fetched only name
  /// and phone, only those fields can be updated; email changes will be ignored.
  static Future<void> update(Contact contact) => _crud.update(contact);

  /// Updates multiple contacts in a single batch operation.
  ///
  /// All contacts must have been fetched using `get()` or `getAll()` with the same
  /// `properties` parameter. Only the properties that were fetched will be updated.
  /// This prevents accidentally overwriting fields that weren't loaded. For example,
  /// if you fetched only name and phone, only those fields can be updated; email
  /// changes will be ignored.
  static Future<void> updateAll(List<Contact> contacts) =>
      _crud.updateAll(contacts);

  /// Deletes a contact.
  static Future<void> delete(String id) => _crud.delete(id);

  /// Deletes multiple contacts in a single batch operation.
  static Future<void> deleteAll(List<String> ids) => _crud.deleteAll(ids);

  /// Stream that triggers whenever the contact database changes.
  ///
  /// Simple notification stream - doesn't provide details about what changed, just that
  /// something changed.
  ///
  /// ```dart
  /// FlutterContacts.onDatabaseChange.listen((_) {
  ///   // Refresh contact list
  /// });
  /// ```
  static Stream<void> get onDatabaseChange => _listener.onDatabaseChange;

  /// Stream that provides detailed diffs of changes (Added, Updated, Removed).
  ///
  /// Each event is a list of [ContactChange] objects describing what changed.
  ///
  /// ```dart
  /// FlutterContacts.onContactChange.listen((changes) {
  ///   for (final change in changes) {
  ///     print('${change.type}: ${change.contactId}');
  ///   }
  /// });
  /// ```
  static Stream<List<ContactChange>> get onContactChange =>
      _listener.onContactChange;
}
