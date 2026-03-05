import Contacts
import Foundation

enum PhoneLabel: String, CaseIterable {
    case appleWatch
    case assistant
    case callback
    case car
    case companyMain
    case home
    case homeFax
    case iPhone
    case isdn
    case main
    case mobile
    case mms
    case other
    case otherFax
    case pager
    case radio
    case school
    case telex
    case ttyTdd
    case work
    case workFax
    case workMobile
    case workPager
    case custom

    private static let CN_TO_LABEL: [String: PhoneLabel] = [
        CNLabelHome: .home,
        CNLabelWork: .work,
        CNLabelOther: .other,
        CNLabelSchool: .school,
        CNLabelPhoneNumberMobile: .mobile,
        CNLabelPhoneNumberiPhone: .iPhone,
        CNLabelPhoneNumberMain: .main,
        CNLabelPhoneNumberHomeFax: .homeFax,
        CNLabelPhoneNumberWorkFax: .workFax,
        CNLabelPhoneNumberOtherFax: .otherFax,
        CNLabelPhoneNumberPager: .pager,
    ]

    private static let LABEL_TO_CN: [PhoneLabel: String] = [
        .home: CNLabelHome,
        .work: CNLabelWork,
        .other: CNLabelOther,
        .school: CNLabelSchool,
        .mobile: CNLabelPhoneNumberMobile,
        .iPhone: CNLabelPhoneNumberiPhone,
        .main: CNLabelPhoneNumberMain,
        .homeFax: CNLabelPhoneNumberHomeFax,
        .workFax: CNLabelPhoneNumberWorkFax,
        .otherFax: CNLabelPhoneNumberOtherFax,
        .pager: CNLabelPhoneNumberPager,
    ]

    static func fromCN(_ cnLabel: String?) -> Label<PhoneLabel> {
        if #available(iOS 14.3, *), let cnLabel = cnLabel, cnLabel == CNLabelPhoneNumberAppleWatch {
            return Label(label: .appleWatch)
        }
        return LabelConverter.fromCN(cnLabel, labelMap: CN_TO_LABEL, defaultLabel: .mobile)
    }

    func toCNLabel(customLabel: String?) -> String {
        if case .appleWatch = self {
            if #available(iOS 14.3, *) {
                return CNLabelPhoneNumberAppleWatch
            }
            return rawValue
        }
        return LabelConverter.toCN(self, customLabel: customLabel, labelMap: PhoneLabel.LABEL_TO_CN)
    }
}
