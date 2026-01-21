import Foundation

enum ContactProperty: String, CaseIterable {
    case name
    case phone
    case email
    case address
    case organization
    case website
    case socialMedia
    case event
    case relation
    case note
    case photoThumbnail
    case photoFullRes

    static func allRawValues() -> Set<String> {
        return Set(allCases.map(\.rawValue))
    }
}
