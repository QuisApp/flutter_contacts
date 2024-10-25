import Contacts

@available(iOS 9.0, *)
struct Note {
    var note: String

    init(fromMap m: [String: Any]) {
        note = m["note"] as! String
    }

    init(fromContact c: CNContact) {
        note = c.note
    }

    func toMap() -> [String: Any] { [
        "note": note,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        c.note = note
    }
}
