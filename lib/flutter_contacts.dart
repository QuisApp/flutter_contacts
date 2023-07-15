import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_contacts/config.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/diacritics.dart';
import 'package:flutter_contacts/properties/group.dart';

export 'contact.dart';
export 'properties/account.dart';
export 'properties/address.dart';
export 'properties/email.dart';
export 'properties/event.dart';
export 'properties/group.dart';
export 'properties/name.dart';
export 'properties/note.dart';
export 'properties/organization.dart';
export 'properties/phone.dart';
export 'properties/social_media.dart';
export 'properties/website.dart';

class FlutterContacts {
  static const _channel = MethodChannel('github.com/QuisApp/flutter_contacts');
  static const _eventChannel =
      EventChannel('github.com/QuisApp/flutter_contacts/events');
  // The linter is confused by this. It's the caller's responsibility to call
  // removeListener when appropriate.
  // ignore: cancel_subscriptions
  static StreamSubscription? _eventSubscription;
  static final _eventSubscribers = <void Function()>[];
  static final _alpha = RegExp(r'\p{Letter}', unicode: true);
  static final _numeric = RegExp(r'\p{Number}', unicode: true);

  /// Plugin configuration.
  static var config = FlutterContactsConfig();

  /// Requests permission to read or read/write contacts. Returns true if
  /// granted, false in any other case. Note: read-only mode is only applicable
  /// to Android.
  static Future<bool> requestPermission({bool readonly = false}) async =>
      await _channel.invokeMethod('requestPermission', readonly) ?? false;

  /// Fetches all contacts.
  ///
  /// By default only ID and display name are fetched. If [withProperties] is
  /// true, properties (phones, emails, addresses, websites, etc) are also
  /// fetched.
  ///
  /// If [withThumbnail] is true, the low-resolution thumbnail is also
  /// fetched. If [withPhoto] is true, the high-resolution photo is also
  /// fetched.
  ///
  /// If [withGroups] is true, it also returns the group information (called
  /// labels on Android and groups on iOS).
  ///
  /// If [withAccounts] is true, it also returns the account information. On
  /// Android this is the raw account, and there can be several accounts per
  /// unified contact (for example one for Gmail, one for Skype and one for
  /// WhatsApp). On iOS it is called container, and there can be only one
  /// container per contact.
  ///
  /// If [sorted] is true, the contacts are returned sorted by their
  /// normalized display names (ignoring case and diacritics).
  ///
  /// If [deduplicateProperties] is true, the properties will be de-duplicated,
  /// mainly to avoid the case (common on Android) where multiple equivalent
  /// phones are returned.
  static Future<List<Contact>> getContacts({
    bool withProperties = false,
    bool withThumbnail = false,
    bool withPhoto = false,
    bool withGroups = false,
    bool withAccounts = false,
    bool sorted = true,
    bool deduplicateProperties = true,
  }) async =>
      _select(
        withProperties: withProperties,
        withThumbnail: withThumbnail,
        withPhoto: withPhoto,
        withGroups: withGroups,
        withAccounts: withAccounts,
        sorted: sorted,
        deduplicateProperties: deduplicateProperties,
      );

  /// Fetches one contact.
  ///
  /// By default everything available is fetched. If [withProperties] is
  /// false, properties (phones, emails, addresses, websites, etc) won't be
  /// fetched.
  ///
  /// If [withThumbnail] is false, the low-resolution thumbnail won't be
  /// fetched. If [withPhoto] is false, the high-resolution photo won't be
  /// fetched.
  ///
  /// If [withGroups] is true, it also returns the group information (called
  /// labels on Android and groups on iOS).
  ///
  /// If [withAccounts] is true, it also returns the account information. On
  /// Android this is the raw account, and there can be several accounts per
  /// unified contact (for example one for Gmail, one for Skype and one for
  /// WhatsApp). On iOS it is called container, and there can be only one
  /// container per contact.
  ///
  /// If [deduplicateProperties] is true, the properties will be de-duplicated,
  /// mainly to avoid the case (common on Android) where multiple equivalent
  /// phones are returned.
  static Future<Contact?> getContact(
    String id, {
    bool withProperties = true,
    bool withThumbnail = true,
    bool withPhoto = true,
    bool withGroups = false,
    bool withAccounts = false,
    bool deduplicateProperties = true,
  }) async {
    final contacts = await _select(
      id: id,
      withProperties: withProperties,
      withThumbnail: withThumbnail,
      withPhoto: withPhoto,
      withGroups: withGroups,
      withAccounts: withAccounts,
      sorted: false,
      deduplicateProperties: deduplicateProperties,
    );
    if (contacts.length != 1) return null;
    return contacts.first;
  }

  /// Inserts a new [contact] in the database and returns it.
  ///
  /// Note that the output contact will be different from the input; for example
  /// the input can't have an ID, but the output will. If you intend to perform
  /// operations on the contact after creation, you should perform them on the
  /// output rather than on the input.
  static Future<Contact> insertContact(Contact contact) async {
    // This avoids the accidental case where we want to update a contact but
    // insert it instead, which would result in two identical contacts.
    if (contact.id.isNotEmpty) {
      throw Exception('Cannot insert contact that already has an ID');
    }
    if (!contact.isUnified) {
      throw Exception('Cannot insert raw contacts');
    }
    final json = await _channel.invokeMethod('insert', [
      contact.toJson(),
      config.includeNotesOnIos13AndAbove,
    ]);
    return Contact.fromJson(Map<String, dynamic>.from(json));
  }

  /// Updates existing contact and returns it.
  ///
  /// Note that output contact may be different from the input. If you intend to
  /// perform operations on the contact after update, you should perform them on
  /// the output rather than on the input.
  static Future<Contact> updateContact(
    Contact contact, {
    bool withGroups = false,
  }) async {
    // This avoids the accidental case where we want to insert a contact but
    // update it instead, which won't work.
    if (contact.id.isEmpty) {
      throw Exception('Cannot update contact without ID');
    }
    // In addition, on Android we need a raw contact ID.
    if (Platform.isAndroid &&
        !contact.accounts.any((x) => x.rawId.isNotEmpty)) {
      throw Exception(
          'Cannot update contact without raw ID on Android, make sure to '
          'specify `withAccounts: true` when fetching contacts');
    }
    // This avoids the accidental case where we try to update a contact before
    // fetching all their properties or photos, which would erase the existing
    // properties or photos.
    if (!contact.propertiesFetched || !contact.photoFetched) {
      throw Exception(
          'Cannot update contact without properties and photo, make sure to '
          'specify `withProperties: true` and `withPhoto: true` when fetching '
          'contacts');
    }
    if (!contact.isUnified) {
      throw Exception('Cannot update raw contacts');
    }
    final json = await _channel.invokeMethod('update', [
      contact.toJson(),
      withGroups,
      config.includeNotesOnIos13AndAbove,
    ]);
    return Contact.fromJson(Map<String, dynamic>.from(json));
  }

  /// Deletes contacts from the database.
  static Future<void> deleteContacts(List<Contact> contacts) async {
    final ids = contacts.map((c) => c.id).toList();
    if (ids.any((x) => x.isEmpty)) {
      throw Exception('Cannot delete contacts without IDs');
    }
    if (contacts.any((c) => !c.isUnified)) {
      throw Exception('Cannot delete raw contacts');
    }
    await _channel.invokeMethod('delete', ids);
  }

  /// Deletes one contact from the database.
  static Future<void> deleteContact(Contact contact) async =>
      deleteContacts([contact]);

  /// Fetches all groups (or labels on Android).
  static Future<List<Group>> getGroups() async {
    List untypedGroups = await _channel.invokeMethod('getGroups');
    // ignore: omit_local_variable_types
    List<Group> groups = untypedGroups
        .map((x) => Group.fromJson(Map<String, dynamic>.from(x)))
        .toList();
    return groups;
  }

  /// Inserts a new group (or label on Android).
  static Future<Group> insertGroup(Group group) async {
    return Group.fromJson(Map<String, dynamic>.from(
        await _channel.invokeMethod('insertGroup', [group.toJson()])));
  }

  /// Updates a group (or label on Android).
  static Future<Group> updateGroup(Group group) async {
    return Group.fromJson(Map<String, dynamic>.from(
        await _channel.invokeMethod('updateGroup', [group.toJson()])));
  }

  /// Deletes a group (or label on Android).
  static Future<void> deleteGroup(Group group) async {
    await _channel.invokeMethod('deleteGroup', [group.toJson()]);
  }

  /// Listens to contact database changes.
  ///
  /// Because of limitations both on iOS and on Android (see
  /// https://www.grokkingandroid.com/use-contentobserver-to-listen-to-changes/)
  /// it's not possible to tell which kind of change happened and on which
  /// contacts. It only notifies that something changed in the contacts
  /// database.
  static void addListener(void Function() listener) {
    if (_eventSubscription != null) {
      _eventSubscription!.cancel();
    }
    _eventSubscribers.add(listener);
    final runAllListeners = (event) => _eventSubscribers.forEach((f) => f());
    _eventSubscription =
        _eventChannel.receiveBroadcastStream().listen(runAllListeners);
  }

  /// Removes a listener to contact database changes.
  ///
  /// Because of limitations both on iOS and on Android (see
  /// https://www.grokkingandroid.com/use-contentobserver-to-listen-to-changes/)
  /// it's not possible to tell which kind of change happened and on which
  /// contacts. It only notifies that something changed in the contacts
  /// database.
  static void removeListener(void Function() listener) {
    if (_eventSubscription != null) {
      _eventSubscription!.cancel();
    }
    _eventSubscribers.remove(listener);
    if (_eventSubscribers.isEmpty) {
      _eventSubscription = null;
    } else {
      final runAllListeners = (event) => _eventSubscribers.forEach((f) => f());
      _eventSubscription =
          _eventChannel.receiveBroadcastStream().listen(runAllListeners);
    }
  }

  /// Opens external contact app to view an existing contact.
  static Future<void> openExternalView(String id) async =>
      await _channel.invokeMethod(
          Platform.isAndroid ? 'openExternalView' : 'openExternalViewOrEdit',
          [id]);

  /// Opens external contact app to edit an existing contact.
  static Future<Contact?> openExternalEdit(String id) async {
    // New ID should be the same as original ID, but just to be safe.
    final newId = await _channel.invokeMethod(
        Platform.isAndroid ? 'openExternalEdit' : 'openExternalViewOrEdit',
        [id]);
    return newId == null ? null : getContact(newId);
  }

  /// Opens external contact app to pick an existing contact.
  static Future<Contact?> openExternalPick() async {
    final id = await _channel.invokeMethod('openExternalPick');
    return id == null ? null : getContact(id);
  }

  /// Opens external contact app to insert a new contact.
  ///
  /// Optionally specify a [Contact] to pre-fill the data from.
  static Future<Contact?> openExternalInsert([Contact? contact]) async {
    final args = contact != null ? [contact.toJson()] : [];
    final id = await _channel.invokeMethod(
      'openExternalInsert',
      args,
    );
    return id == null ? null : getContact(id);
  }

  static Future<List<Contact>> _select({
    String? id,
    bool withProperties = false,
    bool withThumbnail = false,
    bool withPhoto = false,
    bool withGroups = false,
    bool withAccounts = false,
    bool sorted = true,
    bool deduplicateProperties = true,
  }) async {
    // removing the types makes it crash at runtime
    // ignore: omit_local_variable_types
    List untypedContacts = await _channel.invokeMethod('select', [
      id,
      withProperties,
      withThumbnail,
      withPhoto,
      withGroups,
      withAccounts,
      config.returnUnifiedContacts,
      config.includeNonVisibleOnAndroid,
      config.includeNotesOnIos13AndAbove,
    ]);
    // ignore: omit_local_variable_types
    List<Contact> contacts = untypedContacts
        .map((x) => Contact.fromJson(Map<String, dynamic>.from(x)))
        .toList();
    if (sorted) {
      contacts.sort(_compareDisplayNames);
    }
    if (deduplicateProperties) {
      contacts.forEach((c) => c.deduplicateProperties());
    }
    contacts.forEach((c) => c
      ..propertiesFetched = withProperties
      ..thumbnailFetched = withThumbnail
      ..photoFetched = withPhoto
      ..isUnified = config.returnUnifiedContacts);
    return contacts;
  }

  /// Sorts display names in a "natural" way, ignoring case and diacritics.
  ///
  /// By default they would be sorted lexicographically, which means `E` comes
  /// before `e`, which itself comes before `É`. The usual, more natural
  /// sorting, ignores case and diacritics. For example `Édouard Manet` should
  /// come before `Elon Musk`. In addition, numbers come after letters.
  static int _compareDisplayNames(Contact a, Contact b) {
    var x = _normalizeName(a.displayName);
    var y = _normalizeName(b.displayName);
    if (x.isEmpty && y.isNotEmpty) return 1;
    if (x.isEmpty && y.isEmpty) return 0;
    if (x.isNotEmpty && y.isEmpty) return -1;
    if (_alpha.hasMatch(x[0]) && !_alpha.hasMatch(y[0])) return -1;
    if (!_alpha.hasMatch(x[0]) && _alpha.hasMatch(y[0])) return 1;
    if (!_alpha.hasMatch(x[0]) && !_alpha.hasMatch(y[0])) {
      if (_numeric.hasMatch(x[0]) && !_numeric.hasMatch(y[0])) return -1;
      if (!_numeric.hasMatch(x[0]) && _numeric.hasMatch(y[0])) return 1;
    }
    return x.compareTo(y);
  }

  /// Returns normalized display name, which ignores case, space and diacritics.
  static String _normalizeName(String name) =>
      removeDiacritics(name.trim().toLowerCase());
}
