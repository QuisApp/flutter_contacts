import '../../../../models/contact/contact.dart';
import '../../../../models/properties/address.dart';
import '../../core/version.dart';
import '../../writer/formatter.dart';
import '../../utils/encoding/encoding.dart';
import 'address_label.dart';

/// Writes ADR (address) properties.
///
/// RFC sections:
/// - vCard 2.1: ADR property
/// - vCard 3.0: RFC 2426 Section 3.2.1
/// - vCard 4.0: RFC 6350 Section 6.3.1
///
/// Handles custom/non-standard labels using grouping (vCard 3.0+) or fallback (vCard 2.1).
void writeAddresses(
  StringBuffer buffer,
  Contact contact,
  VCardVersion version, {
  required int Function() incrementGroup,
}) {
  for (final address in contact.addresses) {
    final additionalParams = _buildAdditionalParams(address, version);
    writeLabeledProperty(
      buffer,
      'ADR',
      _buildAddressValue(address, version),
      label: address.label,
      shouldGroup: shouldGroupAddress(address.label.label, version),
      types: getAddressTypes(address.label.label, version),
      version: version,
      incrementGroup: incrementGroup,
      additionalParams: additionalParams,
    );
  }
}

/// Builds the ADR property value from address components.
///
/// If no structured components exist, falls back to storing [formatted] in the street component.
String _buildAddressValue(Address address, VCardVersion version) {
  final hasComponents = [
    address.poBox,
    address.street,
    address.city,
    address.state,
    address.postalCode,
    address.country,
  ].any((v) => v?.isNotEmpty == true);

  // Fallback: if no components, use formatted address as street
  final street = hasComponents
      ? (address.street ?? '')
      : (address.formatted ?? '');

  final components = [
    address.poBox ?? '',
    '', // Extended (not in our model)
    street,
    address.city ?? '',
    address.state ?? '',
    address.postalCode ?? '',
    address.country ?? '',
  ];

  return version.isV3OrV4
      ? components.map((s) => escapeValue(s)).join(';')
      : components.join(';');
}

/// Builds additional parameters for vCard 4.0 LABEL property.
///
/// This allows specifying the formatted address as a LABEL parameter,
/// which is separate from the structured ADR components.
List<String> _buildAdditionalParams(Address address, VCardVersion version) {
  if (version.isV4 &&
      address.formatted != null &&
      address.formatted!.isNotEmpty) {
    return ['label="${escapeQuotedValue(address.formatted!)}"'];
  }
  return [];
}
