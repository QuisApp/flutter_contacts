import Foundation

struct PropertyMetadata: Equatable, Hashable {
    let dataId: String?

    func toJson() -> Json {
        var json: Json = [:]
        json.set("dataId", dataId)
        return json
    }

    static func fromJson(_ json: Json) -> PropertyMetadata {
        PropertyMetadata(dataId: json["dataId"] as? String)
    }
}
