import Contacts

@available(iOS 9.0, *)
struct Organization {
    var company: String = ""
    var title: String = ""
    var department: String = ""
    var jobDescription: String = ""
    var symbol: String = ""
    var phoneticName: String = ""
    var officeLocation: String = ""

    init(fromMap m: [String: Any]) {
        company = m["company"] as! String
        title = m["title"] as! String
        department = m["department"] as! String
        jobDescription = m["jobDescription"] as! String
        symbol = m["symbol"] as! String
        phoneticName = m["phoneticName"] as! String
        officeLocation = m["officeLocation"] as! String
    }

    init(fromContact c: CNContact) {
        company = c.organizationName
        title = c.jobTitle
        department = c.departmentName
        // jobDescription, symbol and officeLocation not supported
        if #available(iOS 10, *) {
            phoneticName = c.phoneticOrganizationName
        }
    }

    func toMap() -> [String: Any] { [
        "company": company,
        "title": title,
        "department": department,
        "jobDescription": jobDescription,
        "symbol": symbol,
        "phoneticName": phoneticName,
        "officeLocation": officeLocation,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        c.organizationName = company
        c.jobTitle = title
        c.departmentName = department
        if #available(iOS 10, *) {
            c.phoneticOrganizationName = phoneticName
        }
    }
}
