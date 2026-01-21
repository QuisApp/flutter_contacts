import '../../core/version.dart';

// ASCII character codes
const int _asciiMax = 127;

/// Checks if a string contains non-ASCII characters or newlines.
bool hasNonAsciiOrNewlines(String s) {
  return s.codeUnits.any((c) => c > _asciiMax) ||
      s.contains('\n') ||
      s.contains('\r');
}

/// Checks if Quoted-Printable encoding is needed (vCard 2.1 only).
///
/// RFC 2426 (vCard 3.0) removed quoted-printable support. Only BASE64 encoding
/// is allowed for the ENCODING parameter in v3.0. Text values in v3.0 should
/// use UTF-8 with proper escaping instead.
bool needsQuotedPrintable(String? value, VCardVersion version) {
  if (value == null || value.isEmpty) return false;
  if (!version.isV21) return false; // Only v2.1 supports quoted-printable
  return hasNonAsciiOrNewlines(value);
}

/// Escapes special characters for text values (RFC 2426 Section 2.4.2, RFC 6350 Section 3.4).
///
/// Normalizes all line breaks (\r\n, \r, \n) to \n per RFC 6350 Section 3.4,
/// which only defines \n as a valid escape sequence.
///
/// Order matters: backslash must be escaped first to avoid double-escaping.
String escapeValue(String? s) {
  if (s == null || s.isEmpty) return '';
  return s
      .replaceAll('\\', '\\\\') // Must be first to avoid double-escaping
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll(RegExp(r'\r\n|\r|\n'), '\\n'); // Normalize all breaks to \n
}

/// Escapes parameter values for use in quoted strings.
///
/// Note: Uses backslash escaping for compatibility. RFC 6868 (vCard 4.0) defines
/// ^' for quotes, ^n for newlines, and ^^ for ^, but many parsers support
/// backslash escaping. Normalizes all line breaks to \n for consistency.
///
/// Order matters: backslash must be escaped first to avoid double-escaping.
String escapeQuotedValue(String s) {
  return s
      .replaceAll('\\', '\\\\') // Must be first to avoid double-escaping
      .replaceAll('"', '\\"')
      .replaceAll(RegExp(r'\r\n|\r|\n'), '\\n'); // Normalize all breaks to \n
}

/// Unescapes special characters in text values (reverses escapeValue).
///
/// Handles the vCard standard escapes:
/// - \\ -> \
/// - \; -> ;
/// - \, -> ,
/// - \n or \N -> Newline
/// - \r or \R -> Carriage return (non-standard, but handled gracefully)
String unescapeValue(String? s) {
  if (s == null || s.isEmpty) return '';

  // Matches a backslash followed by \, ;, ,, n, N, r, or R
  final pattern = RegExp(r'\\[\\;,nNrR]');

  return s.replaceAllMapped(pattern, (match) {
    final m = match[0]!;
    final char = m[1];

    switch (char) {
      case 'n':
      case 'N':
        return '\n';
      case 'r':
      case 'R':
        return '\r';
      case '\\':
        return '\\';
      case ';':
        return ';';
      case ',':
        return ',';
      default:
        // Fallback: return the character as-is (unreachable with current regex)
        return char;
    }
  });
}

/// Unescapes parameter values (reverses escapeQuotedValue).
///
/// Handles the compatibility escapes:
/// - \\ -> \
/// - \" -> "
/// - \n or \N -> Newline
String unescapeQuotedValue(String s) {
  if (s.isEmpty) return '';

  // Matches a backslash followed by \, ", n, or N
  final pattern = RegExp(r'\\[\\"nN]');

  return s.replaceAllMapped(pattern, (match) {
    final m = match[0]!;
    final char = m[1];

    switch (char) {
      case 'n':
      case 'N':
        return '\n';
      case '\\':
        return '\\';
      case '"':
        return '"';
      default:
        return char; // Fallback: return the character as-is (unreachable with current regex)
    }
  });
}
