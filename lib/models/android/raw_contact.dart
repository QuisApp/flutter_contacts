import '../../utils/json_helpers.dart';
import '../accounts/account.dart';

/// Information about a raw contact with its identifiers and account.
///
/// One Contact can have multiple RawContacts from different sources (Google, WhatsApp, etc.).
class RawContact {
  /// Raw contact ID. Unstable, local-only. Use when modifying data.
  final String? rawContactId;

  /// Source ID. Stable server UUID. Use for sync matching.
  final String? sourceId;

  /// Account this raw contact belongs to.
  final Account? account;

  const RawContact({this.rawContactId, this.sourceId, this.account});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    JsonHelpers.encode(json, 'rawContactId', rawContactId);
    JsonHelpers.encode(json, 'sourceId', sourceId);
    JsonHelpers.encode(json, 'account', account, (a) => a.toJson());
    return json;
  }

  static RawContact? fromJson(Map? json) {
    if (json == null) return null;
    final accountJson = json['account'];
    final account = accountJson != null
        ? Account.fromJson(accountJson as Map)
        : null;
    final rawContactId = JsonHelpers.decode<String>(json['rawContactId']);
    final sourceId = JsonHelpers.decode<String>(json['sourceId']);
    if (rawContactId == null && sourceId == null && account == null) {
      return null;
    }
    return RawContact(
      rawContactId: rawContactId,
      sourceId: sourceId,
      account: account,
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('RawContact', {
    'rawContactId': rawContactId,
    'sourceId': sourceId,
    'account': account,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawContact &&
          rawContactId == other.rawContactId &&
          sourceId == other.sourceId &&
          account == other.account);

  @override
  int get hashCode => Object.hash(rawContactId, sourceId, account);
}
