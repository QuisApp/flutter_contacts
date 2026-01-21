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

    static func allRawValues(enableIosNotes: Bool) -> Set<String> {
        var values = Set(allCases.map(\.rawValue))
        if !enableIosNotes { values.remove(ContactProperty.note.rawValue) }
        return values
    }
}
