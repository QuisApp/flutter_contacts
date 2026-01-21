/// Splits a string by comma, respecting escaped commas.
///
/// Escaped commas (\,) are not treated as delimiters.
/// Escaped backslashes (\\) are handled correctly.
List<String> splitByComma(String s) => _splitByDelimiter(s, ',');

/// Splits a string by semicolon, respecting escaped semicolons.
///
/// Escaped semicolons (\;) are not treated as delimiters.
/// Escaped backslashes (\\) are handled correctly.
List<String> splitBySemicolon(String s) => _splitByDelimiter(s, ';');

/// Internal helper to split by a delimiter while respecting escape sequences.
///
/// A delimiter is only treated as a separator if it's not escaped.
/// A delimiter is escaped if it's preceded by an odd number of backslashes.
/// Examples:
/// - `\,` - escaped (1 backslash, odd) - don't split
/// - `\\,` - not escaped (2 backslashes, even) - split
/// - `\\\,` - escaped (3 backslashes, odd) - don't split
///
/// Note: Backslashes are preserved in output; unescapeValue handles final unescaping.
List<String> _splitByDelimiter(String s, String delimiter) {
  if (s.isEmpty) return [''];

  final parts = <String>[];
  var current = StringBuffer();
  var escaped = false;

  for (final char in s.codeUnits) {
    final c = String.fromCharCode(char);
    if (escaped) {
      // Previous char was backslash: this char is escaped (e.g., \, or \;)
      // Write it literally and clear escape flag
      current.write(c);
      escaped = false;
    } else if (c == '\\') {
      // Found backslash: write it (unescapeValue will process it later) and mark next char as escaped
      current.write(c);
      escaped = true;
    } else if (c == delimiter) {
      // Found unescaped delimiter: split here
      parts.add(current.toString());
      current.clear();
    } else {
      // Regular character: add to current part
      current.write(c);
    }
  }

  parts.add(current.toString());
  return parts;
}
