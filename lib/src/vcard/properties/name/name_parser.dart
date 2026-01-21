import '../../../../models/properties/name.dart';
import '../../utils/parsing/property_parsing.dart';

/// Parses N property into Name object.
Name parseName(String value) {
  final components = parseComponents(value, 5);

  return Name(
    last: components[0],
    first: components[1],
    middle: components[2],
    prefix: components[3],
    suffix: components[4],
  );
}
