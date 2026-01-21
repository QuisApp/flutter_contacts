import '../../../../models/labels/relation_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/version.dart';
import '../../utils/parsing/label_parsing.dart';

/// Returns whether relation label should be grouped (itemN. prefix).
/// v2.1 never groups; v3.0 always groups (X-RELATION has no standard types);
/// v4.0 groups only non-standard labels (RELATED property).
bool shouldGroupRelation(RelationLabel label, VCardVersion version) {
  if (version.isV21) return false;
  if (!version.isV4) return true; // v3.0: X-RELATION always groups
  switch (label) {
    case RelationLabel.parent:
    case RelationLabel.mother:
    case RelationLabel.father:
    case RelationLabel.child:
    case RelationLabel.son:
    case RelationLabel.daughter:
    case RelationLabel.spouse:
    case RelationLabel.husband:
    case RelationLabel.wife:
    case RelationLabel.sibling:
    case RelationLabel.brother:
    case RelationLabel.sister:
    case RelationLabel.friend:
    case RelationLabel.colleague:
    case RelationLabel.other:
      return false;
    default:
      return true;
  }
}

/// Returns TYPE values for relation label.
/// RELATED property only available in v4.0; v2.1/v3.0 (X-RELATION) have no types.
List<String> getRelationTypes(RelationLabel label, VCardVersion version) {
  if (!version.isV4) return [];
  switch (label) {
    case RelationLabel.parent:
    case RelationLabel.mother:
    case RelationLabel.father:
      return ['parent'];
    case RelationLabel.child:
    case RelationLabel.son:
    case RelationLabel.daughter:
      return ['child'];
    case RelationLabel.spouse:
    case RelationLabel.husband:
    case RelationLabel.wife:
      return ['spouse'];
    case RelationLabel.sibling:
    case RelationLabel.brother:
    case RelationLabel.sister:
      return ['sibling'];
    case RelationLabel.friend:
      return ['friend'];
    case RelationLabel.colleague:
      return ['colleague'];
    case RelationLabel.other:
      return ['contact'];
    default:
      return [];
  }
}

/// Parses relation label from types and optional group label.
Label<RelationLabel> parseRelationLabel(
  List<String> types,
  String? groupLabel,
) {
  return parseLabel(
    types,
    groupLabel,
    RelationLabel.values,
    RelationLabel.custom,
    RelationLabel.other,
    overrides: {'contact': RelationLabel.other},
  );
}
