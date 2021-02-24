import Contacts

@available(iOS 9.0, *)
struct Event {
    var year: Int?
    var month: Int
    var day: Int
    // one of: anniversary, birthday, other, custom
    var label: String = "birthday"
    var customLabel: String = ""

    init(fromMap m: [String: Any?]) {
        year = m["year"] as? Int
        month = m["month"] as! Int
        day = m["day"] as! Int
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
    }

    init(fromContact c: CNContact) {
        // It seems like NSDateComponents use 2^64-1 as a value for year when there is
        // no year. This should cover similar edge cases.
        let y = c.birthday!.year
        year = (y == nil || y! < -100_000 || y! > 100_000) ? nil : y
        year = c.birthday!.year
        month = c.birthday!.month ?? 1
        day = c.birthday!.day ?? 1
        label = "birthday"
    }

    init(fromDate d: CNLabeledValue<NSDateComponents>) {
        // It seems like NSDateComponents use 2^64-1 as a value for year when there is
        // no year. This should cover similar edge cases.
        let y = d.value.year
        year = (y < -100_000 || y > 100_000) ? nil : y
        month = d.value.month
        day = d.value.day
        switch d.label {
        case CNLabelDateAnniversary:
            label = "anniversary"
        case CNLabelOther:
            label = "other"
        default:
            label = "custom"
            customLabel = d.label ?? ""
        }
    }

    func toMap() -> [String: Any?] { [
        "year": year,
        "month": month,
        "day": day,
        "label": label,
        "customLabel": customLabel,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        var dateComponents: DateComponents
        if year == nil {
            dateComponents = DateComponents(month: month, day: day)
        } else {
            dateComponents = DateComponents(year: year, month: month, day: day)
        }
        if label == "birthday" {
            c.birthday = dateComponents
        } else {
            var labelInv: String
            switch label {
            case "anniversary":
                labelInv = CNLabelDateAnniversary
            case "other":
                labelInv = CNLabelOther
            case "custom":
                labelInv = customLabel
            default:
                labelInv = label
            }
            c.dates.append(
                CNLabeledValue(
                    label: labelInv,
                    value: dateComponents as NSDateComponents
                )
            )
        }
    }
}
