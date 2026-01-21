import Contacts
import Foundation

struct Website: Equatable, Hashable {
    let url: String
    let label: Label<WebsiteLabel>
    let metadata: PropertyMetadata?

    init(url: String, label: Label<WebsiteLabel>? = nil, metadata: PropertyMetadata? = nil) {
        self.url = url
        self.label = label ?? Label(label: .homepage)
        self.metadata = metadata
    }

    init(fromURL url: CNLabeledValue<NSString>) {
        let label = WebsiteLabel.fromCN(url.label)
        self.init(
            url: url.value as String,
            label: label,
            metadata: PropertyMetadata(dataId: url.identifier)
        )
    }

    func toJson() -> Json {
        var json: Json = ["url": url, "label": label.toJson()]
        json.setJson("metadata", metadata) { $0.toJson() }
        return json
    }

    static func fromJson(_ json: Json) -> Website {
        Website(
            url: json["url"] as! String,
            label: Label.fromJson(json["label"] as! Json, fromName: { WebsiteLabel(rawValue: $0)! }),
            metadata: json.json("metadata", PropertyMetadata.fromJson)
        )
    }

    static func apply(_ websites: [Website], to cnContact: CNMutableContact) {
        cnContact.urlAddresses = websites.map { website in
            let label = website.label.label.toCNLabel(customLabel: website.label.customLabel)
            return CNLabeledValue(label: label, value: website.url as NSString)
        }
    }
}
