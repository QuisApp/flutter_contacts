import '../../utils/json_helpers.dart';
import '../labels/label.dart';
import '../labels/website_label.dart';
import 'property_metadata.dart';

/// Website URL property.
class Website {
  /// Website URL.
  final String url;

  /// Website label type.
  ///
  /// Defaults to [WebsiteLabel.homepage].
  final Label<WebsiteLabel> label;

  /// Property identity metadata (used internally for updates).
  final PropertyMetadata? metadata;

  const Website({required this.url, Label<WebsiteLabel>? label, this.metadata})
    : label = label ?? const Label(WebsiteLabel.homepage);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'url': url};
    json['label'] = label.toJson();
    JsonHelpers.encode(json, 'metadata', metadata, (m) => m.toJson());
    return json;
  }

  static Website fromJson(Map json) => Website(
    url: json['url'] as String,
    label: Label.fromJson(
      json['label'] as Map,
      WebsiteLabel.values,
      WebsiteLabel.homepage,
    ),
    metadata: JsonHelpers.decode(json['metadata'], PropertyMetadata.fromJson),
  );

  @override
  String toString() => JsonHelpers.formatToString('Website', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Website && url == other.url && label == other.label);

  @override
  int get hashCode => Object.hash(url, label);

  Website copyWith({
    String? url,
    Label<WebsiteLabel>? label,
    PropertyMetadata? metadata,
  }) => Website(
    url: url ?? this.url,
    label: label ?? this.label,
    metadata: metadata ?? this.metadata,
  );
}
