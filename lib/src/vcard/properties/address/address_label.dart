import '../../../../models/labels/address_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/version.dart';
import '../../utils/parsing/label_parsing.dart';

/// Returns whether address label should be grouped (itemN. prefix).
/// v2.1 never groups; v3.0/v4.0 group non-standard labels.
bool shouldGroupAddress(AddressLabel label, VCardVersion version) {
  if (version.isV21) return false;
  switch (label) {
    case AddressLabel.home:
    case AddressLabel.work:
      return false;
    default:
      return true;
  }
}

/// Returns TYPE values for address label.
/// Non-standard: v2.1/v3.0 use fallback ['postal'], v4.0 uses [] (no TYPE when grouping).
List<String> getAddressTypes(AddressLabel label, VCardVersion version) {
  switch (label) {
    case AddressLabel.home:
      return ['home'];
    case AddressLabel.work:
      return ['work'];
    default:
      return version.isV21OrV3 ? ['postal'] : [];
  }
}

/// Parses address label from types and optional group label.
Label<AddressLabel> parseAddressLabel(List<String> types, String? groupLabel) {
  return parseLabel(
    types,
    groupLabel,
    AddressLabel.values,
    AddressLabel.custom,
    AddressLabel.home,
  );
}
