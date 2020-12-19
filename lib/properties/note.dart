import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

/// A note, i.e. a free-form string about the contact.
///
/// Android allows multiple notes per contact, while iOS supports only one.
///
/// On iOS13+ notes are no longer supported, as you need to request entitlement
/// from Apple to use it in your app. See:
/// https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_contacts_notes
@JsonSerializable(disallowUnrecognizedKeys: true)
class Note {
  @JsonKey(required: true)
  String note;

  Note(this.note);

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
