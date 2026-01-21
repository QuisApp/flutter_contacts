import '../../../models/contact/contact.dart';
import 'property_parser.dart';
import 'contact_building.dart';

/// Main vCard reader/parser interface.
class VCardReader {
  VCardReader._();

  /// Parses a vCard string into a list of Contact objects.
  static List<Contact> parse(String vCard) =>
      _splitVCards(vCard).map(_parseVCard).toList();

  /// Splits vCard string into individual vCard blocks (content lines only).
  ///
  /// Handles incomplete vCards (missing END:VCARD) by including all lines after BEGIN:VCARD.
  static List<List<String>> _splitVCards(String vCard) {
    final blocks = <List<String>>[];
    final lines = vCard.split(RegExp(r'\r?\n'));
    var start = -1;

    for (var i = 0; i < lines.length; i++) {
      final upper = lines[i].trim().toUpperCase();
      if (upper == 'BEGIN:VCARD') {
        start = i;
      } else if (start != -1 && upper == 'END:VCARD') {
        if (i > start + 1) blocks.add(lines.sublist(start + 1, i));
        start = -1;
      }
    }

    // Handle incomplete vCard (missing END:VCARD)
    if (start != -1 && lines.length > start + 1) {
      blocks.add(lines.sublist(start + 1));
    }

    return blocks;
  }

  /// Parses a single vCard block (list of lines) into a Contact.
  static Contact _parseVCard(List<String> lines) {
    final properties = unfoldLines(lines)
        .where((line) => line.trim().isNotEmpty)
        .map(parsePropertyLine)
        .nonNulls
        .toList();

    return buildContact(properties);
  }
}
