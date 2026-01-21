@testable import flutter_contacts
import XCTest

final class JsonHelpersTests: XCTestCase {
    func testEncodeOptionalAddsOnlyWhenPresent() {
        var json: Json = [:]
        json.set("name", "Ada")
        json.set("empty", nil as String?)
        XCTAssertEqual(json["name"] as? String, "Ada")
        XCTAssertNil(json["empty"])
    }

    func testDecodeListReturnsEmptyWhenMissing() {
        let json: Json = [:]
        let values = json.list("items") { $0["v"] as? String ?? "" }
        XCTAssertTrue(values.isEmpty)
    }
}
