import Contacts
import Foundation

enum EmailLabel: String, CaseIterable {
    case home
    case iCloud
    case mobile
    case school
    case work
    case other
    case custom

    private static let CN_TO_LABEL: [String: EmailLabel] = [
        CNLabelHome: .home,
        CNLabelWork: .work,
        CNLabelOther: .other,
        CNLabelSchool: .school,
        CNLabelEmailiCloud: .iCloud,
    ]

    private static let LABEL_TO_CN: [EmailLabel: String] = [
        .home: CNLabelHome,
        .work: CNLabelWork,
        .other: CNLabelOther,
        .school: CNLabelSchool,
        .iCloud: CNLabelEmailiCloud,
    ]

    static func fromCN(_ cnLabel: String?) -> Label<EmailLabel> {
        return LabelConverter.fromCN(cnLabel, labelMap: CN_TO_LABEL, defaultLabel: .home)
    }

    func toCNLabel(customLabel: String?) -> String {
        return LabelConverter.toCN(self, customLabel: customLabel, labelMap: EmailLabel.LABEL_TO_CN)
    }
}
