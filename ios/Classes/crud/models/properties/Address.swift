import Contacts
import Foundation

struct Address: Equatable, Hashable {
    let formatted: String?
    let street: String?
    let city: String?
    let state: String?
    let postalCode: String?
    let country: String?
    let isoCountryCode: String?
    let subAdministrativeArea: String?
    let subLocality: String?
    let label: Label<AddressLabel>
    let metadata: PropertyMetadata?

    init(formatted: String? = nil, street: String? = nil, city: String? = nil, state: String? = nil, postalCode: String? = nil, country: String? = nil, isoCountryCode: String? = nil, subAdministrativeArea: String? = nil, subLocality: String? = nil, label: Label<AddressLabel>? = nil, metadata: PropertyMetadata? = nil) {
        self.formatted = formatted
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.isoCountryCode = isoCountryCode
        self.subAdministrativeArea = subAdministrativeArea
        self.subLocality = subLocality
        self.label = label ?? Label(label: .home)
        self.metadata = metadata
    }

    init(fromAddress address: CNLabeledValue<CNPostalAddress>) {
        let postal = address.value
        let label = AddressLabel.fromCN(address.label)
        let formattedAddress = CNPostalAddressFormatter.string(from: postal, style: .mailingAddress)
        self.init(
            formatted: formattedAddress.isEmpty ? nil : formattedAddress,
            street: postal.street.isEmpty ? nil : postal.street,
            city: postal.city.isEmpty ? nil : postal.city,
            state: postal.state.isEmpty ? nil : postal.state,
            postalCode: postal.postalCode.isEmpty ? nil : postal.postalCode,
            country: postal.country.isEmpty ? nil : postal.country,
            isoCountryCode: postal.isoCountryCode.isEmpty ? nil : postal.isoCountryCode,
            subAdministrativeArea: postal.subAdministrativeArea.isEmpty ? nil : postal.subAdministrativeArea,
            subLocality: postal.subLocality.isEmpty ? nil : postal.subLocality,
            label: label,
            metadata: PropertyMetadata(dataId: address.identifier)
        )
    }

    func toJson() -> Json {
        var json: Json = ["label": label.toJson()]
        json.set("formatted", formatted)
        json.set("street", street)
        json.set("city", city)
        json.set("state", state)
        json.set("postalCode", postalCode)
        json.set("country", country)
        json.set("isoCountryCode", isoCountryCode)
        json.set("subAdministrativeArea", subAdministrativeArea)
        json.set("subLocality", subLocality)
        json.setJson("metadata", metadata) { $0.toJson() }
        return json
    }

    static func fromJson(_ json: Json) -> Address {
        Address(
            formatted: json["formatted"] as? String,
            street: json["street"] as? String,
            city: json["city"] as? String,
            state: json["state"] as? String,
            postalCode: json["postalCode"] as? String,
            country: json["country"] as? String,
            isoCountryCode: json["isoCountryCode"] as? String,
            subAdministrativeArea: json["subAdministrativeArea"] as? String,
            subLocality: json["subLocality"] as? String,
            label: Label.fromJson(json["label"] as! Json, fromName: { AddressLabel(rawValue: $0)! }),
            metadata: json.json("metadata", PropertyMetadata.fromJson)
        )
    }

    static func apply(_ addresses: [Address], to cnContact: CNMutableContact) {
        cnContact.postalAddresses = addresses.map { address in
            let label = address.label.label.toCNLabel(customLabel: address.label.customLabel)
            let postalAddress = CNMutablePostalAddress()
            if let street = address.street { postalAddress.street = street }
            if let city = address.city { postalAddress.city = city }
            if let state = address.state { postalAddress.state = state }
            if let postalCode = address.postalCode { postalAddress.postalCode = postalCode }
            if let country = address.country { postalAddress.country = country }
            if let isoCountryCode = address.isoCountryCode { postalAddress.isoCountryCode = isoCountryCode }
            if let subAdministrativeArea = address.subAdministrativeArea { postalAddress.subAdministrativeArea = subAdministrativeArea }
            if let subLocality = address.subLocality { postalAddress.subLocality = subLocality }
            return CNLabeledValue(label: label, value: postalAddress)
        }
    }
}
