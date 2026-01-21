import Contacts
import FlutterMacOS

public class ListenerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let simpleListenerChannel = FlutterEventChannel(
            name: "flutter_contacts/simple_listener",
            binaryMessenger: registrar.messenger
        )
        let detailedListenerChannel = FlutterEventChannel(
            name: "flutter_contacts/detailed_listener",
            binaryMessenger: registrar.messenger
        )
        simpleListenerChannel.setStreamHandler(ListenerHandler(isDetailed: false))
        detailedListenerChannel.setStreamHandler(ListenerHandler(isDetailed: true))
    }
}
