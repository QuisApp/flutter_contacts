import '../../../../models/contact/contact.dart';
import '../../../../models/labels/event_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/version.dart';
import '../../utils/formatting/params.dart';
import '../../writer/formatter.dart';

/// Writes event-related properties (BDAY, ANNIVERSARY, X-EVENT).
///
/// RFC sections:
/// - vCard 2.1: BDAY
/// - vCard 3.0: RFC 2426 Section 3.1.5 (BDAY)
/// - vCard 4.0: RFC 6350 Section 6.2.5 (BDAY), Section 6.2.6 (ANNIVERSARY)
void writeEvents(StringBuffer buffer, Contact contact, VCardVersion version) {
  for (final event in contact.events) {
    final eventVal = _formatDate(event.year, event.month, event.day);
    final propertyName = _getPropertyName(event.label.label, version);
    final params = _getParams(event.label, version);

    writeProperty(
      buffer,
      propertyName,
      eventVal,
      version: version,
      params: params,
    );
  }
}

/// Returns the vCard property name for an event label.
String _getPropertyName(EventLabel label, VCardVersion version) {
  switch (label) {
    case EventLabel.birthday:
      return 'BDAY';
    case EventLabel.anniversary:
      return version.isV4 ? 'ANNIVERSARY' : 'X-ANNIVERSARY';
    default:
      return 'X-EVENT';
  }
}

/// Returns parameters for an event property.
List<String>? _getParams(Label<EventLabel> label, VCardVersion version) {
  if (label.label == EventLabel.birthday ||
      label.label == EventLabel.anniversary) {
    return null;
  }
  final type = label.customLabel ?? label.label.name;
  return ['${paramName('TYPE', version)}=${normalizeLabel(type, version)}'];
}

/// Formats date as YYYY-MM-DD (ISO 8601 format) and partial date as --MM-DD.
String _formatDate(int? year, int month, int day) {
  final m = month.toString().padLeft(2, '0');
  final d = day.toString().padLeft(2, '0');
  final y = year?.toString().padLeft(4, '0') ?? '-';
  return '$y-$m-$d';
}
