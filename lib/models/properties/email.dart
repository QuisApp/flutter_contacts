import '../../utils/json_helpers.dart';
import '../labels/label.dart';
import '../labels/email_label.dart';
import 'property_metadata.dart';

/// Email address property.
class Email {
  /// Email address.
  final String address;

  /// Whether this is the primary email address (Android only).
  ///
  /// Only one email can be primary. Used by default when tapping "email".
  final bool? isPrimary;

  /// Email label type.
  ///
  /// Defaults to [EmailLabel.home].
  final Label<EmailLabel> label;

  /// Property identity metadata (used internally for updates).
  final PropertyMetadata? metadata;

  const Email({
    required this.address,
    this.isPrimary,
    Label<EmailLabel>? label,
    this.metadata,
  }) : label = label ?? const Label(EmailLabel.home);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'address': address};
    JsonHelpers.encode(json, 'isPrimary', isPrimary);
    json['label'] = label.toJson();
    JsonHelpers.encode(json, 'metadata', metadata, (m) => m.toJson());
    return json;
  }

  static Email fromJson(Map json) => Email(
    address: json['address'] as String,
    isPrimary: JsonHelpers.decode<bool>(json['isPrimary']),
    label: Label.fromJson(
      json['label'] as Map,
      EmailLabel.values,
      EmailLabel.home,
    ),
    metadata: JsonHelpers.decode(json['metadata'], PropertyMetadata.fromJson),
  );

  @override
  String toString() => JsonHelpers.formatToString('Email', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Email &&
          address == other.address &&
          isPrimary == other.isPrimary &&
          label == other.label);

  @override
  int get hashCode => Object.hash(address, isPrimary, label);

  Email copyWith({
    String? address,
    bool? isPrimary,
    Label<EmailLabel>? label,
    PropertyMetadata? metadata,
  }) => Email(
    address: address ?? this.address,
    isPrimary: isPrimary ?? this.isPrimary,
    label: label ?? this.label,
    metadata: metadata ?? this.metadata,
  );
}
