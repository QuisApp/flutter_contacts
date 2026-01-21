import Contacts
import Foundation

struct Organization: Equatable, Hashable {
    let name: String?
    let jobTitle: String?
    let departmentName: String?
    let phoneticName: String?

    init(name: String? = nil, jobTitle: String? = nil, departmentName: String? = nil, phoneticName: String? = nil) {
        self.name = name
        self.jobTitle = jobTitle
        self.departmentName = departmentName
        self.phoneticName = phoneticName
    }

    func toJson() -> Json {
        var json: Json = [:]
        json.set("name", name)
        json.set("jobTitle", jobTitle)
        json.set("departmentName", departmentName)
        json.set("phoneticName", phoneticName)
        return json
    }

    static func fromJson(_ json: Json) -> Organization {
        Organization(
            name: (json["name"] as? String) ?? (json["organizationName"] as? String),
            jobTitle: json["jobTitle"] as? String,
            departmentName: json["departmentName"] as? String,
            phoneticName: json["phoneticName"] as? String
        )
    }

    init(fromContact contact: CNContact) {
        name = contact.organizationName.nilIfEmpty
        jobTitle = contact.jobTitle.nilIfEmpty
        departmentName = contact.departmentName.nilIfEmpty
        phoneticName = contact.phoneticOrganizationName.nilIfEmpty
    }

    var isEmpty: Bool { name == nil && jobTitle == nil && departmentName == nil && phoneticName == nil }

    static func apply(_ organization: Organization?, to cnContact: CNMutableContact) {
        if let organization = organization {
            cnContact.organizationName = organization.name ?? ""
            cnContact.jobTitle = organization.jobTitle ?? ""
            cnContact.departmentName = organization.departmentName ?? ""
            cnContact.phoneticOrganizationName = organization.phoneticName ?? ""
        } else {
            cnContact.organizationName = ""
            cnContact.jobTitle = ""
            cnContact.departmentName = ""
            cnContact.phoneticOrganizationName = ""
        }
    }
}
