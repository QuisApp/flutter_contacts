import Contacts

@available(iOS 9.0, *)
struct Email {
    var address: String
    // one of: home, iCloud, mobile, school, work, other, custom
    var label: String = "home"
    var customLabel: String = ""
    var isPrimary: Bool = false // not supported on iOS

    init(fromMap m: [String: Any]) {
        address = m["address"] as! String
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
        isPrimary = m["isPrimary"] as! Bool
    }

    init(fromEmail e: CNLabeledValue<NSString>) {
        address = e.value as String
        switch e.label {
        case CNLabelHome:
            label = "home"
        case CNLabelEmailiCloud:
            label = "iCloud"
        case CNLabelWork:
            label = "work"
        case CNLabelOther:
            label = "other"
        default:
            if #available(iOS 13, *), e.label == CNLabelSchool {
                label = "school"
            } else {
                label = "custom"
                customLabel = e.label ?? ""
            }
        }
    }

    func toMap() -> [String: Any] { [
        "address": address,
        "label": label,
        "customLabel": customLabel,
        "isPrimary": isPrimary,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        var labelInv: String
        switch label {
        case "home":
            labelInv = CNLabelHome
        case "iCloud":
            labelInv = CNLabelEmailiCloud
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
        c.emailAddresses.append(
            CNLabeledValue<NSString>(
                label: labelInv,
                value: address as NSString
            )
        )
    }
}
