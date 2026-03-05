import Contacts
import Foundation

struct Relation: Equatable, Hashable {
    let name: String
    let label: Label<RelationLabel>
    let metadata: PropertyMetadata?

    init(name: String, label: Label<RelationLabel>? = nil, metadata: PropertyMetadata? = nil) {
        self.name = name
        self.label = label ?? Label(label: .other)
        self.metadata = metadata
    }

    init(fromRelation relation: CNLabeledValue<CNContactRelation>) {
        let label = RelationLabel.fromCN(relation.label)
        self.init(
            name: relation.value.name,
            label: label,
            metadata: PropertyMetadata(dataId: relation.identifier)
        )
    }

    func toJson() -> Json {
        var json: Json = ["name": name, "label": label.toJson()]
        json.setJson("metadata", metadata) { $0.toJson() }
        return json
    }

    static func fromJson(_ json: Json) -> Relation {
        Relation(
            name: json["name"] as! String,
            label: Label.fromJson(json["label"] as! Json, fromName: { RelationLabel(rawValue: $0)! }),
            metadata: json.json("metadata", PropertyMetadata.fromJson)
        )
    }

    static func apply(_ relations: [Relation], to cnContact: CNMutableContact) {
        cnContact.contactRelations = relations.map { relation in
            let label = relation.label.label.toCNLabel(customLabel: relation.label.customLabel)
            return CNLabeledValue(label: label, value: CNContactRelation(name: relation.name))
        }
    }
}
