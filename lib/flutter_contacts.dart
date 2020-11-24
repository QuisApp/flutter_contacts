/// Flutter plugin to interact with native contact list
import 'package:flutter/services.dart';

import 'contact.dart';

export 'contact.dart';
export 'properties/account.dart';
export 'properties/address.dart';
export 'properties/email.dart';
export 'properties/event.dart';
export 'properties/name.dart';
export 'properties/note.dart';
export 'properties/organization.dart';
export 'properties/phone.dart';
export 'properties/socialMedia.dart';
export 'properties/website.dart';

class FlutterContacts {
  static const MethodChannel _channel =
      MethodChannel('github.com/QuisApp/flutter_contacts');
  static const EventChannel _eventChannel =
      EventChannel('github.com/QuisApp/flutter_contacts/events');

  ///////////////////////////////////////////////////
  ///              FETCHING CONTACTS              ///
  ///////////////////////////////////////////////////

  /// Fetches all contacts (IDs, display names, and optionally low-res photos)
  static Future<List<Contact>> getContacts(
          {bool withPhotos = false, bool sorted = true}) async =>
      await _get(withPhotos: withPhotos, sorted: sorted);

  /// Fetches all fields for given contact
  static Future<Contact> getContact(String id,
      {bool useHighResolutionPhotos = true}) async {
    final contacts = await _get(
        id: id,
        withDetails: true,
        withPhotos: true,
        useHighResolutionPhotos: useHighResolutionPhotos);
    if (contacts.isEmpty) return null;
    return contacts.first;
  }

  /// Fetches all fields for all contacts
  static Future<List<Contact>> getFullContacts(
          {bool withPhotos = false, bool sorted = true}) async =>
      await _get(withDetails: true, withPhotos: withPhotos, sorted: sorted);

  static Future<List<Contact>> _get(
      {String id,
      bool withDetails = false,
      bool withPhotos = false,
      bool useHighResolutionPhotos = false,
      bool sorted = true}) async {
    List untypedContacts = await _channel.invokeMethod(
        'get', [id, withDetails, withPhotos, useHighResolutionPhotos]);
    List<Contact> contacts =
        untypedContacts.map((x) => Contact.fromJson(x)).toList();
    if (sorted) contacts.sort(compareDisplayNames);
    return contacts;
  }

  ///////////////////////////////////////////////////
  ///              CREATING CONTACTS              ///
  ///////////////////////////////////////////////////

  /// Creates new contact and return its ID (or raw contact ID on Android)
  static Future<String> newContact(Contact contact) async =>
      await _channel.invokeMethod('new', contact.toJson(includePhoto: true));

  ///////////////////////////////////////////////////
  ///              UPDATING CONTACTS              ///
  ///////////////////////////////////////////////////

  /// Updates existing contact
  ///
  /// To delete the photo, explicitly set [deletePhoto] to true
  static Future updateContact(Contact contact,
          {bool deletePhoto = false}) async =>
      await _channel.invokeMethod(
          'update', [contact.toJson(includePhoto: true), deletePhoto]);

  ///////////////////////////////////////////////////
  ///              DELETING CONTACTS              ///
  ///////////////////////////////////////////////////

  /// Deletes contact with given ID (given by [contact.id])
  static Future deleteContact(String contactId) async =>
      await _channel.invokeMethod('delete', [contactId]);

  /// Deletes contacts with given IDs (given by [contact.id])
  static Future deleteContacts(List<String> contactIds) async =>
      await _channel.invokeMethod('delete', contactIds);

  ///////////////////////////////////////////////////
  ///           LISTENING TO DB CHANGES           ///
  ///////////////////////////////////////////////////

  /// Listens to contact database changes and executes callback function.
  ///
  /// Because of limitations both on iOS and on Android (see
  /// https://www.grokkingandroid.com/use-contentobserver-to-listen-to-changes/)
  /// it's not possible to tell which kind of change happened and on which
  /// contacts. It only notifies something changed in the contacts database.
  ///
  /// [listener] must be a parameterless function.
  ///
  /// The return value is a function (returning [Future<void>]) that cancels the
  /// subscription.
  static Future<void> Function() onChange(Function listener) {
    var subscription =
        _eventChannel.receiveBroadcastStream().listen((event) => listener());
    return () => subscription.cancel();
  }

  ///////////////////////////////////////////////////
  ///               SORTING CONTACTS              ///
  ///////////////////////////////////////////////////

  static RegExp _alpha = RegExp(r'\p{Letter}', unicode: true);
  static RegExp _numeric = RegExp(r'\p{Number}', unicode: true);

  /// Sort display names in the "natural" way, ignoring case and diacritics.
  ///
  /// By default they're sorted lexicographically, which means `E` comes before
  /// `e`, which itself comes before `É`. The usual, more natural sorting,
  /// ignores case and diacritics. For example `Édouard Manet` should come
  /// before `Elon Musk`.
  ///
  /// In addition, numbers come after letters.
  static int compareDisplayNames(Contact a, Contact b) {
    var x = a.normalizedName;
    var y = b.normalizedName;
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
}
