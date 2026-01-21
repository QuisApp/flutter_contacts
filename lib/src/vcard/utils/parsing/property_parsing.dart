import '../../../../models/labels/label.dart';
import '../../core/property.dart';
import '../../core/constants.dart';
import 'split.dart';
import '../encoding/encoding.dart';

/// Parses a labeled property (phone, email, address, relation, etc.).
///
/// Handles common logic:
/// - Extracts types from TYPE parameter
/// - Parses label using the provided label parser
/// - Transforms the value using the provided transformer
/// - Constructs the result object using the provided constructor
T parseProperty<T, L extends Enum>(
  VCardProperty prop,
  String? groupLabel,
  Label<L> Function(List<String> types, String? groupLabel) labelParser,
  T Function(String value, Label<L> label, Map<String, String?> params)
  propertyBuilder,
) {
  final types = _parseTypes(prop.params);
  final label = labelParser(types, groupLabel);
  return propertyBuilder(prop.value, label, prop.params);
}

/// Extracts types from vCard parameters.
///
/// Supports:
/// - TYPE=WORK,VOICE or TYPE=a;TYPE=b
/// - Bare flags (e.g., TEL;WORK;VOICE)
/// - X- extensions (e.g., TEL;X-School or TEL;TYPE=X-School)
///
/// Returns type strings preserving original case (with X- prefix stripped).
/// Excludes 'pref' from types (handled separately by isPrimaryProperty).
List<String> _parseTypes(Map<String, String?> params) {
  // Strips x- prefix from type string if present (preserves case).
  String normalizeType(String type) {
    final lower = type.toLowerCase();
    return lower.startsWith('x-') ? type.substring(2) : type;
  }

  final types = <String>{};

  // Get types from TYPE parameter
  final typeValue = params['type'];
  if (typeValue != null) {
    splitByComma(typeValue).forEach((t) {
      final type = t.trim();
      if (type.isNotEmpty && type.toLowerCase() != 'pref') {
        types.add(normalizeType(type));
      }
    });
  }

  // Get types from bare flags (null value means it's a flag, not a parameter)
  params.forEach((key, value) {
    if (value == null && !standardParams.contains(key.toLowerCase())) {
      types.add(normalizeType(key));
    }
  });

  return types.toList();
}

/// Checks if a property is marked as primary/preferred.
///
/// Supports: vCard 2.1 (PREF flag), vCard 3.0 (PREF in TYPE or flag), vCard 4.0 (PREF=1).
bool isPrimaryProperty(Map<String, String?> params) {
  // Check PREF parameter (vCard 2.1/3.0: null, vCard 4.0: '1')
  final pref = params['pref'];
  if (pref != null) {
    if (pref == '1') return true;
    final prefNum = int.tryParse(pref);
    if (prefNum != null && prefNum == 1) return true;
  } else if (params.containsKey('pref')) {
    // Bare flag (vCard 2.1/3.0): null value means PREF is set
    return true;
  }

  // Check PREF in TYPE parameter (vCard 3.0: TYPE=WORK,PREF)
  final typeValue = params['type'];
  if (typeValue == null) return false;
  return splitByComma(typeValue).any((t) => t.trim().toLowerCase() == 'pref');
}

/// Parses semicolon-separated components from a value string.
///
/// Splits by ';' (respecting escaped semicolons), takes the first [count] components,
/// pads to [count] if needed, unescapes each component, and converts empty strings to null.
List<String?> parseComponents(String value, int count) {
  final allParts = splitBySemicolon(value);
  final parts = allParts.take(count).toList();
  while (parts.length < count) {
    parts.add('');
  }

  return parts.map((s) {
    final unescaped = unescapeValue(s.trim());
    return unescaped.isEmpty ? null : unescaped;
  }).toList();
}
