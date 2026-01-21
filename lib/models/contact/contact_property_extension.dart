import '../../utils/json_helpers.dart';
import 'contact_property.dart';

extension ContactPropertySet on Set<ContactProperty> {
  /// Converts a property set to a sorted list of enum names for platform calls.
  List<String> toJson() => map((p) => p.name).toList()..sort();
}

extension ContactPropertyList on List {
  /// Converts a list of enum name strings into a property set.
  Set<ContactProperty> toProperties() => whereType<String>()
      .map((name) => JsonHelpers.decodeEnum(name, ContactProperty.values))
      .toSet();
}
