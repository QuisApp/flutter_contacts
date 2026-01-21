import Contacts
import Foundation

struct Phone: Equatable, Hashable {
    let number: String
    let label: Label<PhoneLabel>
    let metadata: PropertyMetadata?

    init(number: String, label: Label<PhoneLabel>? = nil, metadata: PropertyMetadata? = nil) {
        self.number = number
        self.label = label ?? Label(label: .mobile)
        self.metadata = metadata
    }

    init(fromPhone phone: CNLabeledValue<CNPhoneNumber>) {
        let label = PhoneLabel.fromCN(phone.label)
        self.init(
            number: phone.value.stringValue,
            label: label,
            metadata: PropertyMetadata(dataId: phone.identifier)
        )
    }

    func toJson() -> Json {
        var json: Json = ["number": number, "label": label.toJson()]
        json.setJson("metadata", metadata) { $0.toJson() }
        return json
    }

    static func fromJson(_ json: Json) -> Phone {
        Phone(
            number: json["number"] as! String,
            label: Label.fromJson(json["label"] as! Json, fromName: { PhoneLabel(rawValue: $0)! }),
            metadata: json.json("metadata", PropertyMetadata.fromJson)
        )
    }

    static func apply(_ phones: [Phone], to cnContact: CNMutableContact) {
        cnContact.phoneNumbers = phones.map { phone in
            let label = phone.label.label.toCNLabel(customLabel: phone.label.customLabel)
            return CNLabeledValue(label: label, value: CNPhoneNumber(stringValue: phone.number))
        }
    }
}
