import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/contact/contact_change.dart';
import '../src/stream/broadcast_stream_manager.dart';

/// Contact change listeners API.
class ListenerApi {
  const ListenerApi._();

  static const instance = ListenerApi._();
  static const _simpleEventChannel = EventChannel(
    'flutter_contacts/simple_listener',
  );
  static const _detailedEventChannel = EventChannel(
    'flutter_contacts/detailed_listener',
  );

  static final _simpleStreamManager = BroadcastStreamManager<void>(
    _simpleEventChannel,
  );

  static final _detailedStreamManager =
      BroadcastStreamManager<List<ContactChange>>(
        _detailedEventChannel,
        transform: _parseChangeEvents,
      );

  Stream<void> get onDatabaseChange => _simpleStreamManager.stream;

  Stream<List<ContactChange>> get onContactChange =>
      _detailedStreamManager.stream;

  static List<ContactChange> _parseChangeEvents(dynamic event) {
    if (event is! String) return [];
    final eventsJson = jsonDecode(event) as List<dynamic>;
    return eventsJson
        .map(_parseChangeEvent)
        .whereType<ContactChange>()
        .toList();
  }

  static ContactChange? _parseChangeEvent(dynamic e) {
    if (e is! Map) return null;
    final contactId = e['contactId'] as String?;
    if (contactId == null) return null;
    final changeType = _parseChangeType(e['type'] as String?);
    return changeType != null
        ? ContactChange(type: changeType, contactId: contactId)
        : null;
  }

  static ContactChangeType? _parseChangeType(String? type) {
    return switch (type) {
      'added' => ContactChangeType.added,
      'updated' => ContactChangeType.updated,
      'removed' => ContactChangeType.removed,
      _ => null,
    };
  }
}
