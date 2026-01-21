import Contacts
import Foundation

enum EventLabel: String, CaseIterable {
    case anniversary
    case birthday
    case other
    case custom

    private static var CN_TO_LABEL: [String: EventLabel] {
        var map: [String: EventLabel] = [CNLabelOther: .other]
        map[CNLabelDateAnniversary] = .anniversary
        return map
    }

    private static var LABEL_TO_CN: [EventLabel: String] {
        var map: [EventLabel: String] = [.other: CNLabelOther]
        map[.anniversary] = CNLabelDateAnniversary
        return map
    }

    static func fromCN(_ cnLabel: String?) -> Label<EventLabel> {
        return LabelConverter.fromCN(cnLabel, labelMap: CN_TO_LABEL, defaultLabel: .other)
    }

    func toCNLabel(customLabel: String?) -> String {
        // Birthday is handled separately in Event.apply() and never reaches this function
        return LabelConverter.toCN(self, customLabel: customLabel, labelMap: EventLabel.LABEL_TO_CN)
    }
}
