import Foundation

typealias Json = [String: Any]
typealias JsonArray = [Json]

extension Dictionary where Key == String, Value == Any {
    mutating func set<T>(_ key: String, _ value: T?) {
        if let value { self[key] = value }
    }

    mutating func setJson<T>(_ key: String, _ value: T?, _ toJson: (T) -> Json) {
        if let value { self[key] = toJson(value) }
    }

    mutating func setList<T>(_ key: String, _ list: [T], _ toJson: (T) -> Json) {
        if !list.isEmpty { self[key] = list.map(toJson) }
    }

    func value<T>(_ key: String) -> T? {
        self[key] as? T
    }

    func json<T>(_ key: String, _ fromJson: (Json) -> T) -> T? {
        (self[key] as? Json).map(fromJson)
    }

    func list<T>(_ key: String, _ fromJson: (Json) -> T) -> [T] {
        (self[key] as? JsonArray)?.map(fromJson) ?? []
    }
}

extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
