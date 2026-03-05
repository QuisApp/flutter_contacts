import Contacts
import Foundation

struct Email: Equatable, Hashable {
    let address: String
    let label: Label<EmailLabel>
    let metadata: PropertyMetadata?

    init(address: String, label: Label<EmailLabel>? = nil, metadata: PropertyMetadata? = nil) {
        self.address = address
        self.label = label ?? Label(label: .home)
        self.metadata = metadata
    }

    init(fromEmail email: CNLabeledValue<NSString>) {
        let label = EmailLabel.fromCN(email.label)
        self.init(
            address: email.value as String,
            label: label,
            metadata: PropertyMetadata(dataId: email.identifier)
        )
    }

    func toJson() -> Json {
        var json: Json = ["address": address, "label": label.toJson()]
        json.setJson("metadata", metadata) { $0.toJson() }
        return json
    }

    static func fromJson(_ json: Json) -> Email {
        Email(
            address: json["address"] as! String,
            label: Label.fromJson(json["label"] as! Json, fromName: { EmailLabel(rawValue: $0)! }),
            metadata: json.json("metadata", PropertyMetadata.fromJson)
        )
    }

    static func apply(_ emails: [Email], to cnContact: CNMutableContact) {
        cnContact.emailAddresses = emails.map { email in
            let label = email.label.label.toCNLabel(customLabel: email.label.customLabel)
            return CNLabeledValue(label: label, value: email.address as NSString)
        }
    }
}
