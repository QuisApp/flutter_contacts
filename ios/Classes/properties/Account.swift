import Contacts

@available(iOS 9.0, *)
struct Account {
    var rawId: String
    // local, exchange, cardDAV or unassigned
    var type: String
    var name: String

    init(fromMap m: [String: Any]) {
        rawId = m["rawId"] as! String
        type = m["type"] as! String
        name = m["name"] as! String
    }

    init(fromContainer c: CNContainer) {
        rawId = c.identifier
        name = c.name
        switch c.type {
        case .local:
            type = "local"
        case .exchange:
            type = "exchange"
        case .cardDAV:
            type = "cardDAV"
        case .unassigned:
            type = "unassigned"
        default:
            type = "unassigned"
        }
    }

    func toMap() -> [String: Any] { [
        "rawId": rawId,
        "type": type,
        "name": name,
        "mimetypes": [String](), // not available on iOS
    ]
    }
}
