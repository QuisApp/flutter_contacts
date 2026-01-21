import '../../utils/json_helpers.dart';

/// Property identity metadata for tracking property identity in the native store.
///
/// This metadata is populated when fetching contacts and is used when updating contacts
/// to identify which properties to update.
///
/// Do not edit or create this manually.
class PropertyMetadata {
  /// Stable identifier for the data row in the native store.
  final String? dataId;

  /// Raw contact ID that identifies which raw contact (account) this property belongs to (Android only).
  final String? rawContactId;

  const PropertyMetadata({this.dataId, this.rawContactId});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    JsonHelpers.encode(json, 'dataId', dataId);
    JsonHelpers.encode(json, 'rawContactId', rawContactId);
    return json;
  }

  static PropertyMetadata fromJson(Map json) => PropertyMetadata(
    dataId: JsonHelpers.decode<String>(json['dataId']),
    rawContactId: JsonHelpers.decode<String>(json['rawContactId']),
  );

  @override
  String toString() => JsonHelpers.formatToString('PropertyMetadata', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PropertyMetadata &&
          dataId == other.dataId &&
          rawContactId == other.rawContactId);

  @override
  int get hashCode => Object.hash(dataId, rawContactId);

  PropertyMetadata copyWith({String? dataId, String? rawContactId}) =>
      PropertyMetadata(
        dataId: dataId ?? this.dataId,
        rawContactId: rawContactId ?? this.rawContactId,
      );
}
