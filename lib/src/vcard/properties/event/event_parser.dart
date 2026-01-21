import '../../../../models/properties/event.dart';
import '../../core/property.dart';
import 'event_label.dart';

/// Parses event property (BDAY, ANNIVERSARY, X-EVENT).
Event parseEvent(VCardProperty prop) {
  final label = parseEventLabel(prop.name, prop.params['type']);
  return _parseDate(prop.value).copyWith(label: label);
}

/// Parses date string in various vCard formats.
///
/// Supports:
/// - Partial dates: --MM-DD or --MMDD (no year, e.g., birthdays)
/// - Full dates: YYYY-MM-DD, YYYY/MM/DD, or YYYYMMDD
Event _parseDate(String dateStr) {
  final trimmed = dateStr.trim();

  // Partial date: --MM-DD or --MMDD (RFC 6350 Section 4.3.4)
  final partialMatch = RegExp(r'^--(\d{2})[-]?(\d{2})$').firstMatch(trimmed);
  if (partialMatch != null) {
    return Event(
      year: null,
      month: int.tryParse(partialMatch.group(1)!) ?? 1,
      day: int.tryParse(partialMatch.group(2)!) ?? 1,
    );
  }

  // Full date: YYYY-MM-DD, YYYY/MM/DD, or YYYYMMDD
  final fullMatch = RegExp(
    r'^(\d{4})[-/]?(\d{1,2})[-/]?(\d{1,2})$',
  ).firstMatch(trimmed);
  if (fullMatch != null) {
    return Event(
      year: int.tryParse(fullMatch.group(1)!),
      month: int.tryParse(fullMatch.group(2)!) ?? 1,
      day: int.tryParse(fullMatch.group(3)!) ?? 1,
    );
  }

  // Fallback: invalid date format
  return Event(month: 1, day: 1);
}
