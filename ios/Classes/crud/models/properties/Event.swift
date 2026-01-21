import Contacts
import Foundation

struct Event: Equatable, Hashable {
    let year: Int?
    let month: Int
    let day: Int
    let label: Label<EventLabel>
    let metadata: PropertyMetadata?

    init(year: Int? = nil, month: Int, day: Int, label: Label<EventLabel>? = nil, metadata: PropertyMetadata? = nil) {
        self.year = year
        self.month = month
        self.day = day
        self.label = label ?? Label(label: .other)
        self.metadata = metadata
    }

    func toJson() -> Json {
        var json: Json = ["month": month, "day": day, "label": label.toJson()]
        json.set("year", year)
        json.setJson("metadata", metadata) { $0.toJson() }
        return json
    }

    static func fromJson(_ json: Json) -> Event {
        Event(
            year: json["year"] as? Int,
            month: json["month"] as! Int,
            day: json["day"] as! Int,
            label: Label.fromJson(json["label"] as! Json, fromName: { EventLabel(rawValue: $0)! }),
            metadata: json.json("metadata", PropertyMetadata.fromJson)
        )
    }

    static func apply(_ events: [Event], to cnContact: CNMutableContact) {
        var dates: [CNLabeledValue<NSDateComponents>] = []
        var birthday: DateComponents? = nil

        for event in events {
            let dateComponents = NSDateComponents()
            if let year = event.year { dateComponents.year = year }
            dateComponents.month = event.month
            dateComponents.day = event.day

            if event.label.label == EventLabel.birthday {
                birthday = dateComponents as DateComponents
            } else {
                let label = event.label.label.toCNLabel(customLabel: event.label.customLabel)
                dates.append(CNLabeledValue(label: label, value: dateComponents))
            }
        }

        cnContact.birthday = birthday
        cnContact.dates = dates
    }
}
