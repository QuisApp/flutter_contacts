import '../../utils/json_helpers.dart';
import '../labels/label.dart';
import '../labels/address_label.dart';
import 'property_metadata.dart';

/// Postal address property.
///
/// [formatted] is the full formatted address string. All other fields except [label]
/// are structured components.
///
/// When reading: Use [formatted] for display (always available).
///
/// When creating/updating: Use component fields when possible. Use [formatted]
/// only when components aren't available.
///
/// Platform differences:
/// - Android stores both formatted and components independently.
/// - iOS only stores components; [formatted] is generated from components when reading.
///
/// | Field                  | Android | iOS |
/// |------------------------|:-------:|:---:|
/// | formatted              | ✔       | ✔   |
/// | street                 | ✔       | ✔   |
/// | city                   | ✔       | ✔   |
/// | state                  | ✔       | ✔   |
/// | postalCode             | ✔       | ✔   |
/// | country                | ✔       | ✔   |
/// | poBox                  | ✔       | ⨯   |
/// | neighborhood           | ✔       | ⨯   |
/// | isoCountryCode         | ⨯       | ✔   |
/// | subAdministrativeArea  | ⨯       | ✔   |
/// | subLocality            | ⨯       | ✔   |
class Address {
  /// Formatted address string.
  final String? formatted;

  /// Street address.
  final String? street;

  /// City.
  final String? city;

  /// State or province.
  final String? state;

  /// Postal or ZIP code.
  final String? postalCode;

  /// Country name.
  final String? country;

  /// ISO 3166-1 alpha-2 country code (iOS only, e.g., "US", "GB", "FR").
  final String? isoCountryCode;

  /// Sub-administrative area (iOS only, e.g., county).
  final String? subAdministrativeArea;

  /// Sub-locality (iOS only, e.g., neighborhood or district).
  final String? subLocality;

  /// P.O. Box (Android only, e.g., "PO Box 123").
  final String? poBox;

  /// Neighborhood (Android only, e.g., "Greenwich Village").
  final String? neighborhood;

  /// Address label type.
  ///
  /// Defaults to [AddressLabel.home].
  final Label<AddressLabel> label;

  /// Property identity metadata (used internally for updates).
  final PropertyMetadata? metadata;

  const Address({
    this.formatted,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.isoCountryCode,
    this.subAdministrativeArea,
    this.subLocality,
    this.poBox,
    this.neighborhood,
    Label<AddressLabel>? label,
    this.metadata,
  }) : label = label ?? const Label(AddressLabel.home);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    JsonHelpers.encode(json, 'formatted', formatted);
    JsonHelpers.encode(json, 'street', street);
    JsonHelpers.encode(json, 'city', city);
    JsonHelpers.encode(json, 'state', state);
    JsonHelpers.encode(json, 'postalCode', postalCode);
    JsonHelpers.encode(json, 'country', country);
    JsonHelpers.encode(json, 'isoCountryCode', isoCountryCode);
    JsonHelpers.encode(json, 'subAdministrativeArea', subAdministrativeArea);
    JsonHelpers.encode(json, 'subLocality', subLocality);
    JsonHelpers.encode(json, 'poBox', poBox);
    JsonHelpers.encode(json, 'neighborhood', neighborhood);
    json['label'] = label.toJson();
    JsonHelpers.encode(json, 'metadata', metadata, (m) => m.toJson());
    return json;
  }

  static Address fromJson(Map json) {
    return Address(
      formatted: JsonHelpers.decode<String>(json['formatted']),
      street: JsonHelpers.decode<String>(json['street']),
      city: JsonHelpers.decode<String>(json['city']),
      state: JsonHelpers.decode<String>(json['state']),
      postalCode: JsonHelpers.decode<String>(json['postalCode']),
      country: JsonHelpers.decode<String>(json['country']),
      isoCountryCode: JsonHelpers.decode<String>(json['isoCountryCode']),
      subAdministrativeArea: JsonHelpers.decode<String>(
        json['subAdministrativeArea'],
      ),
      subLocality: JsonHelpers.decode<String>(json['subLocality']),
      poBox: JsonHelpers.decode<String>(json['poBox']),
      neighborhood: JsonHelpers.decode<String>(json['neighborhood']),
      label: Label.fromJson(
        json['label'] as Map,
        AddressLabel.values,
        AddressLabel.home,
      ),
      metadata: JsonHelpers.decode(json['metadata'], PropertyMetadata.fromJson),
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('Address', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Address &&
          formatted == other.formatted &&
          street == other.street &&
          city == other.city &&
          state == other.state &&
          postalCode == other.postalCode &&
          country == other.country &&
          isoCountryCode == other.isoCountryCode &&
          subAdministrativeArea == other.subAdministrativeArea &&
          subLocality == other.subLocality &&
          poBox == other.poBox &&
          neighborhood == other.neighborhood &&
          label == other.label);

  @override
  int get hashCode => Object.hash(
    formatted,
    street,
    city,
    state,
    postalCode,
    country,
    isoCountryCode,
    subAdministrativeArea,
    subLocality,
    poBox,
    neighborhood,
    label,
  );

  Address copyWith({
    String? formatted,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? isoCountryCode,
    String? subAdministrativeArea,
    String? subLocality,
    String? poBox,
    String? neighborhood,
    Label<AddressLabel>? label,
    PropertyMetadata? metadata,
  }) => Address(
    formatted: formatted ?? this.formatted,
    street: street ?? this.street,
    city: city ?? this.city,
    state: state ?? this.state,
    postalCode: postalCode ?? this.postalCode,
    country: country ?? this.country,
    isoCountryCode: isoCountryCode ?? this.isoCountryCode,
    subAdministrativeArea: subAdministrativeArea ?? this.subAdministrativeArea,
    subLocality: subLocality ?? this.subLocality,
    poBox: poBox ?? this.poBox,
    neighborhood: neighborhood ?? this.neighborhood,
    label: label ?? this.label,
    metadata: metadata ?? this.metadata,
  );
}
