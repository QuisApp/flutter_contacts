import '../../../../models/contact/contact.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';
import 'relation_label.dart';

/// Writes relation properties (RELATED/X-RELATION).
///
/// RFC sections:
/// - vCard 2.1/3.0: X-RELATION (non-standard)
/// - vCard 4.0: RFC 6350 Section 6.6.6 (RELATED)
void writeRelations(
  StringBuffer buffer,
  Contact contact,
  VCardVersion version, {
  required int Function() incrementGroup,
}) {
  for (final rel in contact.relations) {
    writeLabeledProperty(
      buffer,
      version.isV4 ? 'RELATED' : 'X-RELATION',
      rel.name,
      label: rel.label,
      shouldGroup: shouldGroupRelation(rel.label.label, version),
      types: getRelationTypes(rel.label.label, version),
      version: version,
      incrementGroup: incrementGroup,
      additionalParams: version.isV4 ? ['value=text'] : [],
    );
  }
}
