import '../../utils/json_helpers.dart';
import 'raw_contact.dart';

/// Android-specific contact identifiers (Android only).
///
/// Android uses a three-tier structure: Contact (aggregate), RawContact (source), Data (details).
/// One Contact can merge multiple RawContacts from different accounts.
///
/// ID Stability:
/// - Unstable: [Contact.id], [RawContact.rawContactId] - change on backup/restore
/// - Stable: [RawContact.sourceId] - persists across devices if synced
/// - Permanent: [lookupKey] - use `FlutterContacts.get(lookupKey, androidLookup: true)` if [Contact.id] becomes invalid
class AndroidIdentifiers {
  /// Lookup key for the contact. Use `FlutterContacts.get(lookupKey, androidLookup: true)` to find the contact.
  final String? lookupKey;

  /// List of raw contacts from different sources.
  final List<RawContact> rawContacts;

  const AndroidIdentifiers({this.lookupKey, this.rawContacts = const []});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    JsonHelpers.encode(json, 'lookupKey', lookupKey);
    JsonHelpers.encodeList(json, 'rawContacts', rawContacts, (r) => r.toJson());
    return json;
  }

  static AndroidIdentifiers? fromJson(Map? json) {
    if (json == null) return null;
    return AndroidIdentifiers(
      lookupKey: JsonHelpers.decode<String>(json['lookupKey']),
      rawContacts:
          (json['rawContacts'] as List?)
              ?.map((e) => RawContact.fromJson(e as Map?))
              .whereType<RawContact>()
              .toList() ??
          const [],
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('AndroidIdentifiers', {
    'lookupKey': lookupKey,
    'rawContacts': rawContacts.isNotEmpty ? rawContacts : null,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AndroidIdentifiers &&
          lookupKey == other.lookupKey &&
          rawContacts == other.rawContacts);

  @override
  int get hashCode => Object.hash(lookupKey, rawContacts);

  bool get isNotEmpty => lookupKey != null || rawContacts.isNotEmpty;
}
