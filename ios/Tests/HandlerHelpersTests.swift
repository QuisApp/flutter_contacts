import Contacts
import Flutter
@testable import flutter_contacts
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

    func testReadOnlyCNErrorsGetTheirOwnCode() {
        for code in [101, 206, 207] {
            let error = HandlerHelpers.makeError(from: NSError(domain: CNErrorDomain, code: code))
            XCTAssertEqual(error.code, "read_only_contact", "CNError \(code)")
        }
    }

    func testOtherErrorsKeepTheGenericCode() {
        for error in [
            NSError(domain: CNErrorDomain, code: 200),
            NSError(domain: CNErrorDomain, code: 500),
            NSError(domain: "other", code: 206),
        ] {
            XCTAssertEqual(HandlerHelpers.makeError(from: error).code, "flutter_contacts_error")
        }
    }
}
