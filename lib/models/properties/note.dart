import '../../utils/json_helpers.dart';
import 'property_metadata.dart';

/// Note property.
///
/// Android allows multiple notes per contact; iOS/macOS allows only one.
///
/// iOS requires entitlements and `FlutterContacts.config.enableIosNotes = true`.
/// See [Apple's documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.contacts.notes).
class Note {
  /// Note text.
  final String note;

  /// Property identity metadata (used internally for updates).
  final PropertyMetadata? metadata;

  const Note({required this.note, this.metadata});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'note': note};
    JsonHelpers.encode(json, 'metadata', metadata, (m) => m.toJson());
    return json;
  }

  static Note fromJson(Map json) => Note(
    note: json['note'] as String,
    metadata: JsonHelpers.decode(json['metadata'], PropertyMetadata.fromJson),
  );

  @override
  String toString() => JsonHelpers.formatToString('Note', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Note && note == other.note);

  @override
  int get hashCode => note.hashCode;

  Note copyWith({String? note, PropertyMetadata? metadata}) {
    return Note(note: note ?? this.note, metadata: metadata ?? this.metadata);
  }
}
