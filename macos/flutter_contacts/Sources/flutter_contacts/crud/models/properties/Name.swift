import Contacts
import Foundation

struct Name: Equatable, Hashable {
    let first: String?
    let middle: String?
    let last: String?
    let prefix: String?
    let suffix: String?
    let phoneticFirst: String?
    let phoneticMiddle: String?
    let phoneticLast: String?
    let previousFamilyName: String?
    let nickname: String?

    init(first: String? = nil, middle: String? = nil, last: String? = nil, prefix: String? = nil, suffix: String? = nil, phoneticFirst: String? = nil, phoneticMiddle: String? = nil, phoneticLast: String? = nil, previousFamilyName: String? = nil, nickname: String? = nil) {
        self.first = first
        self.middle = middle
        self.last = last
        self.prefix = prefix
        self.suffix = suffix
        self.phoneticFirst = phoneticFirst
        self.phoneticMiddle = phoneticMiddle
        self.phoneticLast = phoneticLast
        self.previousFamilyName = previousFamilyName
        self.nickname = nickname
    }

    init(fromContact contact: CNContact) {
        first = contact.givenName.nilIfEmpty
        middle = contact.middleName.nilIfEmpty
        last = contact.familyName.nilIfEmpty
        prefix = contact.namePrefix.nilIfEmpty
        suffix = contact.nameSuffix.nilIfEmpty
        phoneticFirst = contact.phoneticGivenName.nilIfEmpty
        phoneticMiddle = contact.phoneticMiddleName.nilIfEmpty
        phoneticLast = contact.phoneticFamilyName.nilIfEmpty
        previousFamilyName = contact.previousFamilyName.nilIfEmpty
        nickname = contact.nickname.nilIfEmpty
    }

    func toJson() -> Json {
        var json: Json = [:]
        json.set("first", first)
        json.set("middle", middle)
        json.set("last", last)
        json.set("prefix", prefix)
        json.set("suffix", suffix)
        json.set("phoneticFirst", phoneticFirst)
        json.set("phoneticMiddle", phoneticMiddle)
        json.set("phoneticLast", phoneticLast)
        json.set("previousFamilyName", previousFamilyName)
        json.set("nickname", nickname)
        return json
    }

    static func fromJson(_ json: Json) -> Name {
        Name(
            first: json["first"] as? String,
            middle: json["middle"] as? String,
            last: json["last"] as? String,
            prefix: json["prefix"] as? String,
            suffix: json["suffix"] as? String,
            phoneticFirst: json["phoneticFirst"] as? String,
            phoneticMiddle: json["phoneticMiddle"] as? String,
            phoneticLast: json["phoneticLast"] as? String,
            previousFamilyName: json["previousFamilyName"] as? String,
            nickname: json["nickname"] as? String
        )
    }

    static func apply(_ name: Name?, to cnContact: CNMutableContact) {
        guard let name = name else { return }
        cnContact.givenName = name.first ?? ""
        cnContact.middleName = name.middle ?? ""
        cnContact.familyName = name.last ?? ""
        cnContact.namePrefix = name.prefix ?? ""
        cnContact.nameSuffix = name.suffix ?? ""
        cnContact.phoneticGivenName = name.phoneticFirst ?? ""
        cnContact.phoneticMiddleName = name.phoneticMiddle ?? ""
        cnContact.phoneticFamilyName = name.phoneticLast ?? ""
        cnContact.previousFamilyName = name.previousFamilyName ?? ""
        cnContact.nickname = name.nickname ?? ""
    }
}
