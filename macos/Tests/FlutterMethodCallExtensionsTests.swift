@testable import flutter_contacts
import FlutterMacOS
import XCTest

final class FlutterMethodCallExtensionsTests: XCTestCase {
    func testArgAccessors() {
        let call = FlutterMethodCall(
            methodName: "test",
            arguments: ["name": "Ada", "age": 28, "items": ["a", "b"]]
        )

        let name: String? = call.arg("name")
        let age: Int = call.arg("age", default: 0)
        let items: [String]? = call.argList("items")

        XCTAssertEqual(name, "Ada")
        XCTAssertEqual(age, 28)
        XCTAssertEqual(items ?? [], ["a", "b"])
    }
}
