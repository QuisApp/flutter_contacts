import Contacts
import Flutter
import Foundation

class ListenerState {
    private static let debounceMs: TimeInterval = 0.3

    private let isDetailed: Bool
    private var eventSink: FlutterEventSink?
    private let queue = DispatchQueue(label: "co.quis.flutter_contacts.listener", qos: .utility)

    private var observer: NSObjectProtocol?
    private var debounceWorkItem: DispatchWorkItem?
    private var historyToken: Data?
    private var processor: ChangeHistoryProcessor?

    init(isDetailed: Bool, eventSink: @escaping FlutterEventSink) {
        self.isDetailed = isDetailed
        self.eventSink = eventSink
        if isDetailed {
            historyToken = CNContactStore().currentHistoryToken
        }
    }

    func registerObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .CNContactStoreDidChange,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.handleContactChange()
        }
    }

    private func handleContactChange() {
        guard eventSink != nil else { return }

        cancelDebounceTask()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, let eventSink = self.eventSink else { return }
            if self.isDetailed {
                self.processChanges(eventSink)
            } else {
                DispatchQueue.main.async { eventSink(nil) }
            }
        }

        debounceWorkItem = workItem
        queue.asyncAfter(deadline: .now() + Self.debounceMs, execute: workItem)
    }

    private func processChanges(_ eventSink: @escaping FlutterEventSink) {
        processor = processor ?? ChangeHistoryProcessor(eventSink: eventSink)
        processor?.processChanges(historyToken: historyToken) { [weak self] in
            self?.historyToken = $0
        }
    }

    private func cancelDebounceTask() {
        debounceWorkItem?.cancel()
        debounceWorkItem = nil
    }

    func reset() {
        cancelDebounceTask()
        observer.map(NotificationCenter.default.removeObserver)
        observer = nil
        eventSink = nil
        processor = nil
        historyToken = nil
    }
}
