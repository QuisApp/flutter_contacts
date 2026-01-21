import '../../utils/json_helpers.dart';
import '../labels/label.dart';
import '../labels/social_media_label.dart';
import 'property_metadata.dart';

/// Social media profile property.
class SocialMedia {
  /// Social media username.
  final String username;

  /// Social media label type.
  ///
  /// Defaults to [SocialMediaLabel.other].
  final Label<SocialMediaLabel> label;

  /// Property identity metadata (used internally for updates).
  final PropertyMetadata? metadata;

  const SocialMedia({
    required this.username,
    Label<SocialMediaLabel>? label,
    this.metadata,
  }) : label = label ?? const Label(SocialMediaLabel.other);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'username': username};
    json['label'] = label.toJson();
    JsonHelpers.encode(json, 'metadata', metadata, (m) => m.toJson());
    return json;
  }

  static SocialMedia fromJson(Map json) => SocialMedia(
    username: json['username'] as String,
    label: Label.fromJson(
      json['label'] as Map,
      SocialMediaLabel.values,
      SocialMediaLabel.other,
    ),
    metadata: JsonHelpers.decode(json['metadata'], PropertyMetadata.fromJson),
  );

  @override
  String toString() => JsonHelpers.formatToString('SocialMedia', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocialMedia &&
          username == other.username &&
          label == other.label);

  @override
  int get hashCode => Object.hash(username, label);

  SocialMedia copyWith({
    String? username,
    Label<SocialMediaLabel>? label,
    PropertyMetadata? metadata,
  }) => SocialMedia(
    username: username ?? this.username,
    label: label ?? this.label,
    metadata: metadata ?? this.metadata,
  );
}
