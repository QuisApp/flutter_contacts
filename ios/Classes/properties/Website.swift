import Contacts

@available(iOS 9.0, *)
struct Website {
    var url: String
    // one of: blog, ftp, home, homepage, profile, school, work, other, custom
    var label: String = "homepage"
    var customLabel: String = ""

    init(fromMap m: [String: Any]) {
        url = m["url"] as! String
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
    }

    init(fromWebsite w: CNLabeledValue<NSString>) {
        url = w.value as String
        switch w.label {
        case CNLabelHome:
            label = "home"
        case CNLabelURLAddressHomePage:
            label = "homepage"
        case CNLabelWork:
            label = "work"
        case CNLabelOther:
            label = "other"
        default:
            if #available(iOS 13, *), w.label == CNLabelSchool {
                label = "school"
            } else {
                label = "custom"
                customLabel = w.label ?? ""
            }
        }
    }

    func toMap() -> [String: Any] { [
        "url": url,
        "label": label,
        "customLabel": customLabel,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        var labelInv: String
        switch label {
        case "home":
            labelInv = CNLabelHome
        case "homepage":
            labelInv = CNLabelURLAddressHomePage
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
        c.urlAddresses.append(
            CNLabeledValue<NSString>(
                label: labelInv,
                value: url as NSString
            )
        )
    }
}
