import '../../../../models/labels/label.dart';

/// Cleans a label string by removing Google's wrapper format.
///
/// Google sometimes uses `_$!<Label>!$_` format, so we strip the `_$!<` and `>!$_` delimiters.
/// Example: `_$!<Mobile>!$_` -> `Mobile`
String _cleanLabel(String label) {
  return label.replaceAll(RegExp(r'^_\$!<|>!\$_$'), '').trim();
}

/// Converts a string to a Label by matching against enum values.
///
/// Returns a Label with the matching enum value, or a custom label if no match.
Label<T> labelFromString<T extends Enum>(
  String label,
  List<T> enumValues,
  T customValue,
) {
  final cleaned = _cleanLabel(label);
  final lowercased = cleaned.toLowerCase();
  for (final enumValue in enumValues) {
    if (enumValue.name.toLowerCase() == lowercased) {
      return Label(enumValue);
    }
  }
  return Label(customValue, cleaned);
}

/// Parses a single label type string.
///
/// Returns null if type is null, ignored, or doesn't match anything.
/// Returns override value if type matches an override.
/// Otherwise uses labelFromString to parse the type.
Label<T>? _parseLabelType<T extends Enum>(
  String? type,
  List<T> enumValues,
  T customValue, {
  Set<String> ignored = const {},
  Map<String, T> overrides = const {},
}) {
  if (type == null) return null;
  final lower = type.trim().toLowerCase();
  if (ignored.contains(lower)) return null;
  if (overrides.containsKey(lower)) {
    return Label(overrides[lower]!);
  }
  return labelFromString(type, enumValues, customValue);
}

/// Parses a label from types and optional group label.
///
/// If groupLabel is provided, uses it directly.
/// Otherwise, loops through types and returns the first valid label.
/// Returns defaultLabel if no valid label is found.
Label<T> parseLabel<T extends Enum>(
  List<String> types,
  String? groupLabel,
  List<T> enumValues,
  T customValue,
  T defaultLabel, {
  Set<String> ignored = const {},
  Map<String, T> overrides = const {},
}) {
  if (groupLabel != null) {
    return labelFromString(groupLabel, enumValues, customValue);
  }
  for (final type in types) {
    final label = _parseLabelType(
      type,
      enumValues,
      customValue,
      ignored: ignored,
      overrides: overrides,
    );
    if (label != null) return label;
  }
  return Label(defaultLabel);
}
