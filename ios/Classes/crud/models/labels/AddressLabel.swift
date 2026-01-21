import Contacts
import Foundation

enum AddressLabel: String, CaseIterable {
    case home
    case school
    case work
    case other
    case custom

    private static let CN_TO_LABEL: [String: AddressLabel] = [
        CNLabelHome: .home,
        CNLabelWork: .work,
        CNLabelOther: .other,
        CNLabelSchool: .school,
    ]

    private static let LABEL_TO_CN: [AddressLabel: String] = [
        .home: CNLabelHome,
        .work: CNLabelWork,
        .other: CNLabelOther,
        .school: CNLabelSchool,
    ]

    static func fromCN(_ cnLabel: String?) -> Label<AddressLabel> {
        return LabelConverter.fromCN(cnLabel, labelMap: CN_TO_LABEL, defaultLabel: .home)
    }

    func toCNLabel(customLabel: String?) -> String {
        return LabelConverter.toCN(self, customLabel: customLabel, labelMap: AddressLabel.LABEL_TO_CN)
    }
}
