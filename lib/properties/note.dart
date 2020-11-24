import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

/// A note, i.e. a free-form string about the contact.
///
/// Android allows multiple notes per contact, while iOS supports only one.
@JsonSerializable(disallowUnrecognizedKeys: true)
class Note {
  @JsonKey(required: true)
  String note;

  Note(this.note);

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
