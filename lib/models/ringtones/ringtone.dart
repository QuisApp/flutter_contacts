import '../../utils/json_helpers.dart';
import 'ringtone_type.dart';

/// Information about a ringtone.
///
/// [uri] is always present. All other fields are only populated if `withMetadata` was true
/// when fetching the ringtone.
class Ringtone {
  /// Ringtone URI (always present).
  final String uri;

  /// Ringtone title/name (only if withMetadata was true).
  final String? title;

  /// Ringtone type (only if withMetadata was true).
  final RingtoneType? type;

  /// Whether the ringtone contains haptic channels (only if withMetadata was true).
  final bool? hasHapticChannels;

  /// Media title (only if withMetadata was true).
  final String? mediaTitle;

  /// Artist name (only if withMetadata was true).
  final String? artist;

  /// Album name (only if withMetadata was true).
  final String? album;

  /// Duration in milliseconds (only if withMetadata was true).
  final int? duration;

  /// Display name (only if withMetadata was true).
  final String? displayName;

  /// File size in bytes (only if withMetadata was true).
  final int? size;

  /// Date added timestamp in milliseconds since epoch (only if withMetadata was true).
  final int? dateAdded;

  /// Date modified timestamp in milliseconds since epoch (only if withMetadata was true).
  final int? dateModified;

  /// MIME type (only if withMetadata was true).
  final String? mimeType;

  const Ringtone({
    required this.uri,
    this.title,
    this.type,
    this.hasHapticChannels,
    this.mediaTitle,
    this.artist,
    this.album,
    this.duration,
    this.displayName,
    this.size,
    this.dateAdded,
    this.dateModified,
    this.mimeType,
  });

  factory Ringtone.fromJson(Map json) {
    return Ringtone(
      uri: json['uri'] as String,
      title: json['title'] as String?,
      type: JsonHelpers.decodeEnum(
        json['type'],
        RingtoneType.values,
        RingtoneType.ringtone,
      ),
      hasHapticChannels: json['hasHapticChannels'] as bool?,
      mediaTitle: json['mediaTitle'] as String?,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      duration: json['duration'] as int?,
      displayName: json['displayName'] as String?,
      size: json['size'] as int?,
      dateAdded: json['dateAdded'] as int?,
      dateModified: json['dateModified'] as int?,
      mimeType: json['mimeType'] as String?,
    );
  }
}
