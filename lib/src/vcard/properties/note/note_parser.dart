import '../../../../models/properties/note.dart';
import '../../core/property.dart';
import '../../utils/encoding/encoding.dart';

/// Parses NOTE property into Note object.
Note parseNote(VCardProperty prop) {
  return Note(note: unescapeValue(prop.value));
}
