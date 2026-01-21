/// Base class for all vCard properties.
abstract class VCardProperty {
  final String name;
  final String value;
  final Map<String, String?> params;

  VCardProperty({
    required this.name,
    required this.value,
    required this.params,
  });
}

/// Regular property without grouping (e.g., "TEL:+1234567890").
class RegularProperty extends VCardProperty {
  RegularProperty({
    required super.name,
    required super.value,
    required super.params,
  });
}

/// Grouped property with a group prefix (e.g., "item1.TEL:+1234567890").
class GroupedProperty extends VCardProperty {
  final String group;

  GroupedProperty({
    required this.group,
    required super.name,
    required super.value,
    required super.params,
  });
}

/// Label property for grouped properties (e.g., "item1.X-ABLABEL:Custom Label").
class LabelProperty extends VCardProperty {
  final String group;

  LabelProperty({required this.group, required super.value})
    : super(name: 'X-ABLABEL', params: {});
}
