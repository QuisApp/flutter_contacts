import '../../utils/json_helpers.dart';

/// Generic label wrapper that combines an enum label with an optional custom label string.
///
/// When [label] is a custom enum value (e.g., [PhoneLabel.custom], [EmailLabel.custom]),
/// [customLabel] must be provided.
///
/// When creating or updating contacts, unsupported labels on a platform are automatically
/// converted to the custom enum value with the original label name preserved in [customLabel].
class Label<T extends Enum> {
  /// The standard label type (e.g., [PhoneLabel.mobile], [EmailLabel.work]).
  final T label;

  /// Custom label string used when [label] is a custom enum value (e.g., [PhoneLabel.custom]).
  final String? customLabel;

  const Label(this.label, [this.customLabel]);

  /// Creates a [Label] from a JSON map.
  ///
  /// [json] - The JSON map containing 'label' and optionally 'customLabel'.
  /// [values] - The list of enum values to decode the label from.
  /// [defaultValue] - The default enum value to use if decoding fails.
  static Label<T> fromJson<T extends Enum>(
    Map json,
    List<T> values,
    T defaultValue,
  ) {
    return Label<T>(
      JsonHelpers.decodeEnum(json['label'], values, defaultValue),
      json['customLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label.name,
      if (customLabel != null) 'customLabel': customLabel,
    };
  }

  @override
  String toString() => JsonHelpers.formatToString('Label', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Label &&
          label == other.label &&
          customLabel == other.customLabel);

  @override
  int get hashCode => Object.hash(label, customLabel);

  Label<T> copyWith({T? label, String? customLabel}) =>
      Label<T>(label ?? this.label, customLabel ?? this.customLabel);
}
