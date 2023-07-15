import 'package:flutter_contacts/config.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_contacts/vcard.dart';

/// Labeled postal address.
///
/// While structured components are available for compatibility with Android and
/// iOS, it is recommended to use only the formatted [address]. Even if the
/// native contact only has structured components (e.g. [street] and [city]),
/// the [address] is reconstructed from them, so it is guaranteed to always be
/// present.
///
/// | Field           | Android | iOS |
/// |-----------------|:-------:|:---:|
/// | street          | ✔       | ✔   |
/// | pobox           | ✔       | ⨯   |
/// | neighborhood    | ✔       | ⨯   |
/// | city            | ✔       | ✔   |
/// | state           | ✔       | ✔   |
/// | postalCode      | ✔       | ✔   |
/// | country         | ✔       | ✔   |
/// | isoCountry      | ⨯       | ✔   |
/// | subAdminArea    | ⨯       | ✔   |
/// | subLocality     | ⨯       | ✔   |
class Address {
  /// Formatted address.
  String address;

  /// Label (default [AddressLabel.home]).
  AddressLabel label;

  /// Custom label, if [label] is [AddressLabel.custom].
  String customLabel;

  /// Street name and house number.
  String street;

  /// PO box (Android only).
  String pobox;

  /// Neighborhood (Android only).
  String neighborhood;

  /// City.
  String city;

  /// US state, or region/department/county on Android.
  String state;

  /// Postal code / zip code.
  String postalCode;

  /// Country.
  String country;

  /// ISO 3166-1 alpha-2 standard (iOS only).
  String isoCountry;

  /// Region/county on iOS.
  String subAdminArea;

  /// Anything else describing the address (iOS only).
  String subLocality;

  Address(
    this.address, {
    this.label = AddressLabel.home,
    this.customLabel = '',
    this.street = '',
    this.pobox = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.country = '',
    this.isoCountry = '',
    this.subAdminArea = '',
    this.subLocality = '',
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        (json['address'] as String?) ?? '',
        label: _stringToAddressLabel[json['label'] as String? ?? ''] ??
            AddressLabel.home,
        customLabel: (json['customLabel'] as String?) ?? '',
        street: (json['street'] as String?) ?? '',
        pobox: (json['pobox'] as String?) ?? '',
        neighborhood: (json['neighborhood'] as String?) ?? '',
        city: (json['city'] as String?) ?? '',
        state: (json['state'] as String?) ?? '',
        postalCode: (json['postalCode'] as String?) ?? '',
        country: (json['country'] as String?) ?? '',
        isoCountry: (json['isoCountry'] as String?) ?? '',
        subAdminArea: (json['subAdminArea'] as String?) ?? '',
        subLocality: (json['subLocality'] as String?) ?? '',
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address,
        'label': _addressLabelToString[label],
        'customLabel': customLabel,
        'street': street,
        'pobox': pobox,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'isoCountry': isoCountry,
        'subAdminArea': subAdminArea,
        'subLocality': subLocality,
      };

  @override
  int get hashCode =>
      address.hashCode ^
      label.hashCode ^
      customLabel.hashCode ^
      street.hashCode ^
      pobox.hashCode ^
      neighborhood.hashCode ^
      city.hashCode ^
      state.hashCode ^
      postalCode.hashCode ^
      country.hashCode ^
      isoCountry.hashCode ^
      subAdminArea.hashCode ^
      subLocality.hashCode;

  @override
  bool operator ==(Object o) =>
      o is Address &&
      o.address == address &&
      o.label == label &&
      o.customLabel == customLabel &&
      o.street == street &&
      o.pobox == pobox &&
      o.neighborhood == neighborhood &&
      o.city == city &&
      o.state == state &&
      o.postalCode == postalCode &&
      o.country == country &&
      o.isoCountry == isoCountry &&
      o.subAdminArea == subAdminArea &&
      o.subLocality == subLocality;

  @override
  String toString() =>
      'Address(address=$address, label=$label, customLabel=$customLabel, '
      'street=$street, pobox=$pobox, neighborhood=$neighborhood, city=$city, '
      'state=$state, postalCode=$postalCode, country=$country, '
      'isoCountry=$isoCountry, subAdminArea=$subAdminArea, '
      'subLocality=$subLocality)';

  List<String> toVCard() {
    // ADR (V3): https://tools.ietf.org/html/rfc2426#section-3.2.1
    // ADR (V4): https://tools.ietf.org/html/rfc6350#section-6.3.1
    var s = 'ADR';
    if (FlutterContacts.config.vCardVersion == VCardVersion.v3) {
      switch (label) {
        case AddressLabel.home:
          s += ';TYPE=home';
          break;
        case AddressLabel.work:
          s += ';TYPE=work';
          break;
        default:
      }
    } else {
      switch (label) {
        case AddressLabel.home:
          s += ';LABEL=home';
          break;
        case AddressLabel.school:
          s += ';LABEL=school';
          break;
        case AddressLabel.work:
          s += ';LABEL=work';
          break;
        case AddressLabel.other:
          s += ';LABEL=other';
          break;
        case AddressLabel.custom:
          s += ';LABEL="${vCardEncode(customLabel)}"';
          break;
      }
    }
    if (street.isNotEmpty ||
        pobox.isNotEmpty ||
        city.isNotEmpty ||
        state.isNotEmpty ||
        postalCode.isNotEmpty) {
      s += ':${vCardEncode(pobox)};;'
          '${vCardEncode(street)};'
          '${vCardEncode(city)};'
          '${vCardEncode(state)};'
          '${vCardEncode(postalCode)};'
          '${vCardEncode(country)}';
    } else {
      s += ':;;${vCardEncode(address)};;;;';
    }
    return [s];
  }
}

/// Address labels.
///
/// | Label    | Android | iOS |
/// |----------|:-------:|:---:|
/// | home     | ✔       | ✔   |
/// | school   | ⨯       | ✔   |
/// | work     | ✔       | ✔   |
/// | other    | ✔       | ✔   |
/// | custom   | ✔       | ✔   |
enum AddressLabel {
  home,
  school,
  work,
  other,
  custom,
}

final _addressLabelToString = {
  AddressLabel.home: 'home',
  AddressLabel.school: 'school',
  AddressLabel.work: 'work',
  AddressLabel.other: 'other',
  AddressLabel.custom: 'custom',
};

final _stringToAddressLabel = {
  'home': AddressLabel.home,
  'school': AddressLabel.school,
  'work': AddressLabel.work,
  'other': AddressLabel.other,
  'custom': AddressLabel.custom,
};
