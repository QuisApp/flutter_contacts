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
        // Labels iOS has no constant for are written as their raw value (see `toCN`).
        if let label = T(rawValue: cnLabel), label.rawValue != "custom" { return Label(label: label) }
        // Anything else is a custom label; show Apple's internal `_$!<Name>!$_` ones localized.
        let text = cnLabel.hasPrefix("_$!<") ? CNLabeledValue<NSString>.localizedString(forLabel: cnLabel) : cnLabel
        guard let custom = T(rawValue: "custom") else { return Label(label: defaultLabel, customLabel: text) }
        return Label(label: custom, customLabel: text)
    }

    static func toCN<T: RawRepresentable>(
        _ label: T,
        customLabel: String?,
        labelMap: [T: String]
    ) -> String where T.RawValue == String {
        customLabel ?? labelMap[label] ?? label.rawValue
    }
}
