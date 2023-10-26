import Contacts

@available(iOS 9.0, *)
struct Relation {
    var name: String
    // one of: spouse, partner, daughter, son, child, father, mother, parent, 
    // brother, sister, friend, assitant, manager
    var label: String = "home"
    var customLabel: String = ""

    init(fromMap m: [String: Any]) {
        name = m["name"] as! String
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
    }

    init(fromRelation r: CNLabeledValue<CNContactRelation>) {
        name = r.value.name
        switch r.label {
        case CNLabelContactRelationSpouse:
            label = "spouse"
        case CNLabelContactRelationPartner:
            label = "partner"
        case CNLabelContactRelationDaughter:
            label = "daughter"
        case CNLabelContactRelationSon:
            label = "son"
        case CNLabelContactRelationChild:
            label = "child"
        case CNLabelContactRelationFather:
            label = "father"
        case CNLabelContactRelationMother:
            label = "mother"
        case CNLabelContactRelationParent:
            label = "parent"
        case CNLabelContactRelationBrother:
            label = "brother"
        case CNLabelContactRelationSister:
            label = "sister"
        case CNLabelContactRelationFriend:
            label = "friend"
        case CNLabelContactRelationAssistant:
            label = "assistant"
        case CNLabelContactRelationManager:
            label = "manager"
        default:
            label = "custom"
            customLabel = r.label ?? ""
        }
    }

    func toMap() -> [String: Any] { [
        "name": name,
        "label": label,
        "customLabel": customLabel,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        var labelInv: String
        switch label {
        case "spouse":
            labelInv = CNLabelContactRelationSpouse
        case "partner":
            labelInv = CNLabelContactRelationPartner
        case "daughter":
            labelInv = CNLabelContactRelationDaughter
         case "son":
            labelInv = CNLabelContactRelationSon
        case "child":
            labelInv = CNLabelContactRelationChild
        case "father":
            labelInv = CNLabelContactRelationFather
        case "mother":
            labelInv = CNLabelContactRelationMother
        case "parent":
            labelInv = CNLabelContactRelationParent
        case "brother":
            labelInv = CNLabelContactRelationBrother
        case "sister":
            labelInv = CNLabelContactRelationSister
        case "friend":
            labelInv = CNLabelContactRelationFriend
        case "assistant":
            labelInv = CNLabelContactRelationAssistant
         case "manager":
            labelInv = CNLabelContactRelationManager
        default:
            labelInv = label
        }
        c.contactRelations.append(
            CNLabeledValue<CNContactRelation>(
                label: labelInv,
                value: CNContactRelation(name: name)
            )
        )
    }
}
