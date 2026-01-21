import Contacts
import Foundation

enum WebsiteLabel: String, CaseIterable {
    case blog
    case ftp
    case home
    case homepage
    case profile
    case school
    case work
    case other
    case custom

    private static let CN_TO_LABEL: [String: WebsiteLabel] = [
        CNLabelHome: .home,
        CNLabelWork: .work,
        CNLabelOther: .other,
        CNLabelSchool: .school,
        CNLabelURLAddressHomePage: .homepage,
    ]

    private static let LABEL_TO_CN: [WebsiteLabel: String] = [
        .home: CNLabelHome,
        .work: CNLabelWork,
        .other: CNLabelOther,
        .school: CNLabelSchool,
        .homepage: CNLabelURLAddressHomePage,
    ]

    static func fromCN(_ cnLabel: String?) -> Label<WebsiteLabel> {
        return LabelConverter.fromCN(cnLabel, labelMap: CN_TO_LABEL, defaultLabel: .homepage)
    }

    func toCNLabel(customLabel: String?) -> String {
        return LabelConverter.toCN(self, customLabel: customLabel, labelMap: WebsiteLabel.LABEL_TO_CN)
    }
}
