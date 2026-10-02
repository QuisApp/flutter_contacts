import Contacts
import Foundation

enum LabelConverter {
    static func fromCN<T: RawRepresentable>(
        _ cnLabel: String?,
        labelMap: [String: T],
        defaultLabel: T
    ) -> Label<T> where T.RawValue == String {
        guard let cnLabel, !cnLabel.isEmpty else { return Label(label: defaultLabel) }
        if let label = labelMap[cnLabel] { return Label(label: label) }
        // Anything unmapped is a custom label with its text (as on Android). Apple's own `_$!<Name>!$_`
        // labels stay raw: toCN writes customLabel back verbatim, so localizing them here would turn
        // them into literal custom labels on the next update().
        guard let custom = T(rawValue: "custom") else { return Label(label: defaultLabel, customLabel: cnLabel) }
        return Label(label: custom, customLabel: cnLabel)
    }

    static func toCN<T: RawRepresentable>(
        _ label: T,
        customLabel: String?,
        labelMap: [T: String]
    ) -> String where T.RawValue == String {
        customLabel ?? labelMap[label] ?? label.rawValue
    }
}
