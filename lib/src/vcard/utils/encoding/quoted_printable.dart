import 'dart:convert';

/// Quoted-Printable encoding (RFC 2045).
///
/// Implements the Quoted-Printable Content-Transfer-Encoding as specified
/// in RFC 2045 section 6.7.
///
/// Reference: https://www.ietf.org/rfc/rfc2045.txt
class QuotedPrintable {
  QuotedPrintable._();

  // ASCII character codes
  static const int _cr = 13; // Carriage Return
  static const int _lf = 10; // Line Feed
  static const int _tab = 9; // Tab
  static const int _space = 32; // Space
  static const int _equals = 61; // '='
  static const int _printableStart = 33; // First printable (after space)
  static const int _printableEnd = 126; // Last printable ASCII

  /// Encodes a string to Quoted-Printable format (RFC 2045).
  ///
  /// Escapes newlines (\r, \n, \r\n) as literal backslash sequences (\\r, \\n)
  /// before encoding.
  ///
  /// RFC 2045 Rules:
  /// 1. General 8-bit representation: Any octet may be represented by "=XX"
  /// 2. Literal representation: Octets 33-60 and 62-126 may be represented as themselves
  /// 3. Whitespace: Octets 9 (TAB) and 32 (SPACE) may be represented as themselves,
  ///    but MUST be encoded if they appear at the end of a line (immediately before CRLF
  ///    or at end-of-data)
  /// 4. Line breaks: CRLF sequences must be preserved as CRLF
  /// 5. Soft line breaks: Lines must not exceed 76 characters; use "=\r\n" to break
  ///
  /// Implementation uses maxContentLength = 75 to reserve space for the soft
  /// break "=" character, keeping lines ≤ 76 chars per rule 5.
  static String encode(String s) {
    final escaped = s.replaceAll('\r', '\\r').replaceAll('\n', '\\n');
    final bytes = utf8.encode(escaped);
    return _encode(bytes);
  }

  /// Decodes a Quoted-Printable string (RFC 2045).
  ///
  /// Unescapes literal backslash sequences (\\r, \\n) that were escaped during encoding.
  ///
  /// Handles:
  /// - =XX hex sequences
  /// - Soft line breaks (= followed by CRLF)
  /// - Literal CRLF sequences
  static String decode(String s) {
    final bytes = _decode(s);
    final decoded = utf8.decode(bytes);
    return decoded.replaceAll('\\r', '\r').replaceAll('\\n', '\n');
  }

  /// Encodes bytes to Quoted-Printable per RFC 2045.
  static String _encode(List<int> bytes) {
    final buffer = StringBuffer();
    var lineLength = 0;
    const maxContentLength = 75;
    final pendingWhitespace = <int>[];

    /// Writes representation with soft line break handling.
    void write(String rep, int len) {
      // Rule 5: Insert "=\r\n" if line would exceed 75 chars
      if (lineLength + len > maxContentLength) {
        buffer.write('=\r\n');
        lineLength = 0;
      }
      buffer.write(rep);
      lineLength += len;
    }

    /// Flushes buffered whitespace (rule 3). Whitespace is buffered until status is known.
    ///
    /// Buffering avoids an O(N²) look-ahead approach. A naive implementation would
    /// scan forward from each whitespace character to decide if it is trailing. By buffering
    /// whitespace and flushing it when the next non-whitespace byte or line break is seen,
    /// each byte is processed once, yielding O(N).
    ///
    /// Status determined by next character:
    ///   - CRLF or EOF → trailing (encoded as =20 or =09)
    ///   - Non-whitespace → non-trailing (written literally)
    void flushWhitespace({required bool isTrailing}) {
      for (final ws in pendingWhitespace) {
        final rep = isTrailing
            ? (ws == _space ? '=20' : '=09')
            : String.fromCharCode(ws);
        final len = isTrailing ? 3 : 1;
        write(rep, len);
      }
      pendingWhitespace.clear();
    }

    for (var i = 0; i < bytes.length; i++) {
      final byte = bytes[i];

      // Rule 4: Hard line break (CRLF) - flush whitespace as trailing, preserve CRLF
      if (byte == _cr && i + 1 < bytes.length && bytes[i + 1] == _lf) {
        flushWhitespace(isTrailing: true);
        buffer.write('\r\n');
        lineLength = 0;
        i++;
        continue;
      }

      // Rule 3: Whitespace - buffer for later (status unknown until next char or EOF)
      if (byte == _space || byte == _tab) {
        pendingWhitespace.add(byte);
        continue;
      }

      // Non-whitespace: flush buffered whitespace as internal, then encode byte
      flushWhitespace(isTrailing: false);

      // Rules 1-2: Safe chars (33-126 except =) are literal; others encoded as =XX
      final isSafe =
          byte >= _printableStart && byte <= _printableEnd && byte != _equals;
      final rep = isSafe
          ? String.fromCharCode(byte)
          : '=${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}';
      final len = isSafe ? 1 : 3;
      write(rep, len);
    }

    // Rule 3: Flush remaining whitespace as trailing
    flushWhitespace(isTrailing: true);

    return buffer.toString();
  }

  /// Decodes bytes from Quoted-Printable per RFC 2045.
  ///
  /// Handles:
  /// - =XX hex sequences
  /// - Soft line breaks (= followed by CRLF)
  /// - Literal CRLF sequences
  static List<int> _decode(String s) {
    final bytes = <int>[];

    for (var i = 0; i < s.length; i++) {
      final char = s[i];

      if (char == '=') {
        // Check for soft line break (=CRLF)
        if (i + 2 < s.length && s[i + 1] == '\r' && s[i + 2] == '\n') {
          i += 2; // Skip CRLF
          continue;
        }

        // Check for hex sequence (=XX)
        if (i + 2 < s.length) {
          final hex = s.substring(i + 1, i + 3);
          final byte = int.tryParse(hex, radix: 16);
          if (byte != null) {
            bytes.add(byte);
            i += 2; // Skip hex digits
            continue;
          }
        }

        // Invalid = sequence, treat as literal
        bytes.add(char.codeUnitAt(0));
      } else if (char == '\r' && i + 1 < s.length && s[i + 1] == '\n') {
        // Hard line break - preserve as CRLF
        bytes.add(_cr);
        bytes.add(_lf);
        i++; // Skip LF
      } else {
        bytes.add(char.codeUnitAt(0));
      }
    }

    return bytes;
  }
}
