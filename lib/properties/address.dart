import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

/// A postal address.
///
/// Postal address structure varies widely by country. See:
/// https://en.wikipedia.org/wiki/Address#Format_by_country_and_area
///
/// Data models such as those from Android and iOS are typically US-centric and
/// include street, city, state, zip code. They also always include a free-form
/// formatted address, which we recommend to use instead. That said, other
/// fields are included for compatibility.
///
/// | Field           | Android | iOS |
/// |-----------------|:-------:|:---:|
/// | street          | ✔       | ⨯   |
/// | pobox           | ✔       | ⨯   |
/// | neighborhood    | ✔       | ⨯   |
/// | city            | ✔       | ✔   |
/// | state           | ✔       | ✔   |
/// | postalCode      | ✔       | ✔   |
/// | country         | ✔       | ✔   |
/// | isoCountry      | ⨯       | ✔   |
/// | subAdminArea    | ⨯       | ✔   |
/// | subLocality     | ⨯       | ✔   |
@JsonSerializable(disallowUnrecognizedKeys: true)
class Address {
  /// Free-form formatted address.
  ///
  /// It should *always* be included. (Even if the native contact doesn't have
  /// one, it's the adapter's job to format the address into a single string.)
  ///
  /// It is recommended to use this instead of any structured field such as
  /// [street] or [state], when possible.
  @JsonKey(required: true)
  String address;

  /// The label or type of address it is. If `custom`, the free-form label can
  /// be found in [customLabel].
  @JsonKey(defaultValue: AddressLabel.home)
  AddressLabel label;

  /// If [label] is [AddressLabel.custom], free-form user-chosen label.
  @JsonKey(defaultValue: '')
  String customLabel;

  /// Street name. At least on Android this also includes house number and
  /// room/apartment/flat/floor number.
  @JsonKey(defaultValue: '')
  String street;

  /// P.O. box. This is (according to Android's doc) usually but not always
  /// mutually exclusive with street. Android only.
  @JsonKey(defaultValue: '')
  String pobox;

  /// According to Android's doc, this can help disambiguate a street address in
  /// cases the same city has several streets with the same name. Android only.
  @JsonKey(defaultValue: '')
  String neighborhood;

  /// City/town.
  @JsonKey(defaultValue: '')
  String city;

  /// State (in the US).
  ///
  /// On Android (which calls it "region") this also represent the province
  /// (Canada), county (Ireland), Land (Germany), department (France), etc. On
  /// iOS those are defined in [subAdminArea] instead.
  @JsonKey(defaultValue: '')
  String state;

  /// Zip code (US), postcode (UK), etc.
  @JsonKey(defaultValue: '')
  String postalCode;

  /// Country as a free-form text (e.g. "France").
  @JsonKey(defaultValue: '')
  String country;

  /// Country in the ISO 3166-1 alpha-2 standard (e.g. "fr"). iOS only.
  @JsonKey(defaultValue: '')
  String isoCountry;

  /// Subadministrative area, such as region or county. iOS only. On Android
  /// those are folded into [state] (which Android calls "region").
  @JsonKey(defaultValue: '')
  String subAdminArea;

  /// Any additional information associated with the location. iOS only.
  @JsonKey(defaultValue: '')
  String subLocality;

  Address(this.address,
      {this.label = AddressLabel.home,
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
      this.subLocality = ''});

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

/// Address labels
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
