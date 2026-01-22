import '../../utils/json_helpers.dart';
import 'android_identifiers.dart';

/// Android-specific data (Android only).
///
/// Contains all Android-only fields for a contact.
class AndroidData {
  /// Whether contact is starred/favorited.
  final bool? isFavorite;

  /// URI for custom ringtone.
  final String? customRingtone;

  /// Whether to send calls to voicemail.
  final bool? sendToVoicemail;

  /// Last update timestamp in milliseconds since epoch.
  final int? lastUpdatedTimestamp;

  /// Contact identifiers (lookup key, raw contact ID, etc.).
  final AndroidIdentifiers? identifiers;

  /// All data mimetypes for debugging.
  final Map? debugData;

  const AndroidData({
    this.isFavorite,
    this.customRingtone,
    this.sendToVoicemail,
    this.lastUpdatedTimestamp,
    this.identifiers,
    this.debugData,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    JsonHelpers.encode(json, 'isFavorite', isFavorite);
    JsonHelpers.encode(json, 'customRingtone', customRingtone);
    JsonHelpers.encode(json, 'sendToVoicemail', sendToVoicemail);
    JsonHelpers.encode(json, 'lastUpdatedTimestamp', lastUpdatedTimestamp);
    JsonHelpers.encode(json, 'identifiers', identifiers, (i) => i.toJson());
    JsonHelpers.encode(json, 'debugData', debugData);
    return json;
  }

  static AndroidData? fromJson(Map? json) {
    if (json == null) return null;
    return AndroidData(
      isFavorite: JsonHelpers.decode<bool>(json['isFavorite']),
      customRingtone: JsonHelpers.decode<String>(json['customRingtone']),
      sendToVoicemail: JsonHelpers.decode<bool>(json['sendToVoicemail']),
      lastUpdatedTimestamp: json['lastUpdatedTimestamp'] as int?,
      identifiers: AndroidIdentifiers.fromJson(json['identifiers'] as Map?),
      debugData: JsonHelpers.decode<Map>(json['debugData']),
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('AndroidData', {
    'isFavorite': isFavorite,
    'customRingtone': customRingtone,
    'sendToVoicemail': sendToVoicemail,
    'lastUpdatedTimestamp': lastUpdatedTimestamp,
    'identifiers': identifiers,
    'debugData': debugData != null ? '<debugData>' : null,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AndroidData &&
          isFavorite == other.isFavorite &&
          customRingtone == other.customRingtone &&
          sendToVoicemail == other.sendToVoicemail &&
          lastUpdatedTimestamp == other.lastUpdatedTimestamp &&
          identifiers == other.identifiers &&
          debugData == other.debugData);

  @override
  int get hashCode => Object.hash(
    isFavorite,
    customRingtone,
    sendToVoicemail,
    lastUpdatedTimestamp,
    identifiers,
    debugData,
  );

  /// Returns true if this AndroidData object has any data.
  bool get isNotEmpty =>
      isFavorite != null ||
      customRingtone != null ||
      sendToVoicemail != null ||
      lastUpdatedTimestamp != null ||
      identifiers?.isNotEmpty == true ||
      debugData != null;
}
