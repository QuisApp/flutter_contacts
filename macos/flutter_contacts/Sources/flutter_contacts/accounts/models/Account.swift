import Contacts
import Foundation

struct Account: Equatable, Hashable, Codable {
    let id: String
    let name: String
    let type: String

    func toJson() -> Json {
        ["id": id, "name": name, "type": type]
    }

    static func fromJson(_ json: Json) -> Account {
        Account(
            id: json["id"] as! String,
            name: json["name"] as! String,
            type: json["type"] as! String
        )
    }

    static func fromContainer(_ container: CNContainer) -> Account {
        Account(
            id: container.identifier,
            name: container.name,
            type: AccountUtils.toString(container.type)
        )
    }
}
