/// Reusable encoding/decoding helpers for JSON maps and method channel results.
class JsonHelpers {
  /// Encodes an optional value to a JSON map if not null.
  ///
  /// [toJson] - Optional function to encode objects. If not provided, value is used directly.
  static void encode<T>(
    Map<String, dynamic> json,
    String key,
    T? value, [
    Map<String, dynamic> Function(T)? toJson,
  ]) {
    if (value != null) {
      json[key] = toJson != null ? toJson(value) : value;
    }
  }

  /// Encodes a list to a JSON map if not empty.
  static void encodeList<T>(
    Map<String, dynamic> json,
    String key,
    List<T> list,
    Map<String, dynamic> Function(T) toJson,
  ) {
    if (list.isNotEmpty) {
      json[key] = list.map(toJson).toList();
    }
  }

  /// Decodes an optional value from JSON maps or method channel results.
  ///
  /// [value] - The value to decode (typically `json[key]` or a method channel result).
  /// [fromJson] - Optional function to decode objects. If not provided, value is cast directly.
  static T? decode<T>(dynamic value, [T Function(Map)? fromJson]) {
    if (value == null) return null;
    if (fromJson != null) {
      return fromJson(value as Map);
    }
    return value as T?;
  }

  /// Decodes a list from JSON maps or method channel results, returning empty list if null.
  static List<T> decodeList<T>(List? value, T Function(Map) fromJson) {
    if (value == null) return const [];
    return value.map((e) => fromJson(e as Map)).toList();
  }

  /// Decodes an enum from its name string.
  ///
  /// [value] - The value to decode (will be cast to String). Can be null.
  /// [defaultValue] - Optional default value. If not provided, throws if [value] is null or doesn't match.
  /// Returns [defaultValue] if [value] is null or doesn't match (when provided), or throws otherwise.
  static T decodeEnum<T extends Enum>(
    dynamic value,
    List<T> values, [
    T? defaultValue,
  ]) {
    if (value == null) {
      if (defaultValue != null) return defaultValue;
      throw ArgumentError('Cannot decode null enum value');
    }
    final name = value as String;
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () {
        if (defaultValue != null) return defaultValue;
        throw ArgumentError('No enum value found for "$name"');
      },
    );
  }

  /// Builds a concise `toString` output from non-null fields.
  static String formatToString(String type, Map<String, Object?> fields) {
    final buffer = StringBuffer('$type(');
    var first = true;
    fields.forEach((key, value) {
      if (value == null) return;
      if (!first) buffer.write(', ');
      first = false;
      buffer.write('$key: $value');
    });
    buffer.write(')');
    return buffer.toString();
  }
}
