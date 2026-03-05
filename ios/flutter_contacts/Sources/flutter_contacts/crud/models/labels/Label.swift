import Foundation

struct Label<T: RawRepresentable & Hashable>: Equatable, Hashable where T.RawValue == String {
    let label: T
    let customLabel: String?

    init(label: T, customLabel: String? = nil) {
        self.label = label
        self.customLabel = customLabel
    }

    func toJson() -> Json {
        var json: Json = ["label": label.rawValue]
        json.set("customLabel", customLabel)
        return json
    }

    static func fromJson(_ json: Json, fromName: (String) -> T) -> Label<T> {
        Label(
            label: fromName(json["label"] as! String),
            customLabel: json["customLabel"] as? String
        )
    }
}
