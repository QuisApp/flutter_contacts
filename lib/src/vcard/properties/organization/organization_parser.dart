import '../../../../models/properties/organization.dart';
import '../../core/property.dart';
import '../../utils/parsing/property_parsing.dart';

/// Parses ORG property and returns Organization object.
Organization parseOrganization(VCardProperty prop) {
  final components = parseComponents(prop.value, 2);

  return Organization(name: components[0], departmentName: components[1]);
}
