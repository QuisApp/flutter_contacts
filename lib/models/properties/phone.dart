import '../../utils/json_helpers.dart';
import '../labels/label.dart';
import '../labels/phone_label.dart';
import 'property_metadata.dart';

/// Phone number property.
class Phone {
  /// Phone number.
  final String number;

  /// Normalized phone number in E.164 format (Android only).
  final String? normalizedNumber;

  /// Whether this is the primary phone number (Android only).
  ///
  /// Only one phone can be primary. Used by default when tapping "call" or "text".
  final bool? isPrimary;

  /// Phone label type.
  ///
  /// Defaults to [PhoneLabel.mobile].
  final Label<PhoneLabel> label;

  /// Property identity metadata (used internally for updates).
  final PropertyMetadata? metadata;

  const Phone({
    required this.number,
    this.normalizedNumber,
    this.isPrimary,
    Label<PhoneLabel>? label,
    this.metadata,
  }) : label = label ?? const Label(PhoneLabel.mobile);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'number': number};
    JsonHelpers.encode(json, 'normalizedNumber', normalizedNumber);
    JsonHelpers.encode(json, 'isPrimary', isPrimary);
    json['label'] = label.toJson();
    JsonHelpers.encode(json, 'metadata', metadata, (m) => m.toJson());
    return json;
  }

  static Phone fromJson(Map json) => Phone(
    number: json['number'] as String,
    normalizedNumber: JsonHelpers.decode<String>(json['normalizedNumber']),
    isPrimary: JsonHelpers.decode<bool>(json['isPrimary']),
    label: Label.fromJson(
      json['label'] as Map,
      PhoneLabel.values,
      PhoneLabel.mobile,
    ),
    metadata: JsonHelpers.decode(json['metadata'], PropertyMetadata.fromJson),
  );

  @override
  String toString() => JsonHelpers.formatToString('Phone', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Phone &&
          number == other.number &&
          normalizedNumber == other.normalizedNumber &&
          isPrimary == other.isPrimary &&
          label == other.label);

  @override
  int get hashCode => Object.hash(number, normalizedNumber, isPrimary, label);

  Phone copyWith({
    String? number,
    String? normalizedNumber,
    bool? isPrimary,
    Label<PhoneLabel>? label,
    PropertyMetadata? metadata,
  }) => Phone(
    number: number ?? this.number,
    normalizedNumber: normalizedNumber ?? this.normalizedNumber,
    isPrimary: isPrimary ?? this.isPrimary,
    label: label ?? this.label,
    metadata: metadata ?? this.metadata,
  );
}
