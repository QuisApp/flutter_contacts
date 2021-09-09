import Contacts

@available(iOS 9.0, *)
struct Group {
    var id: String
    var name: String

    init(fromMap m: [String: Any]) {
        id = m["id"] as! String
        name = m["name"] as! String
    }

    init(fromGroup g: CNGroup) {
        id = g.identifier
        name = g.name
    }

    func toMap() -> [String: Any] { [
        "id": id,
        "name": name,
    ]
    }
}
