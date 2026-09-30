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
        // Anything unmapped is a custom label with its text (as on Android), including labels this
        // plugin wrote for platform-unsupported values; Apple's internal `_$!<Name>!$_` ones are localized.
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
