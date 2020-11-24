import Contacts

@available(iOS 9.0, *)
struct Name {
    var first: String = ""
    var last: String = ""
    var middle: String = ""
    var prefix: String = ""
    var suffix: String = ""
    var nickname: String = ""
    var firstPhonetic: String = ""
    var lastPhonetic: String = ""
    var middlePhonetic: String = ""

    init() {}

    init(fromMap m: [String: Any]) {
        first = m["first"] as! String
        last = m["last"] as! String
        middle = m["middle"] as! String
        prefix = m["prefix"] as! String
        suffix = m["suffix"] as! String
        nickname = m["nickname"] as! String
        firstPhonetic = m["firstPhonetic"] as! String
        lastPhonetic = m["lastPhonetic"] as! String
        middlePhonetic = m["middlePhonetic"] as! String
    }

    init(fromContact c: CNContact) {
        first = c.givenName
        last = c.familyName
        middle = c.middleName
        prefix = c.namePrefix
        suffix = c.nameSuffix
        nickname = c.nickname
        firstPhonetic = c.phoneticGivenName
        lastPhonetic = c.phoneticFamilyName
        middlePhonetic = c.phoneticMiddleName
    }

    func toMap() -> [String: Any] { [
        "first": first,
        "last": last,
        "middle": middle,
        "prefix": prefix,
        "suffix": suffix,
        "nickname": nickname,
        "firstPhonetic": firstPhonetic,
        "lastPhonetic": lastPhonetic,
        "middlePhonetic": middlePhonetic,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        c.givenName = first
        c.familyName = last
        c.middleName = middle
        c.namePrefix = prefix
        c.nameSuffix = suffix
        c.nickname = nickname
        c.phoneticGivenName = firstPhonetic
        c.phoneticFamilyName = lastPhonetic
        c.phoneticMiddleName = middlePhonetic
    }
}
