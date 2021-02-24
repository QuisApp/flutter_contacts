import Contacts

@available(iOS 9.0, *)
struct Address {
    static var addressFormatter = CNPostalAddressFormatter()

    var address: String
    // one of: home, school, work, other, custom
    var label: String = "home"
    var customLabel: String = ""
    var street: String = ""
    var pobox: String = ""
    var neighborhood: String = ""
    var city: String = ""
    var state: String = ""
    var postalCode: String = ""
    var country: String = ""
    var isoCountry: String = ""
    var subAdminArea: String = ""
    var subLocality: String = ""

    init(fromMap m: [String: Any]) {
        address = m["address"] as! String
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
        street = m["street"] as! String
        pobox = m["pobox"] as! String
        neighborhood = m["neighborhood"] as! String
        city = m["city"] as! String
        state = m["state"] as! String
        postalCode = m["postalCode"] as! String
        country = m["country"] as! String
        isoCountry = m["isoCountry"] as! String
        subAdminArea = m["subAdminArea"] as! String
        subLocality = m["subLocality"] as! String
    }

    init(fromAddress a: CNLabeledValue<CNPostalAddress>) {
        address = Address.addressFormatter.string(from: a.value)
        switch a.label {
        case CNLabelHome:
            label = "home"
        case CNLabelWork:
            label = "work"
        case CNLabelOther:
            label = "other"
        default:
            if #available(iOS 13, *), a.label == CNLabelSchool {
                label = "school"
            } else {
                label = "custom"
                customLabel = a.label ?? ""
            }
        }
        street = a.value.street
        // pobox and neighborhood not supported
        city = a.value.city
        state = a.value.state
        postalCode = a.value.postalCode
        country = a.value.country
        isoCountry = a.value.isoCountryCode
        if #available(iOS 13, *) {
            subAdminArea = a.value.subAdministrativeArea
            subLocality = a.value.subLocality
        }
    }

    func toMap() -> [String: Any] { [
        "address": address,
        "label": label,
        "customLabel": customLabel,
        "street": street,
        "pobox": pobox,
        "neighborhood": neighborhood,
        "city": city,
        "state": state,
        "postalCode": postalCode,
        "country": country,
        "isoCountry": isoCountry,
        "subAdminArea": subAdminArea,
        "subLocality": subLocality,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        let mutableAddress = CNMutablePostalAddress()
        var isAnyFieldPresent = false
        if !street.isEmpty {
            mutableAddress.street = street
            isAnyFieldPresent = true
        }
        if !city.isEmpty {
            mutableAddress.city = city
            isAnyFieldPresent = true
        }
        if !state.isEmpty {
            mutableAddress.state = state
            isAnyFieldPresent = true
        }
        if !postalCode.isEmpty {
            mutableAddress.postalCode = postalCode
            isAnyFieldPresent = true
        }
        if !country.isEmpty {
            mutableAddress.country = country
            isAnyFieldPresent = true
        }
        if !isoCountry.isEmpty {
            mutableAddress.isoCountryCode = isoCountry
            isAnyFieldPresent = true
        }
        if #available(iOS 13, *), !subAdminArea.isEmpty {
            mutableAddress.subAdministrativeArea = subAdminArea
            isAnyFieldPresent = true
        }
        if #available(iOS 13, *), !subLocality.isEmpty {
            mutableAddress.subLocality = subLocality
            isAnyFieldPresent = true
        }
        if !isAnyFieldPresent {
            // fallback to writing the entire address into the `street` field
            mutableAddress.street = address
        }
        var labelInv: String
        switch label {
        case "home":
            labelInv = CNLabelHome
        case "school":
            if #available(iOS 13, *) {
                labelInv = CNLabelSchool
            } else {
                labelInv = "school"
            }
        case "work":
            labelInv = CNLabelWork
        case "other":
            labelInv = CNLabelOther
        case "custom":
            labelInv = customLabel
        default:
            labelInv = label
        }
        c.postalAddresses.append(
            CNLabeledValue<CNPostalAddress>(
                label: labelInv,
                value: mutableAddress
            )
        )
    }
}
