import '../../utils/json_helpers.dart';
import '../labels/label.dart';
import '../labels/relation_label.dart';
import 'property_metadata.dart';

/// Relationship property.
class Relation {
  /// Name of the related person.
  final String name;

  /// Relationship label type.
  ///
  /// Defaults to [RelationLabel.other].
  final Label<RelationLabel> label;

  /// Property identity metadata (used internally for updates).
  final PropertyMetadata? metadata;

  const Relation({
    required this.name,
    Label<RelationLabel>? label,
    this.metadata,
  }) : label = label ?? const Label(RelationLabel.other);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'name': name};
    json['label'] = label.toJson();
    JsonHelpers.encode(json, 'metadata', metadata, (m) => m.toJson());
    return json;
  }

  static Relation fromJson(Map json) => Relation(
    name: json['name'] as String,
    label: Label.fromJson(
      json['label'] as Map,
      RelationLabel.values,
      RelationLabel.other,
    ),
    metadata: JsonHelpers.decode(json['metadata'], PropertyMetadata.fromJson),
  );

  @override
  String toString() => JsonHelpers.formatToString('Relation', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Relation && name == other.name && label == other.label);

  @override
  int get hashCode => Object.hash(name, label);

  Relation copyWith({
    String? name,
    Label<RelationLabel>? label,
    PropertyMetadata? metadata,
  }) => Relation(
    name: name ?? this.name,
    label: label ?? this.label,
    metadata: metadata ?? this.metadata,
  );
}
