import '../../../models/labels/label.dart';
import '../core/version.dart';
import '../utils/encoding/encoding.dart';
import '../utils/formatting/params.dart';
import '../utils/encoding/quoted_printable.dart';

/// Writes a vCard property with proper formatting, encoding, and folding.
///
/// Automatically skips null or empty values (except for required fields).
/// Handles version-specific encoding and escaping.
void writeProperty(
  StringBuffer buffer,
  String key,
  String? value, {
  required VCardVersion version,
  List<String>? params,
  bool isBase64 = false,
}) {
  // Skip null or empty values except for required fields
  final requiredFields = version.isV4 ? ['N', 'FN', 'KIND'] : ['N', 'FN'];
  if ((value == null || value.isEmpty) && !requiredFields.contains(key)) {
    return;
  }

  final finalValue = (value ?? '').trim();
  var attributes = '';
  final paramList = params ?? [];

  String encodedValue = finalValue;
  if (!isBase64) {
    if (needsQuotedPrintable(value, version)) {
      // vCard 2.1: Use quoted-printable for non-ASCII content
      // vCard 3.0+ uses UTF-8 with escaping instead.
      paramList.addAll([
        '${paramName('CHARSET', version)}=UTF-8',
        '${paramName('ENCODING', version)}=QUOTED-PRINTABLE',
      ]);
      encodedValue = QuotedPrintable.encode(finalValue);
    } else if (version.isV3OrV4 &&
        !key.endsWith('.N') &&
        !key.endsWith('.ADR') &&
        !key.endsWith('.ORG') &&
        !key.endsWith('.PHOTO') &&
        key != 'N' &&
        key != 'ADR' &&
        key != 'ORG' &&
        key != 'PHOTO') {
      // vCard 2.1 doesn't require escaping special characters - it uses Quoted-Printable
      // encoding for non-ASCII content instead. vCard 3.0+ (RFC 2426, RFC 6350) requires
      // escaping of backslash, semicolon, comma, and newlines in text values.
      // Structured fields (N, ADR, ORG, PHOTO) handle their own escaping.
      // Note: Grouped properties (e.g., item3.ADR) also need to be excluded.
      encodedValue = escapeValue(finalValue);
    }
  }

  if (paramList.isNotEmpty) {
    attributes = ';${paramList.join(';')}';
  }

  final prefix = '$key$attributes:';

  if (isBase64) {
    buffer.write('$prefix\r\n');
    _writeBase64(buffer, encodedValue);
  } else {
    _writeFoldedLine(buffer, '$prefix$encodedValue');
  }
}

/// Writes a labeled property with automatic grouping for custom/non-standard labels.
void writeLabeledProperty<T extends Enum>(
  StringBuffer buffer,
  String property,
  String value, {
  required Label<T> label,
  required bool shouldGroup,
  required List<String> types,
  required VCardVersion version,
  required int Function() incrementGroup,
  List<String> additionalParams = const [],
  bool isPrimary = false,
}) {
  final labelText = label.customLabel ?? label.label.name;
  final finalTypes = types.map((t) => toTypeCase(t, version)).toList();
  final params = buildParams(
    types: finalTypes,
    version: version,
    isPrimary: isPrimary,
  );
  params.addAll(additionalParams);

  if (shouldGroup) {
    // Group non-standard labels for v3.0/v4.0
    final group = 'item${incrementGroup()}';
    _writeGroupedProperty(
      buffer,
      group,
      property,
      value,
      labelText,
      version: version,
      params: params,
    );
  } else {
    // Standard labels or v2.1 (which uses fallback types directly)
    writeProperty(buffer, property, value, version: version, params: params);
  }
}

/// Writes a grouped property with X-ABLabel.
void _writeGroupedProperty(
  StringBuffer buffer,
  String group,
  String property,
  String value,
  String labelText, {
  required VCardVersion version,
  List<String>? params,
}) {
  writeProperty(
    buffer,
    '$group.$property',
    value,
    version: version,
    params: params,
  );
  writeProperty(buffer, '$group.X-ABLabel', labelText, version: version);
}

/// Folds a line according to vCard specification.
void _writeFoldedLine(StringBuffer buffer, String line) {
  const firstLineLength = 75;
  const continuationLength = 74;

  if (line.length <= firstLineLength) {
    buffer.write('$line\r\n');
    return;
  }

  buffer.write('${line.substring(0, firstLineLength)}\r\n');
  for (int i = firstLineLength; i < line.length; i += continuationLength) {
    final end = i + continuationLength < line.length
        ? i + continuationLength
        : line.length;
    buffer.write(' ${line.substring(i, end)}\r\n');
  }
}

/// Folds base64-encoded data according to vCard specification.
void _writeBase64(StringBuffer buffer, String base64Data) {
  const lineLength = 72;
  for (int i = 0; i < base64Data.length; i += lineLength) {
    final end = i + lineLength < base64Data.length
        ? i + lineLength
        : base64Data.length;
    buffer.write(' ${base64Data.substring(i, end)}\r\n');
  }
}
