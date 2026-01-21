import '../../../../models/properties/website.dart';
import '../../core/property.dart';
import '../../utils/encoding/encoding.dart';

/// Parses URL property into Website object.
Website parseWebsite(VCardProperty prop) {
  return Website(url: unescapeValue(prop.value));
}
