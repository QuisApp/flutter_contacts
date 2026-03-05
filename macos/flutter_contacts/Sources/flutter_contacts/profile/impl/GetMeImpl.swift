import Contacts
import FlutterMacOS

enum GetMeImpl {
    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Check authorization status first
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        guard authorizationStatus == .authorized else {
            result(FlutterError(
                code: "permission_denied",
                message: "Contacts permission is required to get the Me card",
                details: nil
            ))
            return
        }

        let properties = Set(call.argList("properties") as [String]? ?? [])
        let store = ContactStoreProvider.shared
        let keys = KeysBuilder.build(properties: properties)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Fetch the Me card using unifiedMeContactWithKeys
                // Note: unifiedMeContactWithKeys is available on macOS 10.11+
                // unifiedMeContactWithKeys throws an error if no Me card has been set
                let meContact = try store.unifiedMeContactWithKeys(toFetch: keys)
                let options = ContactConverter.makeOptions(properties: properties)
                let json = ContactConverter.toJson(meContact, options: options)

                DispatchQueue.main.async {
                    result(json)
                }
            } catch {
                DispatchQueue.main.async {
                    // unifiedMeContactWithKeys throws an error when no Me card is set
                    // The most common case is that no Me card has been set, so we treat
                    // any error from this method as "no Me card set" unless it's clearly
                    // a permission error
                    let errorDescription = error.localizedDescription.lowercased()

                    // Check if it's a permission error
                    if errorDescription.contains("permission") ||
                        errorDescription.contains("authorization") ||
                        errorDescription.contains("denied")
                    {
                        result(FlutterError(
                            code: "permission_denied",
                            message: "Contacts permission is required to get the Me card",
                            details: nil
                        ))
                    } else {
                        // Most likely no Me card is set - return nil instead of error
                        // This matches the expected behavior where nil means "not found"
                        result(nil)
                    }
                }
            }
        }
    }
}
