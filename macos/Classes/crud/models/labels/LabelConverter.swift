import Contacts
import Foundation

enum LabelConverter {
    static func fromCN<T: RawRepresentable>(
        _ cnLabel: String?,
        labelMap: [String: T],
        defaultLabel: T
    ) -> Label<T> where T.RawValue == String {
        guard let cnLabel, let label = labelMap[cnLabel] else {
            return Label(label: defaultLabel, customLabel: cnLabel)
        }
        return Label(label: label)
    }

    static func toCN<T: RawRepresentable>(
        _ label: T,
        customLabel: String?,
        labelMap: [T: String]
    ) -> String where T.RawValue == String {
        customLabel ?? labelMap[label] ?? label.rawValue
    }
}
