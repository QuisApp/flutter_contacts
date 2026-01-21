import '../../../../models/properties/address.dart';
import '../../../../models/labels/address_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/property.dart';
import '../../utils/parsing/property_parsing.dart';
import '../../utils/parsing/split.dart';
import '../../utils/encoding/encoding.dart';
import 'address_label.dart';

/// Parses ADR property into Address object.
Address parseAddress(VCardProperty prop, [String? groupLabel]) {
  return parseProperty<
    Address,
    AddressLabel
  >(prop, groupLabel, parseAddressLabel, (
    String value,
    Label<AddressLabel> label,
    Map<String, String?> params,
  ) {
    final components = splitBySemicolon(value).map((s) => s.trim()).toList();
    while (components.length < 7) {
      components.add('');
    }

    // ADR has 7 components: poBox, extended, street, city, state, postalCode, country
    // Extended address (components[1]) is not in our model, so we skip it.
    final values = [
      unescapeValue(components[0]), // poBox
      unescapeValue(components[2]), // street
      unescapeValue(components[3]), // city
      unescapeValue(components[4]), // state
      unescapeValue(components[5]), // postalCode
      unescapeValue(components[6]), // country
    ];

    return Address(
      formatted: params['label'] != null
          ? unescapeQuotedValue(params['label']!)
          : null,
      poBox: values[0].isEmpty ? null : values[0],
      street: values[1].isEmpty ? null : values[1],
      city: values[2].isEmpty ? null : values[2],
      state: values[3].isEmpty ? null : values[3],
      postalCode: values[4].isEmpty ? null : values[4],
      country: values[5].isEmpty ? null : values[5],
      label: label,
    );
  });
}
