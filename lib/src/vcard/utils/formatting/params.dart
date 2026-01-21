import '../../core/version.dart';

/// Normalizes label for parameter values.
String normalizeLabel(String label, VCardVersion version) {
  return version.isV4
      ? label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-')
      : label.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '-');
}

/// Converts a type string to the appropriate case for the version.
String toTypeCase(String type, VCardVersion version) {
  return version.isV4 ? type.toLowerCase() : type.toUpperCase();
}

/// Returns parameter name in appropriate case for the version.
String paramName(String name, VCardVersion version) {
  return version.isV4 ? name.toLowerCase() : name.toUpperCase();
}

/// Gets the PREF format for the version.
String getPrefFormat(VCardVersion version) {
  return version.isV4 ? 'PREF=1' : 'PREF';
}

/// Formats TYPE parameter list (comma-separated, quoted if needed).
///
/// RFC 2426 (vCard 3.0): Parameter values with spaces should be quoted.
/// RFC 6350 (vCard 4.0): Parameter values with spaces or dashes should be quoted.
/// vCard 2.1: Less strict, but quoting spaces is safe for compatibility.
///
/// Note: `normalizeLabel` converts spaces to dashes for v2.1/v3.0, so spaces
/// shouldn't appear in practice, but we quote them for safety and RFC compliance.
String _formatTypeList(List<String> types, VCardVersion version) {
  final joined = types.join(',');

  // Quote if contains spaces (required by RFC 2426 for v3.0, safe for v2.1)
  if (joined.contains(' ')) {
    return '"$joined"';
  }

  // For v4.0, also quote if contains dashes (RFC 6350 requirement)
  if (version.isV4 && joined.contains('-')) {
    return '"$joined"';
  }

  return joined;
}

/// Builds TYPE parameter string from a list of types.
String buildTypeParam(List<String> types, VCardVersion version) {
  if (types.isEmpty) return '';
  return '${paramName('TYPE', version)}=${_formatTypeList(types, version)}';
}

/// Builds parameters list with TYPE and optional PREF.
List<String> buildParams({
  required List<String> types,
  required VCardVersion version,
  bool isPrimary = false,
}) {
  final params = <String>[];
  if (types.isNotEmpty) {
    params.add(buildTypeParam(types, version));
  }
  if (isPrimary) {
    params.add(getPrefFormat(version));
  }
  return params;
}
