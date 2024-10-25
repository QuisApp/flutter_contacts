#if os(iOS)
import Flutter
import UIKit


@available(iOS 9.0, *)
@available(macOS, unavailable)
public class ContactViewIOS: CNContactViewControllerDelegate {

    private let flutterContactsPlugin: FlutterContactsPlugin
    private let rootViewController: UIViewController
    private let contactViewIOS: ContactViewIOS

    init(_ flutterContactsPlugin: FlutterContactsPlugin) {
        self.flutterContactsPlugin = flutterContactsPlugin;
        rootViewController = UIApplication.shared.delegate!.window!!.rootViewController!
    }

    public func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) { 
        if let result = flutterContactsPlugin.externalResult {
            result(contact?.identifier)
            flutterContactsPlugin.externalResult = nil
        }
        viewController.dismiss(animated: true, completion: nil)
    }
}
#endif