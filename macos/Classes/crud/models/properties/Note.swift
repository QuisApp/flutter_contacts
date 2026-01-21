import Contacts
import Foundation

struct Note: Equatable, Hashable {
    let note: String
    let metadata: PropertyMetadata?

    init(note: String, metadata: PropertyMetadata? = nil) {
        self.note = note
        self.metadata = metadata
    }

    func toJson() -> Json {
        var json: Json = ["note": note]
        json.setJson("metadata", metadata) { $0.toJson() }
        return json
    }

    static func fromJson(_ json: Json) -> Note {
        Note(
            note: json["note"] as! String,
            metadata: json.json("metadata", PropertyMetadata.fromJson)
        )
    }

    static func apply(_ note: String?, to cnContact: CNMutableContact) {
        cnContact.note = note ?? ""
    }
}
