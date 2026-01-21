import '../../../../models/properties/relation.dart';
import '../../../../models/labels/relation_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/property.dart';
import '../../utils/parsing/property_parsing.dart';
import '../../utils/encoding/encoding.dart';
import 'relation_label.dart';

/// Parses relation property (RELATED/X-RELATION).
Relation parseRelation(VCardProperty prop, [String? groupLabel]) {
  return parseProperty<Relation, RelationLabel>(
    prop,
    groupLabel,
    parseRelationLabel,
    (String value, Label<RelationLabel> label, Map<String, String?> params) =>
        Relation(name: unescapeValue(value), label: label),
  );
}
