import Contacts
import FlutterMacOS

class ListenerHandler: NSObject, FlutterStreamHandler {
    private let isDetailed: Bool
    private var state: ListenerState?

    init(isDetailed: Bool) {
        self.isDetailed = isDetailed
    }

    func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        state?.reset()
        let newState = ListenerState(isDetailed: isDetailed, eventSink: events)
        newState.registerObserver()
        state = newState
        return nil
    }

    func onCancel(withArguments _: Any?) -> FlutterError? {
        state?.reset()
        state = nil
        return nil
    }
}
