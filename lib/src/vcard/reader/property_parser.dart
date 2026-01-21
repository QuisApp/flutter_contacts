import '../core/property.dart';
import '../core/constants.dart';
import '../utils/encoding/quoted_printable.dart';
import '../utils/encoding/encoding.dart';

/// Supported vCard property names (whitelist).
const _supportedProperties = {
  // Standard properties
  'UID',
  'FN',
  'N',
  'NICKNAME',
  'TEL',
  'EMAIL',
  'ADR',
  'ORG',
  'TITLE',
  'ROLE',
  'URL',
  'BDAY',
  'ANNIVERSARY',
  'RELATED',
  'NOTE',
  'PHOTO',
  // Extended properties
  'X-NICKNAME',
  'X-PHONETIC-FIRST-NAME',
  'X-PHONETIC-MIDDLE-NAME',
  'X-PHONETIC-LAST-NAME',
  'X-JOB-DESCRIPTION',
  'X-ORG-SYMBOL',
  'X-ORG-OFFICE',
  'X-PHONETIC-ORG-NAME',
  'X-ANNIVERSARY',
  'X-EVENT',
  'X-RELATION',
  'X-SOCIALPROFILE',
  'X-ABLABEL',
  'X-ANDROID-STARRED',
  'X-ANDROID-CUSTOM-RINGTONE',
  'X-ANDROID-SEND-TO-VOICEMAIL',
};

/// Unfolds folded vCard lines (RFC 2425/RFC 6350).
///
/// Continuation lines start with a space or tab.
List<String> unfoldLines(List<String> lines) {
  final unfolded = <String>[];
  var current = '';

  for (final line in lines) {
    if (line.isNotEmpty && (line[0] == ' ' || line[0] == '\t')) {
      // Continuation line - append to current (without leading space)
      current += line.substring(1);
    } else {
      // New line - save previous and start new
      if (current.isNotEmpty) {
        unfolded.add(current);
      }
      current = line;
    }
  }

  if (current.isNotEmpty) {
    unfolded.add(current);
  }

  return unfolded;
}

/// Parses a single vCard property line.
VCardProperty? parsePropertyLine(String line) {
  final colonIndex = line.indexOf(':');
  if (colonIndex == -1) return null;

  final namePart = line.substring(0, colonIndex);
  var value = line.substring(colonIndex + 1);

  final parts = namePart.split(';');
  var name = parts[0];
  String? group;

  final dotIndex = name.indexOf('.');
  if (dotIndex != -1) {
    group = name.substring(0, dotIndex);
    name = name.substring(dotIndex + 1);
  }

  final params = <String, String?>{};
  for (var i = 1; i < parts.length; i++) {
    final param = parts[i];
    final equalsIndex = param.indexOf('=');
    if (equalsIndex == -1) {
      // Bare flag (vCard 2.1 style): preserve case for types, lowercase for standard params
      final key = standardParams.contains(param.toLowerCase())
          ? param.toLowerCase()
          : param;
      params[key] = null;
    } else {
      // Parameter with value: always lowercase the key
      final key = param.substring(0, equalsIndex).toLowerCase();
      var paramValue = param.substring(equalsIndex + 1);
      if (paramValue.startsWith('"') && paramValue.endsWith('"')) {
        // Quoted value: unescape and remove quotes
        paramValue = unescapeQuotedValue(
          paramValue.substring(1, paramValue.length - 1),
        );
      }
      // Multiple values for same param are comma-joined (e.g., TYPE=WORK,HOME)
      params[key] = params.containsKey(key)
          ? '${params[key]},$paramValue'
          : paramValue;
    }
  }

  final encoding = params['encoding']?.toUpperCase();
  if (encoding == 'QUOTED-PRINTABLE' || encoding == 'QP') {
    value = QuotedPrintable.decode(value);
  }

  final nameUpper = name.toUpperCase();
  if (!_supportedProperties.contains(nameUpper)) return null;

  if (group == null) {
    return RegularProperty(name: nameUpper, value: value, params: params);
  } else if (nameUpper == 'X-ABLABEL') {
    return LabelProperty(group: group, value: value);
  } else {
    return GroupedProperty(
      group: group,
      name: nameUpper,
      value: value,
      params: params,
    );
  }
}
