import Contacts
import FlutterMacOS
import Foundation

enum HandlerHelpers {
    static let errorCode = "flutter_contacts_error"
    static let readOnlyErrorCode = "read_only_contact"

    /// CNError codes meaning the store refused the write because the target isn't writable.
    /// Contacts.framework can't be asked before saving, so this is the only signal there is.
    private static let readOnlyCNErrorCodes: Set<Int> = [
        101, // noAccessibleWritableContainers
        206, // recordNotWritable
        207, // parentContainerNotWritable
    ]

    static func makeError(_ message: String) -> FlutterError {
        FlutterError(code: errorCode, message: message, details: nil)
    }

    static func makeError(from error: Error) -> FlutterError {
        let nsError = error as NSError
        let isReadOnly = nsError.domain == CNErrorDomain && readOnlyCNErrorCodes.contains(nsError.code)
        return FlutterError(
            code: isReadOnly ? readOnlyErrorCode : errorCode,
            message: error.localizedDescription,
            details: nil
        )
    }

    static func nsError(_ message: String, code: Int = 1) -> NSError {
        NSError(domain: errorCode, code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }

    static func handleResult(_ result: @escaping FlutterResult, _ block: () throws -> Any?) {
        do {
            try result(block())
        } catch {
            result(makeError(from: error))
        }
    }
}
