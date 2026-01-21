import Contacts
import FlutterMacOS
import Foundation

class ChangeHistoryProcessor {
    private let eventSink: FlutterEventSink

    init(eventSink: @escaping FlutterEventSink) {
        self.eventSink = eventSink
    }

    func processChanges(historyToken: Data?, onTokenUpdated: @escaping (Data?) -> Void) {
        let contactStore = CNContactStore()
        let request = CNChangeHistoryFetchRequest()
        request.startingToken = historyToken

        let visitor = ChangeHistoryVisitor()
        guard let enumerator = getEnumerator(contactStore: contactStore, request: request) else { return }

        while let event = enumerator.nextObject() as? CNChangeHistoryEvent {
            event.accept(visitor)
        }

        let diffs = visitor.getEvents()
        if !diffs.isEmpty,
           let jsonData = try? JSONSerialization.data(withJSONObject: diffs.map { $0.toJson() }),
           let jsonString = String(data: jsonData, encoding: .utf8)
        {
            DispatchQueue.main.async { self.eventSink(jsonString) }
        }

        contactStore.currentHistoryToken.map(onTokenUpdated)
    }

    // Uses runtime reflection to call private API (enumeratorForChangeHistoryFetchRequest:error:)
    // This is necessary because the public API doesn't provide direct access to the enumerator
    private func getEnumerator(contactStore: CNContactStore, request: CNChangeHistoryFetchRequest) -> NSEnumerator? {
        let selector = NSSelectorFromString("enumeratorForChangeHistoryFetchRequest:error:")
        guard let method = class_getInstanceMethod(CNContactStore.self, selector) else {
            return nil
        }
        typealias EnumeratorMethod = @convention(c) (
            AnyObject,
            Selector,
            CNChangeHistoryFetchRequest,
            UnsafeMutablePointer<NSError?>
        ) -> AnyObject?
        let enumeratorMethod = unsafeBitCast(method_getImplementation(method), to: EnumeratorMethod.self)
        var error: NSError?
        guard let result = enumeratorMethod(contactStore, selector, request, &error) as? CNFetchResult<NSEnumerator> else {
            return nil
        }
        return result.value
    }
}
