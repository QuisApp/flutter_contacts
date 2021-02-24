import Contacts

@available(iOS 9.0, *)
struct Phone {
    var number: String
    var normalizedNumber: String
    // one of: assistant, callback, car, companyMain, faxHome, faxOther, faxWork, home,
    // iPhone, isdn, main, mms, mobile, pager, radio, school, telex, ttyTtd, work,
    // workMobile, workPager, other, custom
    var label: String = "mobile"
    var customLabel: String = ""
    var isPrimary: Bool = false // not supported on iOS

    init(fromMap m: [String: Any]) {
        number = m["number"] as! String
        normalizedNumber = m["normalizedNumber"] as! String
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
        isPrimary = m["isPrimary"] as! Bool
    }

    init(fromPhone p: CNLabeledValue<CNPhoneNumber>) {
        number = p.value.stringValue
        normalizedNumber = ""
        switch p.label {
        case CNLabelPhoneNumberHomeFax:
            label = "faxHome"
        case CNLabelPhoneNumberOtherFax:
            label = "faxOther"
        case CNLabelPhoneNumberWorkFax:
            label = "faxWork"
        case CNLabelHome:
            label = "home"
        case CNLabelPhoneNumberiPhone:
            label = "iPhone"
        case CNLabelPhoneNumberMain:
            label = "main"
        case CNLabelPhoneNumberMobile:
            label = "mobile"
        case CNLabelPhoneNumberPager:
            label = "pager"
        case CNLabelWork:
            label = "work"
        case CNLabelOther:
            label = "other"
        default:
            if #available(iOS 13, *), p.label == CNLabelSchool {
                label = "school"
            } else {
                label = "custom"
                customLabel = p.label ?? ""
            }
        }
    }

    func toMap() -> [String: Any] { [
        "number": number,
        "normalizedNumber": normalizedNumber,
        "label": label,
        "customLabel": customLabel,
        "isPrimary": isPrimary,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        var labelInv: String
        switch label {
        case "faxHome":
            labelInv = CNLabelPhoneNumberHomeFax
        case "faxOther":
            labelInv = CNLabelPhoneNumberOtherFax
        case "faxWork":
            labelInv = CNLabelPhoneNumberWorkFax
        case "home":
            labelInv = CNLabelHome
        case "iPhone":
            labelInv = CNLabelPhoneNumberiPhone
        case "main":
            labelInv = CNLabelPhoneNumberMain
        case "mobile":
            labelInv = CNLabelPhoneNumberMobile
        case "pager":
            labelInv = CNLabelPhoneNumberPager
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
        c.phoneNumbers.append(
            CNLabeledValue<CNPhoneNumber>(
                label: labelInv,
                value: CNPhoneNumber(stringValue: number)
            )
        )
    }
}
