import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import '../utils/json_helpers.dart';
import '../models/contact/contact.dart';
import '../models/accounts/account.dart';
import '../models/contact/contact_property.dart';
import '../models/contact/contact_property_extension.dart';
import '../models/contact/contact_properties.dart';
import '../models/contact/contact_filter.dart';
import 'config_api.dart';

/// Core CRUD operations API.
///
/// Provides methods for creating, reading, updating, and deleting contacts.
class CrudApi {
  const CrudApi._();

  static const instance = CrudApi._();
  static const _channel = MethodChannel('flutter_contacts');

  static Map<String, dynamic> _withIosNotes(Map<String, dynamic> payload) {
    if (Platform.isIOS) {
      payload['enableIosNotes'] = ConfigApi.instance.enableIosNotes;
    }
    return payload;
  }

  Future<Contact?> get(
    String id, {
    Set<ContactProperty>? properties,
    Account? account,
    bool androidLookup = false,
  }) async {
    final props = properties ?? ContactProperties.none;
    final result = await _channel.invokeMethod<Map>(
      'crud.get',
      _withIosNotes({
        'id': id,
        'properties': props.toJson(),
        if (account != null) 'account': account.toJson(),
        if (androidLookup) 'lookup': true,
      }),
    );
    return JsonHelpers.decode(result, Contact.fromJson);
  }

  Future<List<Contact>> getAll({
    Set<ContactProperty>? properties,
    ContactFilter? filter,
    Account? account,
    int? limit,
  }) async {
    final props = properties ?? ContactProperties.none;
    final result = await _channel.invokeMethod<List>(
      'crud.getAll',
      _withIosNotes({
        'properties': props.toJson(),
        if (filter != null) 'filter': filter.toJson(),
        if (account != null) 'account': account.toJson(),
        if (limit != null) 'limit': limit,
      }),
    );
    return JsonHelpers.decodeList(result, Contact.fromJson);
  }

  Future<String> create(Contact contact, {Account? account}) async {
    final result = await _channel.invokeMethod<String>(
      'crud.create',
      _withIosNotes({
        'contact': contact.toJson(),
        if (account != null) 'account': account.toJson(),
      }),
    );
    return result!;
  }

  Future<List<String>> createAll(
    List<Contact> contacts, {
    Account? account,
  }) async {
    final result = await _channel.invokeMethod<List>(
      'crud.createAll',
      _withIosNotes({
        'contacts': contacts.map((e) => e.toJson()).toList(),
        if (account != null) 'account': account.toJson(),
      }),
    );
    return (result ?? []).cast<String>();
  }

  Future<void> update(Contact contact) async {
    await _channel.invokeMethod(
      'crud.update',
      _withIosNotes({'contact': contact.toJson()}),
    );
  }

  Future<void> updateAll(List<Contact> contacts) async {
    await _channel.invokeMethod(
      'crud.updateAll',
      _withIosNotes({'contacts': contacts.map((e) => e.toJson()).toList()}),
    );
  }

  Future<void> delete(String id) async {
    await _channel.invokeMethod('crud.delete', {'id': id});
  }

  Future<void> deleteAll(List<String> ids) async {
    await _channel.invokeMethod('crud.deleteAll', {'ids': ids});
  }
}
