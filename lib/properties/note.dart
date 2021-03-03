import 'package:flutter_contacts/vcard.dart';

/// Note, i.e. a free-form string about the contact.
///
/// Android allows multiple notes per contact, while iOS supports only one.
///
/// On iOS13+ notes are no longer supported, as you need to request entitlement
/// from Apple to use it in your app. See:
/// https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_contacts_notes
class Note {
  /// Note content.
  String note;

  Note(this.note);

  factory Note.fromJson(Map<String, dynamic> json) =>
      Note((json['note'] as String?) ?? '');

  Map<String, dynamic> toJson() => <String, dynamic>{'note': note};

  @override
  int get hashCode => note.hashCode;

  @override
  bool operator ==(Object o) => o is Note && o.note == note;

  @override
  String toString() => 'Note(note=$note)';

  List<String> toVCard() {
    // NOTE (V3): https://tools.ietf.org/html/rfc2426#section-3.6.2
    // NOTE (V4): https://tools.ietf.org/html/rfc6350#section-6.7.2
    return ['NOTE:${vCardEncode(note)}'];
  }
}
