import '../../../../models/labels/event_label.dart';
import '../../../../models/labels/label.dart';
import '../../utils/parsing/split.dart' show splitByComma;

/// Parses event label from property name and TYPE parameter.
Label<EventLabel> parseEventLabel(String name, String? typeValue) {
  switch (name) {
    case 'BDAY':
      return Label(EventLabel.birthday);
    case 'ANNIVERSARY':
    case 'X-ANNIVERSARY':
      return Label(EventLabel.anniversary);
  }

  final type = typeValue != null
      ? splitByComma(typeValue).first.trim().toLowerCase()
      : null;
  if (type == null || type.isEmpty) {
    return Label(EventLabel.other);
  }

  switch (type) {
    case 'birthday':
      return Label(EventLabel.birthday);
    case 'anniversary':
      return Label(EventLabel.anniversary);
    default:
      return Label(EventLabel.custom, type);
  }
}
