@testable import flutter_contacts
import FlutterMacOS
import XCTest

final class HandlerHelpersTests: XCTestCase {
    func testHandleResultReturnsValue() {
        let expectation = XCTestExpectation(description: "result returned")
        HandlerHelpers.handleResult({ value in
            if let number = value as? Int {
                XCTAssertEqual(number, 42)
                expectation.fulfill()
            }
        }, {
            42
        })
        wait(for: [expectation], timeout: 1.0)
    }

    func testHandleResultReturnsFlutterErrorOnThrow() {
        let expectation = XCTestExpectation(description: "error returned")
        HandlerHelpers.handleResult({ value in
            if let error = value as? FlutterError {
                XCTAssertEqual(error.code, "flutter_contacts_error")
                expectation.fulfill()
            }
        }, {
            throw NSError(domain: "test", code: 1)
        })
        wait(for: [expectation], timeout: 1.0)
    }
}
